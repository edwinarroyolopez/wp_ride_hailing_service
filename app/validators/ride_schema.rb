require 'dry-validation'

module Validators
  RideRequestSchema = Dry::Schema.Params do
    required(:latitude).filled(:float)
    required(:longitude).filled(:float)
  end
  RideFinishSchema = Dry::Schema.Params do
    required(:latitude).filled(:float)
    required(:longitude).filled(:float)
  end
end