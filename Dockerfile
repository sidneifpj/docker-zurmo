FROM ubuntu:xenial
MAINTAINER Yehuda Deutsch yeh@uda.co.il

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -yqq --no-install-recommends \
    apache2 \
    libapache2-mod-php7.0 \
    php7.0-mysql \
    php7.0-gd \
    php7.0-curl \
    php7.0-soap \
    php7.0-imap \
    php7.0-mcrypt \
    php7.0-cli \
    php7.0-mbstring \
    php7.0-ldap \
    php-xdebug \
    php-memcached \
    php-opcache \
    php-pear \
    supervisor \
    libsqlite3-dev \
    cron \
    mercurial \
    ca-certificates \
    memcached \
    && apt-get clean autoclean && apt-get autoremove -y

RUN a2enmod rewrite \
    && a2enmod expires \
    && phpdismod xdebug

# Code
RUN rm -rf /var/www/*
RUN cd /var/www && hg clone https://bitbucket.org/zurmo/zurmo public

# Apache2
COPY config/web/000-default.conf /etc/apache2/sites-available/000-default.conf

# Update php.ini
RUN sed -e 's/zend.assertions = -1/zend.assertions = 0/' \
        -i /etc/php/7.0/apache2/php.ini

# XDebug
COPY config/web/xdebug.ini /tmp/xdebug.ini
RUN cat /tmp/xdebug.ini | tee -a /etc/php/7.0/mods-available/xdebug.ini

# Crontab
COPY config/web/crontab.txt /var/crontab.txt
RUN crontab /var/crontab.txt && chmod 600 /etc/crontab

# Web Writable list
RUN mkdir /var/www/config
COPY config/web/web-writable.txt /var/www/config/web-writable.txt

# Bootstrap
COPY config/web/bootstrap.sh /usr/local/bin/bootstrap.sh
RUN chmod +x /usr/local/bin/bootstrap.sh

# Supervisord
COPY config/web/supervisord.conf /etc/supervisor/supervisord.conf

VOLUME ["/var/www"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
