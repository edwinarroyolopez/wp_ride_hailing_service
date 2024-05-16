# spec/ride_spec.rb
require 'spec_helper'
require_relative '../app/models'

RSpec.describe Ride do
  describe '.calculate_cost' do
    context 'when a valid distance is provided' do
      it 'correctly calculate the cost of the trip' do
        expect(Ride.calculate_cost(5)).to eq(50) # 5 km * $10/km
      end
    end

    context 'when a negative distance is provided' do
      it 'throws an error' do
        expect { Ride.calculate_cost(-5) }.to raise_error(ArgumentError)
      end
    end

    context 'when zero distance is provided' do
      it 'return zero' do
        expect(Ride.calculate_cost(0)).to eq(0)
      end
    end
  end
end
