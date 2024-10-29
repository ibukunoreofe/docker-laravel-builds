FROM ubuntu:22.04

LABEL maintainer="Taylor Otwell"

ARG WWWGROUP=1000
ARG NODE_VERSION=18
ARG POSTGRES_VERSION=14

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add for scheduling
RUN apt-get update \
    && apt-get install -y htop cron

RUN apt-get update \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && echo "keyserver hkp://keyserver.ubuntu.com:80" >> ~/.gnupg/dirmngr.conf \
    && gpg --recv-key 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c \
    && gpg --export 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c > /usr/share/keyrings/ppa_ondrej_php.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.1-cli php8.1-dev \
       php8.1-pgsql php8.1-sqlite3 php8.1-gd \
       php8.1-curl \
       php8.1-imap php8.1-mysql php8.1-mbstring \
       php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
       php8.1-intl php8.1-readline \
       php8.1-ldap \
       php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
       php8.1-memcached php8.1-pcov php8.1-xdebug \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/pgdg.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y yarn \
    && apt-get install -y mysql-client \
    && apt-get install -y postgresql-client-$POSTGRES_VERSION \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.1

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini /etc/php/8.1/cli/conf.d/99-sail.ini
RUN chmod +x /usr/local/bin/start-container

# MS SQL SERVER SUPPORTS
RUN apt-get update \
    && apt-get install -y unixodbc-dev

RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN echo "extension=sqlsrv.so" > /etc/php/8.1/mods-available/sqlsrv.ini
RUN echo "extension=pdo_sqlsrv.so" > /etc/php/8.1/mods-available/pdo_sqlsrv.ini

RUN ln -s /etc/php/8.1/mods-available/sqlsrv.ini /etc/php/8.1/cli/conf.d/20-sqlsrv.ini
RUN ln -s /etc/php/8.1/mods-available/pdo_sqlsrv.ini /etc/php/8.1/cli/conf.d/20-pdo_sqlsrv.ini
RUN #ln -s /etc/php/8.1/mods-available/sqlsrv.ini /etc/php/8.1/apache2/conf.d/20-sqlsrv.ini
RUN #ln -s /etc/php/8.1/mods-available/pdo_sqlsrv.ini /etc/php/8.1/apache2/conf.d/20-pdo_sqlsrv.ini

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Change this line if you change the ubuntu version
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN ACCEPT_EULA=Y apt-get -y install mssql-tools

# Add certificate for curl issues
COPY cacert.pem /etc/php/8.1/cacert.pem

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


# Create the start_laravel_app script
COPY start_laravel_app.sh /usr/local/bin/start_laravel_app

# Make the script executable
RUN chmod +x /usr/local/bin/start_laravel_app


EXPOSE 8000

ENTRYPOINT ["start-container"]
