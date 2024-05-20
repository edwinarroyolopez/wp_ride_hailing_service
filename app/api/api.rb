require 'grape'
require 'logger'
require 'securerandom'
require_relative '../../config/env'
require_relative '../../config/constants'

require_relative 'helpers/authentication_helper'
require_relative 'helpers/trip_helper'
require_relative 'helpers/payment_helper'

require_relative 'resources/users'
require_relative 'resources/payments'
require_relative 'resources/trips'

class TransporteAPI < Grape::API
  format :json
  logger = Logger.new(STDOUT)

  helpers AuthenticationHelper
  helpers RideHelper
  helpers PaymentHelper

  mount Resources::Users
  mount Resources::Payments
  mount Resources::Trips
end