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

  def haversine(lat1, lon1, lat2, lon2)
    # Convertir grados a radianes
    rad_per_deg = Math::PI / 180
    rkm = 6371 # Radio de la Tierra en kilómetros
  
    # Convertir las coordenadas de grados a radianes
    lat1_rad = lat1 * rad_per_deg
    lon1_rad = lon1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg
    lon2_rad = lon2 * rad_per_deg
  
    # Diferencias de latitud y longitud
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
  
    # Fórmula de Haversine
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  
    # Distancia en kilómetros
    rkm * c
    # Ejemplo de uso
    # lat1 = 40.7128 # Latitud de Nueva York
    # lon1 = -74.0060 # Longitud de Nueva York
    # lat2 = 34.0522 # Latitud de Los Ángeles
    # lon2 = -118.2437 # Longitud de Los Ángeles
  end

  def current_user(token)
    decoded_token = decode_token(token)
    user = USERS.find { |u| u[:user_id] == decoded_token['user_id'] }
    return user if user
  
    error!('Unauthorized', 401)
  end
end
