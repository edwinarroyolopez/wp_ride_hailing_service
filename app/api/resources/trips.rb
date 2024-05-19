require 'logger'
require 'dry-validation'
require 'httparty'
require 'securerandom'
require_relative '../../models/ride'
require_relative '../../validators/ride_schema'
require_relative '../../models/payment_source'
require_relative '../../models/transaction'

module Resources
  class Trips < Grape::API
    format :json
    logger = Logger.new(STDOUT)
    BASE_URL = ENV['EXTERNAL_API_URL']

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
          # Verify that the payment source exists before create the new ride
          if !PaymentSource.find(rider_id: user[:user_id])
            error!('Not allowed, Payment source dond exists for this rider, you need create a payment source first', 403)
          end

          # additional validation
          # oldRide = Ride.find(rider_id: user[:user_id], status: 'requested')
          # if oldRide
          #   error!("Cannot created a new ride because you already an open ride: #{oldRide.id}", 403)
          # end

          drivers = USERS.select { |u| u[:user_type] == 'driver' }
          assigned_driver = drivers.sample
    
          ride = Ride.create(
            rider_id: user[:user_id],
            driver_id: assigned_driver[:user_id],
            latitude_start: params[:latitude],
            longitude_start: params[:longitude],
            status: 'requested'
          )

          logger.info("ride  #{ride}")
          
          { message: 'Ride requested successfully', status: 'requested', ride_id:ride.id, driver_id:ride.driver_id }
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
          # find a ride
          # cal distance between the start location and the finish location
          # create a new transaction and change status

          logger.info("diver  user #{user}")

          ride = Ride.find(id: params[:ride_id])
          if !ride
            error!("Not found a ride whith this ride_id: #{params[:ride_id]}", 404)
          end

          if ride.status != 'requested'
            error!("Not allowed, the ride was finished before", 403)
          end

          if ride.driver_id != user[:user_id]
            error!("Not allowed, you are not the driver of this ride", 403)
          end

          payment_source = PaymentSource.find(rider_id: ride.rider_id)
          # TOKEN PAYMENT SOURCE TO MAKE TRANSTACTION
          paymentToken = payment_source.respond_to?(:token)? payment_source.token : ENV['TOKEN_CARD'] 
          logger.info(" paymentToken #{paymentToken}")

          latitude_start = ride.latitude_start
          longitude_start = ride.longitude_start
          
          latitude_finish = params[:latitude]
          longitude_finish = params[:longitude]
          
          # validate that the driver is same on ride
          logger.info("ride  driver_id #{ride.driver_id}")
          logger.info("ride  latitude_start: #{ride.latitude_start} longitude_start: #{ride.longitude_start}")
          logger.info("ride  latitude_finish: #{latitude_finish} longitude_finish: #{longitude_finish}")
          distance = calculate_distance(latitude_start, longitude_start, latitude_finish, longitude_finish)
          distance = distance.round

          logger.info("ride  distance #{distance}")
          timeStart = ride.created_at
          timeEnd = Time.now
          
          logger.info("ride  timeStart: #{timeStart} timeEnd: #{timeEnd}")

          timeElapsed = calculate_time_elapsed(timeStart, timeEnd)

          logger.info("ride  timeElapsed: #{timeElapsed}")

          # Update the ride status to finished and update coordinates
          ride.update(
            latitude_finish: params[:latitude],
            longitude_finish: params[:longitude],
            distance: distance,
            elapsed_time: timeElapsed,
            status: 'finished'
          )

          cost = calculate_cost(distance,timeElapsed)

          logger.info("cost: #{cost}")

          pubGatewayKey = params[:pubGatewayKey] ? params[:pubGatewayKey] : ENV['PUB_GATEWAY_KEY']
          # Generate the acceptation token
          logger.info("Generating the acceptation token")
          acceptance_token = generate_acceptance_token(pubGatewayKey)
            
          logger.info("acceptance_token: #{acceptance_token}")
          
          #  excecute a transaction
          reference = SecureRandom.hex(16)
          
          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{pubGatewayKey}"
          }

          body = {
            acceptance_token: "#{acceptance_token}",
            amount_in_cents: cost*100,
            currency: "COP",
            customer_email: "#{user[:email]}",
            reference: reference,
            payment_method: {
              type: "CARD",
              token: "#{paymentToken}",
              installments: 2
            }
          }
          
          logger.info("Generating external transaction")
          external_transaction = generate_external_transaction(body, headers)
          # return external_transaction
           
          logger.info("external_transaction #{external_transaction}")

          transaction_external_id = external_transaction['data']['id']
          transaction_external_status = external_transaction['data']['status']
          transaction = Transaction.create(
            ride_id: ride.id,
            cost: cost,
            distance: distance,
            status: transaction_external_status,
            id_external_transaction: transaction_external_id
          )

          logger.info("Transaction generated...")


          { message: 'Ride finished successfully', status: 'finished', transaction_status: transaction_external_status, transaction_id: transaction.id, external_id: transaction_external_id }
        else
          error!(validation.errors.to_h, 400)
        end
      end
    end

  end
end