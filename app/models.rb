class DummyUser
    def driver?
      false
    end
  end
  
  class Ride
    def self.calculate_cost(distance)
        raise ArgumentError, 'La distancia no puede ser negativa' if distance.negative?
        distance * 10 # $10 por kilómetro
    end
  end
  