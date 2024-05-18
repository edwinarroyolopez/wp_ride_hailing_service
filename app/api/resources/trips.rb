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
          # Aquí iría la lógica para solicitar un viaje
          { message: 'Ride requested successfully' }
        else
          error!('Not allowed', 403)
        end
      end
    end
  end
end