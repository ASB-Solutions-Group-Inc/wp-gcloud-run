# Use the official PHP 8.0 Apache base image
FROM php:8.0-apache

# Update and install necessary packages in a single layer
RUN apt-get update && apt-get upgrade -yy \
    && apt-get install --no-install-recommends -yy \
        apt-utils libjpeg-dev libpng-dev libwebp-dev \
        libzip-dev zlib1g-dev libfreetype6-dev supervisor zip \
        unzip software-properties-common \
        curl gnupg lsb-release tini && \
    gcsFuseRepo=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
        tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        apt-key add - && \
    apt-get update && \
    apt-get install -y gcsfuse && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install necessary PHP extensions and configure Apache
RUN docker-php-ext-install zip mysqli pdo pdo_mysql exif && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j "$(nproc)" gd && \
    a2enmod rewrite

# Set fallback mount directory
ENV MNT_DIR /mnt/gcs

# Set build argument for access token
ARG _ACCESS_TOKEN
ENV _ACCESS_TOKEN=${_ACCESS_TOKEN}

# Set working directory and copy application files
WORKDIR /var/www/html/app
COPY --chmod=777 ./app /var/www/html/

# Copy access token to the application folder
RUN echo $_ACCESS_TOKEN > /var/www/html/app/service_account_conf.json

# Set permissions for various directories
RUN chmod -R 777 \
    /var/www/html/app/wp-* /var/www/html/app/*

# Use tini to manage processes and signal forwarding
#ENTRYPOINT ["/usr/bin/tini", "--"]

# Pass the wrapper script as arguments to tini
#CMD ["./gcsfuse_run.sh"]
