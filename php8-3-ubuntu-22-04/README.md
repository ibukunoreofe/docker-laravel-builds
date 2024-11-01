# About App 
- Default Port is 80. It is running from supervisor
- Using <code>/var/www/html</code> directory
- Runs with default laravel server
- Composer install only auto runs if it is production environment

# Contains MS SQL Server Support

# Overriding default configuration
You can modify the copy of start container as needed and supervisor

```shell
# Configure your services
COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /usr/local/bin/start-container

EXPOSE 8000

ENTRYPOINT ["start-container"]
```

## You can also modify php.ini config

```shell
COPY php.ini /etc/php/8.3/cli/conf.d/99-sail.ini
```

### Building

```shell
docker build -t ibukunoreofe/php8-3-ubuntu-22-04:node20postgre17 .
docker push ibukunoreofe/php8-3-ubuntu-22-04:node20postgre17
```



### Check Listening Ports

```shell
sudo ss -tuln
sudo netstat -tuln
sudo lsof -i -P -n | grep LISTEN
```