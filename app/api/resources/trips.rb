require 'logger'
require 'dry-validation'
require_relative '../../models/ride'
require_relative '../../validators/ride_schema'

module Resources
  class Trips < Grape::API
    format :json
    logger = Logger.new(STDOUT)
    resource :trip_cost do
      desc 'Calculate the cost of the trip'
      params do
        requires :origin, type: String, desc: 'Origin of the trip'
        requires :destiny, type: String, desc: 'Destiny of the trip'
        requires :distance, type: Float, desc: 'Distance of the trip on kms'
        requires :user_type, type: String, desc: 'User type (driver o rider)'
      end
      post do
        user = current_user(headers['Authorization'])
        if user[:user_type] == 'driver'
          cost = Ride.calculate_cost(params[:distance])
          { cost: cost }
        else
          { error: 'Riders cannot calculate the cost of the trip' }
        end
      end
    end

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
          
          { message: 'Ride requested successfully', status: 'requested' }
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

          logger.info("ride  user #{user}")

          ride = Ride.find(id: params[:ride_id])
          if !ride
            error!("Not found a ride whith this ride_id: #{params[:ride_id]}", 403)
          end

          if ride.driver_id != user[:user_id]
            error!("Not allowed, you are not the driver of this ride", 403)
          end

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

          { message: 'Ride finished successfully', status: 'finished' }
        else
          error!(validation.errors.to_h, 400)
        end
      end
    end

  end
end