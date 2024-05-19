require 'jwt'
require 'bcrypt'

USERS = [
  { user_id: 1, name: 'Alice', phone: '123-456-7890', user_type: 'rider', email: 'alice@example.com', pass: BCrypt::Password.create('password1') },
  { user_id: 2, name: 'Bob', phone: '234-567-8901', user_type: 'rider', email: 'bob@example.com', pass: BCrypt::Password.create('password2') },
  { user_id: 3, name: 'Charlie', phone: '345-678-9012', user_type: 'rider', email: 'charlie@example.com', pass: BCrypt::Password.create('password3') },
  { user_id: 4, name: 'Dave', phone: '456-789-0123', user_type: 'driver', email: 'dave@example.com', pass: BCrypt::Password.create('password4') },
  { user_id: 5, name: 'Eve', phone: '567-890-1234', user_type: 'driver', email: 'eve@example.com', pass: BCrypt::Password.create('password5') },
  { user_id: 6, name: 'Frank', phone: '678-901-2345', user_type: 'driver', email: 'frank@example.com', pass: BCrypt::Password.create('password6') }
]

module AuthenticationHelper
  def find_user_by_email(email)
    USERS.find { |user| user[:email] == email }
  end

  def encode_token(payload)
    JWT.encode(payload, ENV['SECRET_KEY'], 'HS256')
  end

  def decode_token(token)
    JWT.decode(token.split(' ').last, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })[0]
  rescue
    nil
  end

  def authenticate!(token)
    decoded_token = decode_token(token)
    error!('Unauthorized', 401) unless decoded_token
  end

  def current_user(token)
    decoded_token = decode_token(token)
    user = USERS.find { |u| u[:user_id] == decoded_token['user_id'] }
    return user if user
    error!('Unauthorized', 401)
  end
  
end
