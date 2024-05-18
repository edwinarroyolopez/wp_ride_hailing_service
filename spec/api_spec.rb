require 'spec_helper'
require 'jwt'

describe TransporteAPI do
  logger = Logger.new(STDOUT)

  SECRET_KEY = ENV['SECRET_KEY'] 


  def encode_token(payload)
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  # describe 'POST /trip_cost' do
  #   context 'when the user is a driver' do
  #     let(:params) { { origin: 'A', destiny: 'B', distance: 10, user_type: 'driver' } }

  #     it 'calculate the cost of the trip' do
  #       post '/trip_cost', params
  #       expect(last_response.status).to eq(201)
  #       expect(JSON.parse(last_response.body)).to have_key('cost')
  #     end
  #   end

  #   context 'when the user is a passenger' do
  #     let(:params) { { origin: 'A', destiny: 'B', distance: 10, user_type: 'rider' } }

  #     it 'returns an error' do
  #       post '/trip_cost', params
  #       expect(last_response.status).to eq(201)
  #       expect(JSON.parse(last_response.body)).to have_key('error')
  #     end
  #   end
  # end

  # describe 'GET /users' do
  #   it 'devuelve todos los usuarios' do
  #     get '/users'
  #     expect(last_response.status).to eq(200)
  #     users = JSON.parse(last_response.body)
  #     expect(users.size).to eq(6)
  #     expect(users).to include(
  #       { 'user_id' => 1, 'name' => 'Alice', 'phone' => '123-456-7890', 'user_type' => 'rider', 'email' => 'alice@example.com' },
  #       { 'user_id' => 4, 'name' => 'Dave', 'phone' => '456-789-0123', 'user_type' => 'driver', 'email' => 'dave@example.com' }
  #     )
  #   end
  # end

  describe 'POST /users/login' do
    context 'con credenciales válidas' do
      let(:params) { { email: 'alice@example.com', pass: 'password1' } }

      it 'devuelve un token' do
        post '/users/login', params
        expect(last_response.status).to eq(201)
        response_body = JSON.parse(last_response.body)
        expect(response_body).to have_key('token')
        expect(response_body).to have_key('user_id')
      end
    end

    context 'con credenciales inválidas' do
      let(:params) { { email: 'alice@example.com', pass: 'wrongpassword' } }

      it 'devuelve un error de autenticación' do
        post '/users/login', params
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /create_payment_source' do
    let(:base_api_url) { 'https://sandbox.wompi.co/v1' }
    let(:url) { "#{base_api_url}/tokens/cards" }
    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer pub_test_rrnLHOmdCTLw1kquFbHgxQjKyYSndKhu'
      }
    end
    let(:body) do
      {
        number: "4242424242424242",
        cvc: "789",
        exp_month: "12",
        exp_year: "29",
        card_holder: "Pedro Pérez"
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: body, headers: headers)
        .to_return(status: 200, body: { success: true, id: 'card_123' }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    context 'cuando se proporcionan parámetros válidos sin token válido' do
      let(:params) { { userId: '1', user_type: 'driver' } }

      it 'crea una nueva fuente de pago' do
        post '/create_payment_source', params
        expect(last_response.status).to eq(401)
      end
    end

    context 'cuando se proporcionan parámetros válidos y un token válido' do
      let(:valid_rider_token) { encode_token({ user_id: 1 }) }
      let(:params) { { userId: '1', user_type: 'driver', 'Authorization' => "Bearer #{valid_rider_token}" } }
      it 'crea una nueva fuente de pago' do
        post '/create_payment_source', params
        expect(last_response.status).to eq(201)
        response_body = JSON.parse(last_response.body)
        expect(response_body['success']).to be true
        expect(response_body['id']).to eq('card_123')
      end
      
    end

    context 'cuando el token no es válido' do
      let(:params) { { userId: '1', user_type: 'driver' } }
      let(:invalid_token) { 'invalid_token' }

      it 'devuelve un error de autenticación' do
        post '/create_payment_source', params, { 'Authorization' => "Bearer #{invalid_token}" }
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end

  end

  describe 'POST /request_ride' do
    context 'cuando el token pertenece a un rider' do
      let(:valid_rider_token) { encode_token({ user_id: 1 }) }
      it 'permite la solicitud de un viaje' do
        header 'Authorization', "Bearer #{valid_rider_token}"
        post '/request_ride',  { latitude: 123.456, longitude: -78.910, 'Authorization' => "Bearer #{valid_rider_token}"}
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to eq({ 'message' => 'Ride requested successfully' })
      end
    end
  
    context 'cuando el token pertenece a un conductor' do
      let(:valid_driver_token) { encode_token({ user_id: 4 }) }
      it 'no permite la solicitud de un viaje y devuelve un error de "no permitido"' do
        header 'Authorization', "Bearer #{valid_driver_token}"
        post '/request_ride', { latitude: 123.456, longitude: -78.910, 'Authorization' => "Bearer #{valid_driver_token}"}
        expect(last_response.status).to eq(403)
        expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Not allowed' })
      end
    end
  
    context 'cuando el token no es válido' do
      let(:invalid_token) { 'invalid_token' }
      it 'devuelve un error de autenticación' do
        header 'Authorization', "Bearer #{invalid_token}"
        post '/request_ride', latitude: 123.456, longitude: -78.910
        expect(last_response.status).to eq(401)
        expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end

  describe 'POST /finish_ride' do
    context 'cuando el token pertenece a un driver' do
      let(:valid_driver_token) { encode_token({ user_id: 4 }) }
  
      it 'permite finalizar un viaje' do
        header 'Authorization', "Bearer #{valid_driver_token}"
        post '/finish_ride', { latitude: 123.456, longitude: -78.910, ride_id: 1, 'Authorization' => "Bearer #{valid_driver_token}"}
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to eq({ 'message' => 'Ride finished successfully' })
      end
    end
  
    context 'cuando el token pertenece a un rider' do
      let(:valid_rider_token) { encode_token({ user_id: 1 }) }
  
      it 'no permite finalizar un viaje y devuelve un error de "no permitido"' do
        header 'Authorization', "Bearer #{valid_rider_token}"
        post '/finish_ride', { latitude: 123.456, longitude: -78.910, ride_id: 1, 'Authorization' => "Bearer #{valid_rider_token}" }
        expect(last_response.status).to eq(403)
        expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Not allowed' })
      end
    end
  
    context 'cuando el token no es válido' do
      let(:invalid_token) { 'invalid_token' }
  
      it 'devuelve un error de autenticación' do
        header 'Authorization', "Bearer #{invalid_token}"
        post '/finish_ride', latitude: 123.456, longitude: -78.910, ride_id: 1
        expect(last_response.status).to eq(401)
        expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end
  
end
