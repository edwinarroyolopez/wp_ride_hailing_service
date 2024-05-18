require 'spec_helper'
require 'rack/test'
require 'jwt'

RSpec.describe 'Trips API' do
  include Rack::Test::Methods

  def app
    TransporteAPI
  end

  let(:secret_key) { ENV['SECRET_KEY'] }
  let(:rider_token) { JWT.encode({ user_id: 1, user_type: 'rider' }, secret_key, 'HS256') }
  let(:driver_token) { JWT.encode({ user_id: 4, user_type: 'driver' }, secret_key, 'HS256') }

  describe 'POST /request_ride' do
    context 'when the user is a rider' do
      it 'requests a ride successfully' do
        post '/request_ride', { latitude: 10.0, longitude: 20.0, 'Authorization' => "Bearer #{rider_token}"}
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to include('status' => 'requested')
      end
    end

    context 'when the user is not a rider' do
      it 'returns an error' do
        post '/request_ride', { latitude: 10.0, longitude: 20.0, 'Authorization' => "Bearer #{driver_token}"  }
        expect(last_response.status).to eq(403)
        expect(JSON.parse(last_response.body)).to include('error' => 'Not allowed')
      end
    end
  end

  describe 'POST /finish_ride' do
    context 'when the user is a driver' do
      it 'finishes the ride successfully' do
        post '/finish_ride', { latitude: 10.0, longitude: 20.0, ride_id: 1, 'Authorization' => "Bearer #{driver_token}"  }
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to include('status' => 'finished')
      end
    end

    context 'when the user is not a driver' do
      it 'returns an error' do
        post '/finish_ride', { latitude: 10.0, longitude: 20.0, ride_id: 1, 'Authorization' => "Bearer #{rider_token}" }
        expect(last_response.status).to eq(403)
        expect(JSON.parse(last_response.body)).to include('error' => 'Not allowed')
      end
    end
  end

  describe 'POST /create_payment_source' do
    let(:external_api_url) { ENV['EXTERNAL_API_URL'] }
    let(:pub_gateway_key) { ENV['PUB_GATEWAY_KEY'] }

    before do
      stub_request(:post, "#{external_api_url}/tokens/cards")
        .to_return(status: 200, body: { token: 'card_token' }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'creates a new payment source successfully with valid token' do
      post '/create_payment_source', { userId: '1', user_type: 'rider', 'Authorization' => "Bearer #{rider_token}"  }
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to include('token' => 'card_token')
    end

    context 'when the token is invalid' do
      let(:params) { { userId: '1', user_type: 'driver' } }
      let(:invalid_token) { 'invalid_token' }

      it 'returns an authentication error' do
        post '/create_payment_source', params, { 'Authorization' => "Bearer #{invalid_token}" }
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end
end
