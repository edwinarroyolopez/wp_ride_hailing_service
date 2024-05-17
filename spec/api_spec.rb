require 'spec_helper'

describe TransporteAPI do
  describe 'POST /trip_cost' do
    context 'when the user is a driver' do
      let(:params) { { origin: 'A', destiny: 'B', distance: 10, user_type: 'driver' } }

      it 'calculate the cost of the trip' do
        post '/trip_cost', params
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to have_key('cost')
      end
    end

    context 'when the user is a passenger' do
      let(:params) { { origin: 'A', destiny: 'B', distance: 10, user_type: 'rider' } }

      it 'returns an error' do
        post '/trip_cost', params
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to have_key('error')
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

    context 'cuando se proporcionan parámetros válidos' do
      let(:params) { { userId: '1', user_type: 'driver' } }

      it 'crea una nueva fuente de pago' do
        post '/create_payment_source', params
        expect(last_response.status).to eq(201)
        response_body = JSON.parse(last_response.body)
        expect(response_body['success']).to be true
        expect(response_body['id']).to eq('card_123')
      end
    end
  end
  
end
