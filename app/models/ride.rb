require 'sequel'

class Ride < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  def validate
    super
    validates_presence [:rider_id, :driver_id, :latitude_start, :longitude_start, :status]
  end
end