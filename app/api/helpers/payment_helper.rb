require 'httparty'
require 'securerandom'
require_relative '../../models/payment_source'

module PaymentHelper
  BASE_URL = Constants::EXTERNAL_API_URL
  TOKEN_CARD = Constants::TOKEN_CARD
  PUB_GATEWAY_KEY = Constants::PUB_GATEWAY_KEY 

  def generate_acceptance_token()
      url = "#{BASE_URL}/merchants/#{PUB_GATEWAY_KEY}"
      response = HTTParty.get(url)

      if response.success?
        bodyResult = JSON.parse(response.body)
        acceptance_token = bodyResult['data']['presigned_acceptance']['acceptance_token']
        return acceptance_token
      else
        raise StandardError, "Error getting aceptation token: #{response.code} - #{response.body}"
      end 
  end

  def generate_payment_source_token(rider_id)
    url = "#{BASE_URL}/tokens/cards"
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{PUB_GATEWAY_KEY}"
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
        rider_id: rider_id,
        token: "#{token ? token : TOKEN_CARD}"
      )
      return {status: 'Payment source created successfully', token: "#{token ? token : ENV['TOKEN_CARD']}"}
    else
      raise StandardError, "Error creating payment source intent: #{response.code} - #{response.body}"
    end
  end

  def generate_external_transaction(acceptance_token, payment_token, email, cost)
    #  create the reference
    #reference = SecureRandom.hex(16)
    url = "#{BASE_URL}/transactions"
      
     headers = {
       'Content-Type' => 'application/json',
       'Authorization' => "Bearer #{PUB_GATEWAY_KEY}"
     }

     body = {
       acceptance_token: "#{acceptance_token}",
       amount_in_cents: cost*100,
       currency: "COP",
       customer_email: "#{email}",
       reference: "#{cost*100}-#{email}",
       payment_method: {
         type: "CARD",
         token: "#{payment_token}",
         installments: 2
       }
     }

    response =  HTTParty.post(url, body: body.to_json, headers: headers)
    if response.success?
      return JSON.parse(response.body)
    else
      raise StandardError, "Error while was generating the transaction: #{response.code} - #{response.body}"
    end 
  end
  
  def verify_payment_source_rider(rider_id)
    if PaymentSource.find(rider_id: rider_id)
      error!('Not allowed, Payment source already exists for rider', 403)
    end
  end
end