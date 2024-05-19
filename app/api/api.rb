require 'grape'
require 'logger'
require 'securerandom'
require_relative '../../config/env'
require_relative 'helpers/authentication_helper'
require_relative 'helpers/ride_helper'

require_relative 'resources/users'
require_relative 'resources/payments'
require_relative 'resources/trips'

class TransporteAPI < Grape::API
  format :json
  logger = Logger.new(STDOUT)

  helpers AuthenticationHelper
  helpers RideHelper

  mount Resources::Users
  mount Resources::Payments
  mount Resources::Trips
end