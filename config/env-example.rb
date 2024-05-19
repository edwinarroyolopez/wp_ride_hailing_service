# Rename this file by env.rb and configure the vars necessary for run
require 'dotenv/load' #  dotenv

ENV['RACK_ENV'] = 'test'

ENV['EXTERNAL_API_URL'] = 'https://api.example.com'

ENV['PUB_GATEWAY_KEY'] = 'YOUR_PUB_GATEWAY_KEY'
ENV['PRIV_GATEWAY_KEY'] = 'YOUR_PRIV_GATEWAY_KEY'

ENV['TOKEN_CARD'] = 'YOUR_TOKEN_CARD'
ENV['SECRET_KEY'] = 'YOUR_SECRET_KEY'

# database
ENV['DB_HOST'] = 'localhost'
ENV['DB_PORT'] = '5432'
ENV['DB_NAME'] = 'postgres'
ENV['DB_USER'] = 'YOUR_USERNAME'
ENV['DB_PASSWORD'] = 'YOUR_PASSWORD'