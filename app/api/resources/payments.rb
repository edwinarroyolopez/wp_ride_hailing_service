require 'grape'
require 'httparty'

module Resources
    class Payments < Grape::API
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
  
          url = "#{ENV['EXTERNAL_API_URL']}/tokens/cards"
        #   logger.info("external url  #{url}")
  
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
  
          response = HTTParty.post(url, body: body.to_json, headers: headers)
  
          if response.success?
            return JSON.parse(response.body)
          else
            raise StandardError, "Error creating payment source intent: #{response.code} - #{response.body}"
          end
        end
      end
    end
  end
  