ARG PHP_VERSION=7.2

FROM composer:latest as composer
FROM php:${PHP_VERSION}

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y \
    git-core


COPY --from=composer /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /home/docker/.composer
# contains dev-mode packages
RUN composer global require "hirak/prestissimo:^0.3" "sllh/composer-versions-check:^2.0" "pyrech/composer-changelogs:^1.7" --prefer-dist --no-progress --no-suggest --classmap-authoritative

##############################################################
# add symfony/panther
##############################################################
RUN apt-get update && apt-get install -y libzip-dev zlib1g-dev unzip chromium && docker-php-ext-install zip
ENV PANTHER_NO_SANDBOX 1

##############################################################
# add gd
##############################################################

RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    libpng-dev

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd

WORKDIR /var/www/html
COPY . /var/www/html

COPY ./start-project.sh /start-project.sh

ENTRYPOINT /start-project.sh
