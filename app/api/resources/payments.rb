require 'grape'
require 'httparty'
require_relative '../../models/payment_source'

module Resources
    class Payments < Grape::API
      format :json
      logger = Logger.new(STDOUT)
      resource :create_payment_source do
        desc 'Create a new payment source'
        post do
          jwtToken = headers['Authorization'] ? headers['Authorization'] : params[:Authorization]
          authenticate!(jwtToken)
          user = current_user(jwtToken)

        if user[:user_type] == 'rider'
          pubGatewayKey = params[:pubGatewayKey] ? params[:pubGatewayKey] : ENV['PUB_GATEWAY_KEY'] # IF THIS PARAM IS SET MAYBY WORKING

          logger.info("user #{user}")

          if PaymentSource.find(rider_id: user[:user_id])
            error!('Not allowed, Payment source already exists for rider', 403)
          end
          
          acceptance_token = generate_acceptance_token(pubGatewayKey)

          logger.info("acceptance_token #{acceptance_token}")

          url = "#{ENV['EXTERNAL_API_URL']}/tokens/cards"

          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{pubGatewayKey}"
          }
          
          # card harcoded
          body = {
            number: "4242424242424242",
            cvc: "789",
            exp_month: "12",
            exp_year: "29",
            card_holder: "Pedro Pérez"
          }
  
          response = HTTParty.post(url, body: body.to_json, headers: headers)
  
          if response.success? 
            bodyResult = JSON.parse(response.body)
            token = bodyResult['data']['id'] 
            payment = PaymentSource.create(
              rider_id: user[:user_id],
              token: "#{token ? token : ENV['TOKEN_CARD']}"
            )
            return {status: 'Payment source created successfully', token: "#{token ? token : ENV['TOKEN_CARD']}"}
          else
            logger.error("Error creating payment source intent: #{response.code} - #{response.body}")
            raise StandardError, "Error creating payment source intent: #{response.code} - #{response.body}"
          end
        else
          error!('Not allowed', 403)
        end

        end
      end
    end
  end
  