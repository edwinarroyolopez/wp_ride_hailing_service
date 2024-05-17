require 'grape'
require 'httparty'
require 'bcrypt'
require 'jwt'
require 'json'
require 'logger'
require_relative '../config/env'
require_relative 'models'

class TransporteAPI < Grape::API
    format :json
    logger = Logger.new(STDOUT)

    base_api_url = ENV['EXTERNAL_API_URL']
    SECRET_KEY = ENV['SECRET_KEY']


    # Arreglo de usuarios
    USERS = [
      { user_id: 1, name: 'Alice', phone: '123-456-7890', user_type: 'rider', email: 'alice@example.com', pass: BCrypt::Password.create('password1') },
      { user_id: 2, name: 'Bob', phone: '234-567-8901', user_type: 'rider', email: 'bob@example.com', pass: BCrypt::Password.create('password2') },
      { user_id: 3, name: 'Charlie', phone: '345-678-9012', user_type: 'rider', email: 'charlie@example.com', pass: BCrypt::Password.create('password3') },
      { user_id: 4, name: 'Dave', phone: '456-789-0123', user_type: 'driver', email: 'dave@example.com', pass: BCrypt::Password.create('password4') },
      { user_id: 5, name: 'Eve', phone: '567-890-1234', user_type: 'driver', email: 'eve@example.com', pass: BCrypt::Password.create('password5') },
      { user_id: 6, name: 'Frank', phone: '678-901-2345', user_type: 'driver', email: 'frank@example.com', pass: BCrypt::Password.create('password6') }
  ]

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
      def find_user_by_email(email)
        USERS.find { |user| user[:email] == email }
      end
  
      def encode_token(payload)
        JWT.encode(payload, SECRET_KEY, 'HS256')
      end
  
      def decode_token(token)
        JWT.decode(token.split(' ').last, SECRET_KEY, true, { algorithm: 'HS256' })[0]
      rescue
        nil
      end
  
      def authenticate!(token)
        decoded_token = decode_token(token)
        error!('Unauthorized', 401) unless decoded_token
      end
  
      def current_user(token)
        decoded_token = decode_token(token)
        USERS.find { |user| user[:user_id] == decoded_token['user_id'] }
      end
    end

    resource :users do
      desc 'Get all users'
      get do
        USERS
      end
  
      desc 'Login and get a token'
      params do
        requires :email, type: String, desc: 'Email of the user'
        requires :pass, type: String, desc: 'Password of the user'
      end
      post :login do
        user = find_user_by_email(params[:email])
  
        if user && BCrypt::Password.new(user[:pass]) == params[:pass]
          token = encode_token({ user_id: user[:user_id] })
          { token: "Bearer #{token}", user_id: user[:user_id] }
        else
          error!('Unauthorized', 401)
        end
      end
    end

    resource :create_payment_source do
      desc 'Create a new payment source'
      params do
        requires :userId, type: String, desc: 'Id of the user'
        requires :user_type, type: String, desc: 'User type (driver o rider)'
      end
      post do
        jwtToken = headers['Authorization'] ? headers['Authorization'] : params[:Authorization]
        authenticate!(jwtToken)
        userLogged = decode_token(jwtToken)

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
  