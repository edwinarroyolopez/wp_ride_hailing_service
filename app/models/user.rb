class User < Sequel::Model
    one_to_many :rides_as_rider, class: :Ride, key: :rider_id
    one_to_many :rides_as_driver, class: :Ride, key: :driver_id
    plugin :secure_password, include_validations: false
  
    def validate
      super
      validates_presence [:name, :phone, :user_type, :email, :password_digest]
      validates_unique :email
    end
end