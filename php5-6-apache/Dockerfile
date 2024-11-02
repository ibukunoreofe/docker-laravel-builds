# Use the official PHP 5.6 Apache image from Docker Hub
# 5 years ago
FROM php:5.6-apache

# Step 1: Update the sources list to use the archived repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# Step 2: Allow APT to use repositories without valid signatures
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Step 3: Update the package lists and upgrade the system
RUN apt-get update && apt-get upgrade -y --allow-unauthenticated

# Install basic dependencies
RUN apt-get update && apt-get install -y --allow-unauthenticated software-properties-common curl zip unzip

# Install additional libraries (batch 1)
RUN apt-get install -y --allow-unauthenticated libfreetype6-dev libjpeg62-turbo-dev libpng-dev

# Install additional libraries (batch 2)
RUN apt-get install -y --allow-unauthenticated libicu-dev libpq-dev libxml2-dev libmcrypt-dev

# Install additional libraries (batch 3)
RUN apt-get install -y --allow-unauthenticated libcurl4-openssl-dev libbz2-dev

# Configure and install PHP extensions (batch 1)
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd iconv mcrypt intl mbstring

# Configure and install PHP extensions (batch 2)
RUN docker-php-ext-install -j$(nproc) mysqli pdo_mysql pdo_pgsql soap xml zip opcache mysql

# Set timezone in php.ini
RUN echo "date.timezone = UTC" > /usr/local/etc/php/conf.d/timezone.ini

# Enable Apache mod_rewrite and mod_headers
RUN a2enmod rewrite headers

# Copy Apache configuration file
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Set the ServerName globally to suppress the warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set the working directory
WORKDIR /var/www/html

# Install wget
RUN apt-get update && apt-get install -y --allow-unauthenticated wget

# Install Composer
RUN wget https://getcomposer.org/download/latest-2.2.x/composer.phar -O /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

# Expose port 80
EXPOSE 80

# Utilities
RUN apt-get install -y \
    jq

# Schedulers
RUN apt-get install -y \
    cron htop gosu


# Networking Tools
RUN apt-get install -y \
    iproute2 iputils-ping netcat net-tools lsof

# Editors
RUN apt-get install -y \
    nano

# SUPERVISOR
RUN apt-get install -y \
    supervisor

# Start Apache in the foreground
CMD ["apache2-foreground"]
