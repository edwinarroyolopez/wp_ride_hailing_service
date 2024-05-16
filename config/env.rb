# Configuración para entorno de desarrollo
ENV['DATABASE_URL_DEV'] = 'postgres://username:password@localhost:5432/database_dev'
ENV['API_KEY_DEV'] = 'your_api_key_dev'
ENV['RACK_ENV'] = 'test'
