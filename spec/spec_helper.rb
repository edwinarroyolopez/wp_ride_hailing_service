# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require 'webmock/rspec'
require_relative '../config/database'
require_relative '../app/api/api'

require_relative '../app/api/resources/payments'
require_relative '../config/env'
require_relative '../app/models/payment_source'

module RSpecMixin
  include Rack::Test::Methods
  def app() TransporteAPI end
end

RSpec.configure do |config|
  config.include RSpecMixin
  WebMock.disable_net_connect!(allow_localhost: true)
  config.before(:each) do
    DB[:payment_sources].truncate
  end
end

DB = Sequel.connect(
  adapter: 'postgres',
  user: ENV['DB_USER'],
  password: ENV['DB_PASSWORD'],
  host: ENV['DB_HOST'],
  port: ENV['DB_PORT'],
  database: ENV['DB_NAME']
)
