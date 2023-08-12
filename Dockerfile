FROM php:8.0-apache

RUN apt-get update && apt-get upgrade -yy \
    && apt-get install --no-install-recommends apt-utils libjpeg-dev libpng-dev libwebp-dev \
    libzip-dev zlib1g-dev libfreetype6-dev supervisor zip \
    unzip software-properties-common -yy \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install zip \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-install exif \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j "$(nproc)" gd \
    && a2enmod rewrite

# RUN useradd -ms /bin/bash admin

USER  root 
WORKDIR /var/www/html
COPY --chmod=777 ./app /var/www/html/ 



WORKDIR /var/www/html/app/wp-content/
RUN ls -ld /var/www/html/app/wp-content/ 
USER root 
RUN chown -R 777 /var/www/html/app/wp-content/

WORKDIR /var/www/html/app/
RUN chown -R 777 /var/www/html/app

WORKDIR /var/www/html/app/wp-admin
RUN chown -R 777 /var/www/html/app/wp-admin

WORKDIR /var/www/html/app/wp-include
RUN chown -R 777 /var/www/html/app/wp-include

WORKDIR /var/www/html/app/wp-content/plugins
RUN chown -R 777 /var/www/html/app/wp-content/plugins

WORKDIR /var/www/html/app/wp-content/upload
RUN chown -R 777 /var/www/html/app/wp-content/upload
WORKDIR /var/www/html/app/wp-content/themes
RUN chown -R 777 /var/www/html/app/wp-content/themes

WORKDIR /var/www/html/app/wp-includes
RUN chown -R 777 /var/www/html/app/wp-includes