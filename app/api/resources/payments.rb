require 'grape'
require 'httparty'
require_relative '../../models/payment_source'

module Resources
    class Payments < Grape::API
      format :json
      logger = Logger.new(STDOUT)
      resource :create_payment_source do
        desc 'Create a new payment source'
        params do
          requires :userId, type: String, desc: 'Id of the user'
          requires :user_type, type: String, desc: 'User type (driver o rider)'
        end
        post do
          jwtToken = headers['Authorization'] ? headers['Authorization'] : params[:Authorization]
          authenticate!(jwtToken)
          user = current_user(jwtToken)

        if user[:user_type] == 'rider'
          pubGatewayKey = params[:pubGatewayKey] ? params[:pubGatewayKey] : ENV['PUB_GATEWAY_KEY']

          logger.info("user #{user}")
          logger.info("pubGatewayKey #{pubGatewayKey}")

          if PaymentSource.find(rider_id: user[:user_id])
            error!('Not allowed, Payment source already exists for rider', 403)
          end

          PaymentSource.create(
            rider_id: user[:user_id],
            pub_gateway_key: pubGatewayKey
          )
          # { status: 'Payment source created successfully', token: payment_source_data['token'] }
        

          url = "#{ENV['EXTERNAL_API_URL']}/tokens/cards"

          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{pubGatewayKey}"
          }
  
          body = {
            number: "4242424242424242",
            cvc: "789",
            exp_month: "12",
            exp_year: "29",
            card_holder: "Pedro Pérez"
          }
  
          response = HTTParty.post(url, body: body.to_json, headers: headers)
  
          if response.success?
            return JSON.parse(response.body)
          else
            raise StandardError, "Error creating payment source intent: #{response.code} - #{response.body}"
          end
        else
          error!('Not allowed', 403)
        end

        end
      end
    end
  end
  