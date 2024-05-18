require 'sequel'
require 'dotenv/load'

DB = Sequel.connect(
  adapter: :postgres,
  host: ENV['DB_HOST'],
  database: ENV['DB_NAME'],
  user: ENV['DB_USER'],
  password: ENV['DB_PASSWORD']
)