#https://hub.docker.com/r/vulnerables/web-dvwa/dockerfile

FROM debian:9.2

ARG ROOTPW
ARG APPPW

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debconf-utils && \
    echo mariadb-server mysql-server/root_password password $ROOTPW | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password $ROOTPW | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
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
COPY DVWA/php.ini /etc/php/7.0/apache2/php.ini
COPY DVWA /var/www/html

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html


#workaround - ARG and ENV are not expanded to values when in single quotes
RUN echo -n "CREATE USER app@localhost IDENTIFIED BY '" > /tmp/sqlquery && echo -n "$APPPW" >> /tmp/sqlquery && \
echo "';CREATE DATABASE dvwa;GRANT ALL privileges ON dvwa.* TO 'app'@localhost;" >> /tmp/sqlquery

RUN service mysql start && \
    sleep 10 && \
    mysql -uroot -p${ROOTPW} < /tmp/sqlquery && rm /tmp/sqlquery

EXPOSE 80

RUN sed -i'' "s/APP_PW/${APPPW}/" /var/www/html/config/config.inc.php
COPY main.sh /
RUN chmod o+x /main.sh
ENTRYPOINT ["/main.sh"]