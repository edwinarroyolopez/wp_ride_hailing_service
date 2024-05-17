require 'grape'
require 'httparty'
require 'json'
require 'logger'
require_relative '../config/env'
require_relative 'models'

class TransporteAPI < Grape::API
    format :json
    logger = Logger.new(STDOUT)

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

    resource :create_payment_source do
      desc 'Create a new payment source'
      params do
        requires :userId, type: String, desc: 'Id of the user'
        requires :user_type, type: String, desc: 'User type (driver o rider)'
      end
      post do
        base_api_url = ENV['EXTERNAL_API_URL']
        url = "#{base_api_url}/tokens/cards"
        logger.info("create_payment_method -> Este es un mensaje de información #{url}")
          # Construir el cuerpo de la solicitud a la API externa
          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{ENV['PUB_GATEWAY_KEY']}"
          }

          body = {
            number: "4242424242424242",
            cvc: "789",
            exp_month: "12",
            exp_year: "29",
            card_holder: "Pedro Pérez"
          }

          response = HTTParty.post(url, body: body.to_json, headers:  headers)

          if response.success?
            return JSON.parse(response.body)
          else
            raise StandardError, "Error creating payment source intent: #{response.code} - #{response.body}"
          end

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
  