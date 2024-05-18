require 'logger'
require 'sequel'
require 'dotenv/load'
# Requerir modelos después de establecer la conexión
# require_relative '../app/models/user'
# require_relative '../app/models/ride'

logger = Logger.new(STDOUT)
logger.info("database log")


# postgres://wp_user:wp_user@localhost:5432/postgres


# adapter: 'postgres',
# user: ENV['DB_USER'],
# password: ENV['DB_PASSWORD'],
# host: ENV['DB_HOST'],
# port: ENV['DB_PORT'],
# database: "#{ENV['DB_NAME']}_test"

# DB = Sequel.connect(
#   adapter: 'postgres',
#   user: ENV['DB_USER'],
#   password: ENV['DB_PASSWORD'],
#   host: ENV['DB_HOST'],
#   port: ENV['DB_PORT'],
#   database: "postgres"

# )


DB = Sequel.connect(
  adapter: 'postgres',
  user: 'wp_user',
  password: 'wp_user',
  host: 'localhost',
  port: '5432',
  database: 'postgres'
)

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers
Sequel::Model.db = DB