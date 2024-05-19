require 'httparty'

module PaymentHelper
  def generate_acceptance_token(pubGatewayKey)
      url = "#{ENV['EXTERNAL_API_URL']}/merchants/#{pubGatewayKey}"
      response = HTTParty.get(url)

      if response.success?
        bodyResult = JSON.parse(response.body)
        acceptance_token = bodyResult['data']['presigned_acceptance']['acceptance_token']
        return acceptance_token
      else
        raise StandardError, "Error getting aceptation token: #{response.code} - #{response.body}"
      end 
  end

  def generate_external_transaction(body, headers)
    url = "#{ENV['EXTERNAL_API_URL']}/transactions"
    response =  HTTParty.post(url, body: body.to_json, headers: headers)

    if response.success?
      return JSON.parse(response.body)
    else
      raise StandardError, "Error while was generating the transaction: #{response.code} - #{response.body}"
    end 
  end

end