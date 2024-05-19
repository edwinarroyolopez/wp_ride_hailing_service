require 'logger'
require 'sequel'
require 'dotenv/load'
require_relative './env' # rename env.example.rb ro env.rb

logger = Logger.new(STDOUT)
logger.info("Connecting to database...")

DB = Sequel.connect(
  adapter: 'postgres',
  user: ENV['DB_USER'],
  password: ENV['DB_PASSWORD'],
  host: ENV['DB_HOST'],
  port: ENV['DB_PORT'],
  database: ENV['DB_NAME']
)

# hardcode my local database
# DB = Sequel.connect(
#   adapter: 'postgres',
#   user: 'wp_user',
#   password: 'wp_user',
#   host: 'localhost',
#   port: '5432',
#   database: 'postgres'
# )

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers
Sequel::Model.db = DB