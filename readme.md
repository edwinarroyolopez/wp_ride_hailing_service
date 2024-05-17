# API: Ride hailing services


## Tabla de Contenidos

1. [Install](#install)
2. [Start](#start)
3. [Test](#test)
4. [License](#license)

## Folder Structure
```
├── app/
│   ├── api.rb
│   └── models.rb
│
├── config/
│   ├── env.rb
│
├── spec/
│   ├── spec_helper.rb
│   ├── api_spec.rb
│   └── ride_spec.rb
│
├── config.ru
├── Gemfile
├── Gemfile.lock
├── Rakefile
└── readme.md
```

## Install

To install run this command ```bundle install```

## Start 

To run run this command ```rackup -p 3000```

## Test 

To install run this command ```rspec```

To see covarage ```open covarage/index.html```

**Coverage Status:** *96.23% covered at 1.17 hits/line* 

https://coveralls.io/github/edwinarroyolopez/wp_ride_hailing_service?branch=master

## License

*Technical test - public domain*

![Logo](https://code.dblock.org/images/posts/2015/2015-08-04-ruby-grape/grape.png)



TODO:
    🔲 Create payment method
    🔲 Create postman collection
    🔲 Create documentation 
    🔲 Generate transaction with payment method with external api
    🔲 Keep unit tests

DONE:
    ✅ Task One



tokeniza una tarjeta

POST /v1/tokens/cards

{
  "number": "4242424242424242", // Número de la tarjeta
  "cvc": "123", // Código de seguridad de la tarjeta (3 o 4 dígitos según corresponda)
  "exp_month": "08", // Mes de expiración (string de 2 dígitos)
  "exp_year": "28", // Año expresado current 2 dígitos
  "card_holder": "José Pérez" // Nombre del tarjetahabiente
}


// Riders
    create-payment-source
    request-ride
        start: latitude - longitude
        1. Assign a driver
        2. Start a ride

// Drivers
    finish-ride
        ride-id
        final: latitude - longitude

        1. Calculate the amount total
        2. Create a transaction using wp api
    
    Necesito crear los usuarios - migrarlos a la db




-- https://www.youtube.com/watch?v=1jgXrZlLrkQ&ab_channel=Wompi
https://sandbox.wompi.co/v1/merchants/pub_test_rrnLHOmdCTLw1kquFbHgxQjKyYSndKhu

https://sandbox.wompi.co/v1/merchants/pub_test_rrnLHOmdCTLw1kquFbHgxQjKyYSndKhu

RESP:
-> Save to db -- // payment source
{
  "status": "CREATED",
  "data": {
    "id": "tok_prod_1_BBb749EAB32e97a2D058Dd538a608301", // TOKEN que debe ser usado para crear la transacción
    "created_at": "2020-01-02T18:52:35.850+00:00",
    "brand": "VISA",
    "name": "VISA-4242",
    "last_four": "4242",
    "bin": "424242",
    "exp_year": "28",
    "exp_month": "08",
    "card_holder": "José Pérez",
    "expires_at": "2020-06-30T18:52:35.000Z"
  }
}



{
    "status": "CREATED",
    "data": {
        "id": "tok_test_8417_dD58ce2308498704C73973Aceb403bdC",
        "created_at": "2024-05-16T23:19:36.133+00:00",
        "brand": "VISA",
        "name": "VISA-4242",
        "last_four": "4242",
        "bin": "424242",
        "exp_year": "29",
        "exp_month": "12",
        "card_holder": "Pedro Pérez",
        "created_with_cvc": true,
        "expires_at": "2024-11-12T23:19:35.000Z",
        "validity_ends_at": "2024-05-18T23:19:36.133+00:00"
    }
}
