#!/bin/bash

composer install

php artisan migrate --force

# Clear all previous cache as it may affect if some cache are still lock
# Using withoutOverlapping in Kernel Schedule
php artisan cache:clear

# Check if APP_ENV is set to "production"
start_laravel_app