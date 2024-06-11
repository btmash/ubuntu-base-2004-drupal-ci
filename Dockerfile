# syntax=docker/dockerfile:1
LABEL com.btmash.build-date="2024-06-11"

FROM ubuntu:20.04

#stop asking geographic area while building image |  ¿apt-utils?  ¿unzip?
ARG DEBIAN_FRONTEND=noninteractive 

RUN apt-get update

RUN apt-get install -y wget git unzip

RUN apt-get install -y apt-utils

RUN  apt-get install --no-install-recommends -y php7.4 php7.4-fpm php7.4-gd php7.4-cli php-pear php-redis php7.4-mysql php7.4-curl php-memcached php-bcmath php7.4-zip php-mbstring php7.4-dev

RUN php -- --disable-tls

RUN apt-get install -y build-essential
RUN pecl install timezonedb
RUN echo extension=timezonedb.so > /etc/php/7.4/mods-available/timezonedb.ini
RUN ln -s /etc/php/7.4/mods-available/timezonedb.ini /etc/php/7.4/cli/conf.d/30-timezone.ini
RUN ln -s /etc/php/7.4/mods-available/timezonedb.ini /etc/php/7.4/fpm/conf.d/30-timezone.ini

# INSTALLING COMPOSER
RUN wget --no-check-certificate https://getcomposer.org/download/1.10.27/composer.phar

RUN chmod 0755 composer.phar && mv composer.phar /usr/local/bin/composer

RUN apt-get -y clean && apt-get -y autoremove
