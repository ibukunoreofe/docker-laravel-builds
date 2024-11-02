FROM ubuntu:22.04

ENV TZ=Europe/Paris
ARG WWWGROUP=1000
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# NEEDED FOR PHP 7.4 to work specifically on new ubuntu
RUN apt-get update \
 && apt-get install -y \
    software-properties-common

RUN add-apt-repository ppa:ondrej/php -y
# ------

RUN apt-get update \
 && apt-get install -y \
    curl php7.4 php7.4-common php7.4-mysql  \
    php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd  \
    php7.4-imagick php7.4-cli php7.4-dev php7.4-imap  \
    php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip  \
    mysql-client


# International plugin
RUN apt-get install -y \
    php7.4-intl


# Schedulers
RUN apt-get install -y \
    cron htop gosu


# Networking Tools
RUN apt-get install -y \
    iproute2 iputils-ping netcat net-tools lsof


# Editors
RUN apt-get install -y \
    nano



# COMPOSER -2.7.7 At the point of building
RUN a2enmod rewrite
RUN apt-get -y install wget
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet
RUN mv composer.phar /usr/local/bin/composer



## MS SQL SERVER SUPPORTS
RUN apt-get update \
    && apt-get install -y unixodbc-dev
#
RUN pecl install sqlsrv-5.10.1
RUN pecl install pdo_sqlsrv-5.10.1
RUN echo "extension=sqlsrv.so" > /etc/php/7.4/mods-available/sqlsrv.ini
RUN echo "extension=pdo_sqlsrv.so" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini

RUN ln -s /etc/php/7.4/mods-available/sqlsrv.ini /etc/php/7.4/cli/conf.d/20-sqlsrv.ini
RUN ln -s /etc/php/7.4/mods-available/pdo_sqlsrv.ini /etc/php/7.4/cli/conf.d/20-pdo_sqlsrv.ini
#RUN ln -s /etc/php/7.4/mods-available/sqlsrv.ini /etc/php/7.4/apache2/conf.d/20-sqlsrv.ini
#RUN ln -s /etc/php/7.4/mods-available/pdo_sqlsrv.ini /etc/php/7.4/apache2/conf.d/20-pdo_sqlsrv.ini

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Change this line if you change the ubuntu version
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN ACCEPT_EULA=Y apt-get -y install mssql-tools


# SUPERVISOR
RUN apt-get install -y \
    supervisor


# REDIS SUPPORT
RUN apt-get update \
     && apt-get install -y \
     php7.4-redis


# You can do this on your own if you wish to override or add more to the cert
#COPY apache2.conf /etc/apache2/apache2.conf
COPY cacert.pem /etc/php/7.4/cacert.pem
#COPY php-apache2/php.ini /etc/php/7.4/apache2/php.ini
#COPY php-cli/php.ini /etc/php/7.4/cli/php.ini


# NEEDED FOR PHP 7.4 to work specifically on new ubuntu
RUN apt remove php8.* -y
# ------

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php7.4

# Default Php Service configuration for laravel
COPY php.ini /etc/php/7.4/cli/conf.d/99-sail.ini
RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

# SCHEDULING
# -------------------------------------
# Add cronjob, you can use below if you want log
RUN (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1") | crontab -


# Configure your services
COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /usr/local/bin/start-container

# Create the start_laravel_app script
COPY start_laravel_app.sh /usr/local/bin/start_laravel_app

# Make the script executable
RUN chmod +x /usr/local/bin/start_laravel_app

# Utilities
RUN apt-get install -y \
    jq

EXPOSE 8000

ENTRYPOINT ["start-container"]
