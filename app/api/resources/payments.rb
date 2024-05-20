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
          logger.info("Verifying if is a rider user")
          if user[:user_type] == 'rider'
            logger.info("Verifying that there is no payment source for the user #{user}")
            verify_payment_source_rider(user[:user_id])
            logger.info("Generating the payment source token")
            generate_payment_source_token(user[:user_id])
          else
            error!('Not allowed', 403)
          end
        end
      end
    end
  end