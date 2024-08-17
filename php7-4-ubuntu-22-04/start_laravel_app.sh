#!/bin/bash

# Check if APP_ENV is set to "production"
if [ "$APP_ENV" = "production" ]; then
    # If production, run supervisord as the main process
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
else
    # If not production, run the queue worker in the background
    php /var/www/html/artisan queue:work --sleep=3 --tries=3 --queue=default,emails &

    # Run the Laravel development server as the main process
    /usr/bin/php -d variables_order=EGPCS /var/www/html/artisan serve --host=0.0.0.0 --port=80
fi
