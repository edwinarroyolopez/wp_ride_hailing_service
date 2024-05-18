class Ride < Sequel::Model
  many_to_one :rider, class: :User, key: :rider_id
  many_to_one :driver, class: :User, key: :driver_id

  def validate
    super
    validates_presence [:rider_id, :driver_id, :latitude_start, :longitude_start, :status]
  end
end