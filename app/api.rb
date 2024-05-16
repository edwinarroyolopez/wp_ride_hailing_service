require 'grape'
require 'json'
require_relative '../config/env'
require_relative 'models'

class TransporteAPI < Grape::API
    format :json
  
    # User
    class User
      attr_reader :type
  
      def initialize(type)
        @type = type
      end
  
      def driver?
        @type == 'driver'
      end
  
      def rider?
        @type == 'rider'
      end
    end
  
    # User auth 
    helpers do
      def current_user
        User.new(params[:user_type])
      end
    end
  
    resource :trip_cost do
      desc 'Calculate the cost of the trip'
      params do
        requires :origin, type: String, desc: 'Origin of the trip'
        requires :destiny, type: String, desc: 'Detiny of the trip'
        requires :distance, type: Float, desc: 'Distance of the trip on kms'
        requires :user_type, type: String, desc: 'User type (driver o rider)'
      end
      post do
        user = current_user
        if user.driver?
          cost = Ride.calculate_cost(params[:distance])
          { cost: cost }
        else
          { error: 'Drivers cannot calculate the cost of the trip' }
        end
      end
    end
  end
  