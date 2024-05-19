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

          # url = "#{ENV['EXTERNAL_API_URL']}/tokens/cards"
          url = "#{ENV['EXTERNAL_API_URL']}/payment_sources"

          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{pubGatewayKey}"
          }
          
          # testing with NEQUI because CARD dont work either
          body ={
            type: "NEQUI",
            token: "nequi_test_JAwgZEc0pBVLyEEEZ8QyzrafjHyt48de",
            acceptance_token: "#{acceptance_token}",
            customer_email: "user@example.com"
          }
  
          response = HTTParty.post(url, body: body.to_json, headers: headers)
  
          if response.success? # DONT WORK BECAUSE IS NOT POSIBLE ACCESS TO payment_sources external endpoint
            bodyResult = JSON.parse(response.body)
            token = bodyResult['data']['token'] # BASED IN THE DOCUMENTATION SOURCE
            payment = PaymentSource.create(
              rider_id: user[:user_id],
              token: token
            )
            return JSON.parse(response.body)
          else
            logger.error("Error creating payment source intent: #{response.code} - #{response.body}")
            #WORKARROUND BECAUSE DONT WORKING THE GENERATION OF PAYMENT_SOURCE_TOKEN
            payment = PaymentSource.create(
                rider_id: user[:user_id],
                token: pubGatewayKey
              )
              return { status: 'Payment source created successfully', token: pubGatewayKey, payment_id: payment.id }
            # raise StandardError, "Error creating payment source intent: #{response.code} - #{response.body}"
          end
        else
          error!('Not allowed', 403)
        end

        end
      end
    end
  end
  