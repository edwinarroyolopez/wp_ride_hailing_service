
module RideHelper
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
  
    # Distancia en kilómetros
    rkm * c
    # Example
    # lat1 = 40.7128 # Latitude New York
    # lon1 = -74.0060 # Longitude New York
    # lat2 = 34.0522 # Latitud de Los Ángeles
    # lon2 = -118.2437 # Longitud de Los Ángeles
  end

  def calculate_time_elapsed(timeStart, timeEnd)
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

end