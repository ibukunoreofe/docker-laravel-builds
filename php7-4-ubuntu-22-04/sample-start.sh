#!/bin/bash

php artisan migrate --force

# Your custom commands here
php artisan connection:fetch-clients

# Check if APP_ENV is set to "production"
start_laravel_app