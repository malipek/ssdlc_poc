#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chown -R www-data:www-data /var/www/html/hackable/uploads/ /var/www/html/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt /var/www/html/config

echo '[+] Starting mysql...'
service mysql start

echo '[+] Starting apache'
service apache2 start

while true
do
    tail -f /var/log/apache2/*.log
    exit 0
done