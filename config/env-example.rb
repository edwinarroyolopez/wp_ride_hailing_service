# Rename this file by env.rb and configure the vars necessary for run
ENV['DATABASE_URL_DEV'] = 'postgres://username:password@localhost:5432/database_dev'

ENV['RACK_ENV'] = 'test'

ENV['EXTERNAL_API_URL'] = 'https://api.example.com'

ENV['PUB_GATEWAY_KEY'] = 'YOUR_PUB_GATEWAY_KEY'
ENV['PRIV_GATEWAY_KEY'] = 'YOUR_PRIV_GATEWAY_KEY'

ENV['TOKEN_CARD'] = 'YOUR_TOKEN_CARD'

ENV['SECRET_KEY'] = 'YOUR_SECRET_KEY'
