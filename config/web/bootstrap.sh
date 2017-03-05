#!/bin/bash

if [[ $ENVIRONMENT == 'DEV' ]]; then phpenmod xdebug; fi

mkdir -p /var/www/public/app/assets
mkdir -p /var/www/public/app/protected/data
mkdir -p /var/www/public/app/protected/runtime/uploads

for dn in `cat /var/www/config/web-writable.txt`; do
  chown www-data. /var/www/$dn
done

rm /var/www/public/app/test.php

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
