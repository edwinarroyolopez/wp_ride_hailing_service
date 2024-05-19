require 'sequel'

class PaymentSource < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  def validate
    super
    validates_presence [:rider_id, :token]
  end
end