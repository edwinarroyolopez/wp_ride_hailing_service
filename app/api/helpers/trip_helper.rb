require 'logger'
require_relative '../../models/payment_source'

module RideHelper
  logger = Logger.new(STDOUT)

  def calculate_distance(lat1, lon1, lat2, lon2)
    # Convert degrees to radians
    rad_per_deg = Math::PI / 180
    rkm = 6371 # Earth's radius in kilometers
  
    # Convert coordinates from degrees to radians
    lat1_rad = lat1 * rad_per_deg
    lon1_rad = lon1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg
    lon2_rad = lon2 * rad_per_deg
  
    # Latitude and longitude differences
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
  
    # Haversine formula
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  
    # kms distance
    rkm * c
    # Example
    # lat1 = 40.7128 # Latitude New York
    # lon1 = -74.0060 # Longitude New York
    # lat2 = 34.0522 # Latitud de Los Ángeles
    # lon2 = -118.2437 # Longitud de Los Ángeles
  end

  def calculate_time_elapsed(timeStart)
    timeEnd = Time.now
    difference_in_seconds = timeEnd - timeStart
    timeElapsed = difference_in_seconds / 60
    timeElapsed = timeElapsed.round
  end

  def calculate_cost(distance,timeElapsed)
    amountKm = distance*1000
    amountTime = timeElapsed*200
    amount = amountKm + amountTime + 3500
    amount = amount.round
  end

  def request_ride(params,user)
    # Verify that the payment source exists before create the new ride
    if !PaymentSource.find(rider_id: user[:user_id])
      error!('Not allowed, Payment source dond exists for this rider, you need create a payment source first', 403)
    end

    # additional validation
    # oldRide = Ride.find(rider_id: user[:user_id], status: 'requested')
    # if oldRide
    #   error!("Cannot created a new ride because you already an open ride: #{oldRide.id}", 403)
    # end

    drivers = USERS.select { |u| u[:user_type] == 'driver' }
    assigned_driver = drivers.sample

    ride = Ride.create(
      rider_id: user[:user_id],
      driver_id: assigned_driver[:user_id],
      latitude_start: params[:latitude],
      longitude_start: params[:longitude],
      status: 'requested'
    )
    
    { message: 'Ride requested successfully', status: 'requested', ride_id:ride.id, driver_id:ride.driver_id }
  end

  def validations_ride(ride_id, user_id)
    ride = Ride.find(id: ride_id)
    if !ride
      error!("Not found a ride whith this ride_id: #{ride_id}", 404)
    end

    if ride.status != 'requested'
      error!("Not allowed, the ride was finished before", 403)
    end
    # validate that the driver is same on ride
    if ride.driver_id != user_id
      error!("Not allowed, you are not the driver of this ride", 403)
    end
    return ride
  end

  def get_payment_source(rider_id)
    payment_source = PaymentSource.find(rider_id: rider_id)
    # TOKEN PAYMENT SOURCE TO MAKE TRANSTACTION
    paymentToken = payment_source.respond_to?(:token)? payment_source.token : ENV['TOKEN_CARD'] 
    return paymentToken
  end

end