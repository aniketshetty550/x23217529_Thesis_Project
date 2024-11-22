# Use a more recent Debian base image
FROM ubuntu:latest



LABEL maintainer "opsxcq@strm.sh"

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debconf-utils && \
    echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    mariadb-server \
    php \
    php-mysql \
    php-pgsql \
    php-pear \
    php-gd \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY php.ini /etc/php5/apache2/php.ini
COPY dvwa /var/www/html

COPY config.inc.php /var/www/html/config/

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html

RUN /usr/bin/mysqld_safe & \
    sleep 5 && \
    until mysqladmin ping -uroot -pvulnerables; do \
        echo "Waiting for MySQL to be ready..."; \
        sleep 2; \
    done && \
    mysql -uroot -pvulnerables -e "CREATE USER 'app'@'localhost' IDENTIFIED BY 'vulnerables'; CREATE DATABASE dvwa; GRANT ALL PRIVILEGES ON dvwa.* TO 'app'@'localhost';" && \
    kill $(pgrep mysqld)

EXPOSE 8080 

COPY main.sh /
ENTRYPOINT ["/main.sh"]
