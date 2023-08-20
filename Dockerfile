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

ARG _ACCESS_TOKEN
# ENV _ACCESS_TOKEN=$_ACCESS_TOKEN


RUN groupadd -r user && useradd -r -g user user
USER root

WORKDIR /var/www/html/
RUN chmod 777 /var/www/html/gcsfuse_run.sh
USER user
# Set fallback mount directory
#ENV MNT_DIR /var/www/html/wp-content/upload-1
ENV MNT_DIR /var/www/html/wp-content
RUN /var/www/html/gcsfuse_run.sh
#Testing END 
# Copy local code to the container image.
USER  root 
WORKDIR /var/www/html
COPY --chmod=777 ./app /var/www/html/ 
RUN ls -alrt 

# Testing Start 
# Ensure the script is executable

RUN echo $_ACCESS_TOKEN > /var/www/html/service_account_conf.json
#RUN chmod 777 /var/www/html/gcsfuse_run.sh
#Testing END 

WORKDIR /var/www/html/wp-content/
RUN ls -ld /var/www/html/wp-content/ 
#USER root 
RUN chmod -R 777 /var/www/html/wp-content/

WORKDIR /var/www/html/wp-admin
RUN chmod -R 777 /var/www/html/wp-admin

WORKDIR /var/www/html/wp-admin/includes
RUN chmod -R 777 /var/www/html/wp-admin/includes

WORKDIR /var/www/html/wp-include
RUN chmod -R 777 /var/www/html/wp-include

WORKDIR /var/www/html/wp-content/plugins
RUN chmod -R 777 /var/www/html/wp-content/plugins

WORKDIR /var/www/html/wp-content/upload
RUN chmod -R 777 /var/www/html/wp-content/upload

WORKDIR /var/www/html/wp-content/themes
RUN chmod -R 777 /var/www/html/wp-content/themes

WORKDIR /var/www/html/wp-includes
RUN chmod -R 777 /var/www/html/wp-includes


# Testing Start 
# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
# ENTRYPOINT ["/usr/bin/tini", "--"]
# CMD ["/var/www/html/gcsfuse_run.sh"]
# CMD ["apache2ctl", "-D", "FOREGROUND"]
# Pass the wrapper script as arguments to tini
#CMD ["/var/www/html/gcsfuse_run.sh"]
#Testing END 
# CMD ["apache2ctl", "-D", "FOREGROUND"]