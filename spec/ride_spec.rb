require 'spec_helper'
require_relative '../config/database'
require_relative '../app/models/ride'

RSpec.describe Ride, type: :model do
  before(:each) do
    Ride.dataset.truncate
  end

  let(:valid_ride) do
    Ride.new(
      rider_id: 1,
      driver_id: 2,
      latitude_start: 10.0,
      longitude_start: 20.0,
      status: 'requested'
    )
  end

  it 'is valid with valid attributes' do
    expect(valid_ride).to be_valid
  end

  it 'is not valid without a rider_id' do
    valid_ride.rider_id = nil
    expect(valid_ride).not_to be_valid
  end

  it 'is not valid without a driver_id' do
    valid_ride.driver_id = nil
    expect(valid_ride).not_to be_valid
  end

  it 'is not valid without a latitude_start' do
    valid_ride.latitude_start = nil
    expect(valid_ride).not_to be_valid
  end

  it 'is not valid without a longitude_start' do
    valid_ride.longitude_start = nil
    expect(valid_ride).not_to be_valid
  end

  it 'is not valid without a status' do
    valid_ride.status = nil
    expect(valid_ride).not_to be_valid
  end

  it 'sets timestamps on create' do
    ride = Ride.create(
      rider_id: 1,
      driver_id: 2,
      latitude_start: 10.0,
      longitude_start: 20.0,
      status: 'requested'
    )
    expect(ride.created_at).not_to be_nil
    expect(ride.updated_at).not_to be_nil
  end
end