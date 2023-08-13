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
# Testing Start 
# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    tini && \
    gcsFuseRepo=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
    tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key add - && \
    apt-get update && \
    apt-get install -y gcsfuse && \
    apt-get clean

# Set fallback mount directory
ENV MNT_DIR /mnt/gcs
ENV ACCESS_TOKEN=$ACCESS_TOKEN

RUN echo $ACCESS_TOKEN > /var/www/html/app/service_account_conf.json

#Testing END 
# Copy local code to the container image.
USER  root 
WORKDIR /var/www/html
COPY --chmod=777 ./app /var/www/html/ 

# Testing Start 
# Ensure the script is executable
WORKDIR /var/www/html/app
#RUN chmod 777 /var/www/html/app/gcsfuse_run.sh
#Testing END 

WORKDIR /var/www/html/app/wp-content/
RUN ls -ld /var/www/html/app/wp-content/ 
USER root 
RUN chmod -R 777 /var/www/html/app/wp-content/

WORKDIR /var/www/html/app/wp-admin
RUN chmod -R 777 /var/www/html/app/wp-admin

WORKDIR /var/www/html/app/wp-admin/includes
RUN chmod -R 777 /var/www/html/app/wp-admin/includes

WORKDIR /var/www/html/app/wp-include
RUN chmod -R 777 /var/www/html/app/wp-include

WORKDIR /var/www/html/app/wp-content/plugins
RUN chmod -R 777 /var/www/html/app/wp-content/plugins

WORKDIR /var/www/html/app/wp-content/upload
RUN chmod -R 777 /var/www/html/app/wp-content/upload

WORKDIR /var/www/html/app/wp-content/themes
RUN chmod -R 777 /var/www/html/app/wp-content/themes

WORKDIR /var/www/html/app/wp-includes
RUN chmod -R 777 /var/www/html/app/wp-includes

WORKDIR /var/www/html/app/
RUN chmod -R 777 /var/www/html/app

RUN ls-alrt 

# Testing Start 
# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# Pass the wrapper script as arguments to tini
CMD ["./gcsfuse_run.sh"]
#Testing END 