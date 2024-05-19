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

  let(:pub_gateway_key) { ENV['PUB_GATEWAY_KEY'] }
  let(:user_token) { 'test_token' }
  let(:headers) { { 'Authorization' => user_token } }
  let(:rider) { { user_id: 1, user_type: 'rider', email: 'rider@example.com' } }
  let(:driver) { { user_id: 2, user_type: 'driver', email: 'driver@example.com' } }
  let(:ride) { Ride.create(rider_id: rider[:user_id], driver_id: driver[:user_id], latitude_start: 1.0, longitude_start: 1.0, status: 'requested') }

  before do
    allow_any_instance_of(Resources::Trips).to receive(:authenticate!).and_return(true)
    allow_any_instance_of(Resources::Trips).to receive(:current_user).and_return(driver)

    stub_request(:get, "#{ENV['EXTERNAL_API_URL']}/merchants/#{pub_gateway_key}")
      .to_return(
        status: 200,
        body: { data: { presigned_acceptance: { acceptance_token: 'test_acceptance_token' } } }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:post, "#{ENV['EXTERNAL_API_URL']}/transactions")
      .to_return(
        status: 200,
        body: { status: 'success', transaction_id: '12345' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'POST /finish_ride' do

    let!(:ride) do
      Ride.create(
        rider_id: 1,
        driver_id: 4,
        latitude_start: 40.7128,
        longitude_start: -74.0060,
        status: 'requested'
      )
    end
  

    it 'finishes a ride successfully and updates the ride details' do
      post '/finish_ride', { latitude: 34.0522, longitude: -118.2437, ride_id: ride.id, 'Authorization' => driver_token }
      expect(last_response.status).to eq(201)
      response = JSON.parse(last_response.body)

      finished_ride = Ride.find(id: ride.id)
      expect(finished_ride.status).to eq('finished')
      expect(finished_ride.latitude_finish).to eq(34.0522)
      expect(finished_ride.longitude_finish).to eq(-118.2437)
      # expect(finished_ride.distance).to be_within(0.1).of(calculate_distance(40.7128, -74.0060, 34.0522, -118.2437))
      expect(finished_ride.elapsed_time).not_to be_nil
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
      post '/create_payment_source', { 'Authorization' => "Bearer #{rider_token}"  }
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to include('token' => 'card_token')
    end

    it 'creates a new payment source successfully' do
      expect {
        post '/create_payment_source', { 'Authorization' => "Bearer #{rider_token}" }
      }.to change { PaymentSource.count }.by(1)
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to include('token' => 'card_token')
    end

    context 'when the user is not a rider' do
      it 'returns an error' do
        post '/create_payment_source', {'Authorization' => "Bearer #{driver_token}" }
        expect(last_response.status).to eq(403)
        expect(JSON.parse(last_response.body)).to include('error' => 'Not allowed')
      end
    end
    

    context 'when the token is invalid' do
      let(:invalid_token) { 'invalid_token' }

      it 'returns an authentication error' do
        post '/create_payment_source', { 'Authorization' => "Bearer #{invalid_token}" }
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end

  # auth
  describe 'POST /users/login' do
    context 'when are valid credentials' do
      let(:params) { { email: 'alice@example.com', pass: 'password1' } }

      it 'return a token' do
        post '/users/login', params
        expect(last_response.status).to eq(201)
        response_body = JSON.parse(last_response.body)
        expect(response_body).to have_key('token')
        expect(response_body).to have_key('user_id')
      end
    end

    context 'when are invalid credentials' do
      let(:params) { { email: 'alice@example.com', pass: 'wrongpassword' } }

      it 'return an authentication error' do
        post '/users/login', params
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end

end
