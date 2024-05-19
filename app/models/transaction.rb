class Transaction < Sequel::Model
    many_to_one :ride
  
    def validate
      super
      validates_presence [:ride_id, :cost, :distance, :status, :id_external_transaction]
    end
  end