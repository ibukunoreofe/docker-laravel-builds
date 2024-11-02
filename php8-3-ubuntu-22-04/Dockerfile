FROM ubuntu:22.04

LABEL maintainer="Taylor Otwell"

ARG WWWGROUP=1000
ARG NODE_VERSION=20
ARG MYSQL_CLIENT="mysql-client"
ARG POSTGRES_VERSION=17

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV SUPERVISOR_PHP_COMMAND="/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan serve --host=0.0.0.0 --port=80"
ENV SUPERVISOR_PHP_USER="sail"
ENV SUPERVISOR_PHP_USER_ID=1337

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add for scheduling
RUN apt-get update \
    && apt-get install -y htop cron

RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom && \
    echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99custom && \
    echo "Acquire::BrokenProxy    true;" >> /etc/apt/apt.conf.d/99custom

RUN apt-get update && apt-get upgrade -y \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 dnsutils librsvg2-bin fswatch ffmpeg nano  \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.3-cli php8.3-dev \
       php8.3-pgsql php8.3-sqlite3 php8.3-gd \
       php8.3-curl \
       php8.3-imap php8.3-mysql php8.3-mbstring \
       php8.3-xml php8.3-zip php8.3-bcmath php8.3-soap \
       php8.3-intl php8.3-readline \
       php8.3-ldap \
       php8.3-msgpack php8.3-igbinary php8.3-redis \
       php8.3-memcached php8.3-pcov php8.3-imagick php8.3-xdebug php8.3-swoole \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g pnpm \
    && npm install -g bun \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/keyrings/pgdg.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y yarn \
    && apt-get install -y $MYSQL_CLIENT \
    && apt-get install -y postgresql-client-$POSTGRES_VERSION \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.3

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u $SUPERVISOR_PHP_USER_ID sail

COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini /etc/php/8.3/cli/conf.d/99-sail.ini
RUN chmod +x /usr/local/bin/start-container

# MS SQL SERVER SUPPORTS
RUN apt-get update \
    && apt-get install -y unixodbc-dev

RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN echo "extension=sqlsrv.so" > /etc/php/8.3/mods-available/sqlsrv.ini
RUN echo "extension=pdo_sqlsrv.so" > /etc/php/8.3/mods-available/pdo_sqlsrv.ini

RUN ln -s /etc/php/8.3/mods-available/sqlsrv.ini /etc/php/8.3/cli/conf.d/20-sqlsrv.ini
RUN ln -s /etc/php/8.3/mods-available/pdo_sqlsrv.ini /etc/php/8.3/cli/conf.d/20-pdo_sqlsrv.ini

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Change this line if you change the ubuntu version
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN ACCEPT_EULA=Y apt-get -y install mssql-tools

# Add certificate for curl issues
COPY cacert.pem /etc/php/8.3/cacert.pem

# SCHEDULING
# -------------------------------------
# Add cronjob, you can use below if you want log
RUN (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1") | crontab -

# Schedulers
RUN apt-get install -y \
    cron htop gosu

# Networking Tools
RUN apt-get install -y \
    iproute2 iputils-ping netcat net-tools lsof

# Editors
RUN apt-get install -y \
    nano

# Utilities
RUN apt-get install -y \
    jq

# Install FPM
RUN apt-get update && apt-get install -y php8.3-fpm

# Install nginx
RUN apt-get update \
    && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y nginx-extras

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf

RUN usermod -a -G www-data sail

# Update PHP-FPM pool configuration to optimize worker settings
RUN sed -i 's/^listen = .*/listen = \/run\/php\/php8.3-fpm.sock/' /etc/php/8.3/fpm/pool.d/www.conf
RUN echo "listen.owner = www-data" >> /etc/php/8.3/fpm/pool.d/www.conf
RUN echo "listen.group = www-data" >> /etc/php/8.3/fpm/pool.d/www.conf
RUN echo "listen.mode = 0660" >> /etc/php/8.3/fpm/pool.d/www.conf

# Update PHP-FPM worker settings
RUN sed -i 's/^pm.max_children = .*/pm.max_children = 20/' /etc/php/8.3/fpm/pool.d/www.conf
RUN sed -i 's/^pm.start_servers = .*/pm.start_servers = 5/' /etc/php/8.3/fpm/pool.d/www.conf
RUN sed -i 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 3/' /etc/php/8.3/fpm/pool.d/www.conf
RUN sed -i 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 10/' /etc/php/8.3/fpm/pool.d/www.conf

# Update PHP-FPM error log location
RUN sed -i 's|^error_log = .*|error_log = /var/www/html/storage/logs/php8.3-fpm_error.log|' /etc/php/8.3/fpm/php-fpm.conf

# Link SQLSRV extension for PHP-FPM
RUN ln -s /etc/php/8.3/mods-available/sqlsrv.ini /etc/php/8.3/fpm/conf.d/20-sqlsrv.ini
RUN ln -s /etc/php/8.3/mods-available/pdo_sqlsrv.ini /etc/php/8.3/fpm/conf.d/20-pdo_sqlsrv.ini

# Create the start_laravel_app script
COPY start_laravel_app.sh /usr/local/bin/start_laravel_app

# Make the script executable
RUN chmod +x /usr/local/bin/start_laravel_app

# Expose both nginx (80) and Laravel application (8000) ports
EXPOSE 80 8000

ENTRYPOINT ["start-container"]
