class Ride
    def self.calculate_cost(distance)
      raise ArgumentError, 'Distance must be positive' if distance < 0
      distance * 10 # Suponiendo que el costo es $10 por km
    end
  end