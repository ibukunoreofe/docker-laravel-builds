#!/bin/bash

# This is just a sample of how you can use your own command start
# It is optional, if you don't use it at all, it will just start the supersor with the current running user
# Supervisor will still run with the ENV_SUPERVISOR_PHP_USER

composer install

php artisan migrate --force

# Clear all previous cache as it may affect if some cache are still lock
# Using withoutOverlapping in Kernel Schedule
php artisan cache:clear

# Check if APP_ENV is set to "production"
start_laravel_app