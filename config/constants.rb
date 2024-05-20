module Constants
    EXTERNAL_API_URL = ENV['EXTERNAL_API_URL'] || 'https://default.api.url'
    PUB_GATEWAY_KEY = ENV['PUB_GATEWAY_KEY'] || 'default_pub_gateway_key'
    TOKEN_CARD = ENV['TOKEN_CARD'] || 'default_pub_gateway_key'
    DEFAULT_PHONE_NUMBER = '3107654321'
    BASE_COST = 3500
    COST_PER_KM = 1000
    COST_PER_MINUTE = 200
end