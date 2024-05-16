# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require_relative '../app/api'

module RSpecMixin
  include Rack::Test::Methods
  def app() TransporteAPI end
end

RSpec.configure { |c| c.include RSpecMixin }
