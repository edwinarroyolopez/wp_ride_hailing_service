require 'logger'

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
      desc 'Request a ride'
      params do
        requires :latitude, type: Float, desc: 'Latitude of the pickup location'
        requires :longitude, type: Float, desc: 'Longitude of the pickup location'
      end
      post do
        jwtToken = headers['Authorization'] ? headers['Authorization'] : params[:Authorization]
        authenticate!(jwtToken)
        user = current_user(jwtToken)
        
        logger.info("user  #{user}")

        if user[:user_type] == 'rider'
            # Seleccionar un conductor aleatorio
            drivers = USERS.select { |u| u[:user_type] == 'driver' }
            assigned_driver = drivers.sample
        
            ride = {
              ride_id: SecureRandom.uuid,
              rider_id: user[:user_id],
              driver_id: assigned_driver[:user_id],
              latitude: params[:latitude],
              longitude: params[:longitude],
              status: 'requested',
              created_at: Time.now,
              updated_at: Time.now
            }

            logger.info("ride  #{ride}")
          
          { message: 'Ride requested successfully' }
        else
          error!('Not allowed', 403)
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
        if user[:user_type] == 'driver'
          # Aquí iría la lógica para finalizar un viaje
          { message: 'Ride finished successfully' }
        else
          error!('Not allowed', 403)
        end
      end
    end

  end
end