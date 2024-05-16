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
end
