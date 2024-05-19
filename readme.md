# API: Ride hailing services


## Tabla de Contenidos

1. [Install](#install)
2. [Start](#start)
3. [Test](#test)
4. [License](#license)

## Folder Structure
```
├── app/
│   ├── api/
│   │   ├── helpers/
│   │   │   ├── authentication_helper.rb
│   │   │   ├── payment_helper.rb
│   │   │   └── ride_helper.rb
│   │   ├── resources/
│   │   │   ├── payments.rb
│   │   │   ├── trips.rb
│   │   │   └── users.rb
│   │   └── validators/
│   │       └── ride_schema.rb
│   ├── models/
│   │   └── ride.rb
├── config/
│   ├── environment.rb
│   └── initializers/
│       └── setup.rb
├── db/
│   ├── migrate/
│   └── schema.rb
├── spec/
│   ├── api/
│   │   ├── helpers/
│   │   │   ├── authentication_helper_spec.rb
│   │   │   ├── payment_helper_spec.rb
│   │   │   └── ride_helper_spec.rb
│   │   ├── resources/
│   │   │   ├── payments_spec.rb
│   │   │   ├── trips_spec.rb
│   │   │   └── users_spec.rb
│   ├── models/
│   │   └── ride_spec.rb
│   └── spec_helper.rb
├── config.ru
├── Gemfile
├── Rakefile
└── readme.md
```

## Install

To install run this command ```bundle install```

## Start 

To run  this command ```rackup -p 3000```

# Migrations
To run migrations this command ```sequel -m db/migrations postgres://DB_USER:DB_PASSWORD@DB_HOST/DB_NAME```
OR ```rake db:migrate```

## Test 

To install run this command ```rspec```

To see covarage ```open covarage/index.html```

**Coverage Status:** *96.23% covered at 1.17 hits/line* 

https://coveralls.io/github/edwinarroyolopez/wp_ride_hailing_service?branch=master

## License

*Technical test - public domain*

![Logo](https://code.dblock.org/images/posts/2015/2015-08-04-ruby-grape/grape.png)


TODO:
    🔲 Create postman collection
    🔲 Create documentation 
    🔲 Generate transaction with payment method with external api
    🔲 Keep unit tests
    🔲 Insert transaction with payment method
    
DONE:
    ✅ Create payment method

