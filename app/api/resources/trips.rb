require 'logger'
require 'dry-validation'
require 'httparty'
require_relative '../../models/ride'
require_relative '../../validators/ride_schema'
require_relative '../../models/payment_source'
require_relative '../../models/transaction'


module Resources
  class Trips < Grape::API
    format :json
    logger = Logger.new(STDOUT)
    BASE_URL = Constants::EXTERNAL_API_URL


    resource :request_ride do
      desc 'Request a new ride'
      params do
        requires :latitude, type: Float, desc: 'Current latitude of the rider'
        requires :longitude, type: Float, desc: 'Current longitude of the rider'
      end
      post do
        jwtToken = headers['Authorization'] ? headers['Authorization'] : params[:Authorization]
        authenticate!(jwtToken)
        user = current_user(jwtToken)
        
        error!('Not allowed', 403) unless user[:user_type] == 'rider'
        validation = Validators::RideRequestSchema.call(params)

        if validation.success?
          logger.info("Creating ride to user #{user}")
          request_ride(params, user)
        else
          error!(validation.errors.to_h, 400)
        end
      end
    end

    resource :finish_ride do
      desc 'Finish a ride'
      params do
        requires :latitude, type: Float, desc: 'Latitude of the finish location'
        requires :longitude, type: Float, desc: 'Longitude of the finish location'
        requires :ride_id, type: Integer, desc: 'ID of the ride'
      end
      post do
        jwtToken = headers['Authorization'] ? headers['Authorization'] : params[:Authorization]
        authenticate!(jwtToken)
        user = current_user(jwtToken)

        error!('Not allowed', 403) unless user[:user_type] == 'driver'
        validation = Validators::RideFinishSchema.call(params)

        if validation.success?
          logger.info("Finishing ride...")
          logger.info("Validating ride...")
          ride = validations_ride(params[:ride_id], user[:user_id])
          logger.info("Generating payment source token...")
          payment_token = get_payment_source(ride.rider_id)# TOKEN PAYMENT SOURCE TO MAKE TRANSTACTION

          # latitude and longitude parameters
          latitude_start = ride.latitude_start
          longitude_start = ride.longitude_start
          latitude_finish = params[:latitude]
          longitude_finish = params[:longitude]
          
          logger.info("Calculing ride distance...")
          distance = calculate_distance(latitude_start, longitude_start, latitude_finish, longitude_finish)
          distance = distance.round
          logger.info("Ride distance #{distance}")

          logger.info("Calculing time elapsed in the ride...")
          timeStart = ride.created_at
          timeElapsed = calculate_time_elapsed(timeStart)
          logger.info("Ride time elapsed: #{timeElapsed}")

          logger.info("Calculing ride cost...")
          cost = calculate_cost(distance,timeElapsed)
          logger.info("Ride cost: #{cost}")

          # Update the ride status to finished and update coordinates
          ride.update(
            latitude_finish: params[:latitude],
            longitude_finish: params[:longitude],
            distance: distance,
            elapsed_time: timeElapsed,
            status: 'finished'
          )

          # Generate the acceptation token
          logger.info("Generating the acceptation token")
          acceptance_token = generate_acceptance_token()
          logger.info("Acceptance token generated: #{acceptance_token}")
          
          logger.info("Generating external transaction")
          external_transaction = generate_external_transaction(acceptance_token, payment_token, user[:email], cost)
          # return external_transaction
           
          logger.info("External transaction generated #{external_transaction}")

          transaction_external_id = external_transaction['data']['id']
          transaction_external_status = external_transaction['data']['status']
          # # # # # # # # # # :P # # # # # # # # # #
          transaction = Transaction.create(
            ride_id: ride.id,
            cost: cost,
            distance: distance,
            status: transaction_external_status,
            id_external_transaction: transaction_external_id
          )

          logger.info("Transaction generated on localdb...")

          { message: 'Ride finished successfully', status: 'finished', transaction_status: transaction_external_status, transaction_id: transaction.id, external_id: transaction_external_id }
        else
          error!(validation.errors.to_h, 400)
        end
      end
    end

  end
end