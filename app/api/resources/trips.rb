module Resources
    class Trips < Grape::API
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
    end
  end
  