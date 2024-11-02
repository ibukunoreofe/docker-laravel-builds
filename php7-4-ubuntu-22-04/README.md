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
COPY php.ini /etc/php/7.4/cli/conf.d/99-sail.ini
```



### Apache Configuration:

There are several commented-out lines in the Dockerfile related to Apache configuration files, such as:
- #COPY apache2.conf /etc/apache2/apache2.conf
- #COPY php-apache2/php.ini /etc/php/7.4/apache2/php.ini

This indicates that the Dockerfile may be prepared for an environment where Apache is used, and these configuration files would be placed in the Apache directories.

Apache is installed but not running




### Building

```shell
docker build -t ibukunoreofe/php7-4-ubuntu-22-04:latest .
docker push ibukunoreofe/php7-4-ubuntu-22-04:latest
```



### Check Listening Ports

```shell
sudo ss -tuln
sudo netstat -tuln
sudo lsof -i -P -n | grep LISTEN
```



### Notes
The exec command in a shell script replaces the current shell process with the command that follows exec. This means that instead of spawning a new process, the shell process itself becomes the process specified by the command following exec. This has some important implications:

Purpose of exec in the Script
Avoiding an Extra Shell Process:

When you run a command in a script without exec, a new child process is created to run that command. The shell script process remains active, waiting for that child process to complete. By using exec, the shell process is replaced entirely by the command, avoiding an extra layer of process management.
Proper Signal Handling:

In a Docker container or any long-running process, proper signal handling is critical. For example, if the container receives a signal to stop (SIGTERM), you want that signal to go directly to the main process (e.g., supervisord). By using exec, you ensure that the process you want to manage is the direct child of the container's init process, and it receives signals directly, allowing for clean shutdowns or restarts.
Efficiency:

Since exec replaces the current shell with the specified command, there's no need to maintain an additional shell process. This can be more efficient, especially in environments like Docker where resource usage and process management are critical.