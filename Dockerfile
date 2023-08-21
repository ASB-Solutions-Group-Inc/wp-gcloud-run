# Use the official PHP 8.0 Apache base image
FROM php:8.0-apache

# Install system dependencies
RUN set -eux; \
    apt-get update && apt-get upgrade -yy; \
    apt-get install --no-install-recommends -yy \
        apt-utils \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        zlib1g-dev \
        libfreetype6-dev \
        supervisor \
        zip \
        unzip \
        software-properties-common \
        curl \
        gnupg \
        lsb-release \
        apt-transport-https \
        ca-certificates \
        tini; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install PHP extensions
RUN docker-php-ext-install zip exif
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install -j "$(nproc)" gd mysqli pdo pdo_mysql

# Enable Apache modules
RUN a2enmod rewrite

# Install gcsfuse and Google Cloud SDK
RUN GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s) && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y gcsfuse && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \ 
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-cli -y
      

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set build argument for access token
ARG _ACCESS_TOKEN
ENV _ACCESS_TOKEN=${_ACCESS_TOKEN}

# Create a non-root user
RUN groupadd -r user && useradd -r -g user user
USER root

# Copy and set permissions for local code
WORKDIR /var/www/html
COPY --chmod=777 ./app /var/www/html/
RUN chmod -R 777 /var/www/html/

# Copy access token to the application folder
RUN echo $_ACCESS_TOKEN > /var/www/html/service_account_conf.json

WORKDIR /var/www/html/
RUN chmod 777 /var/www/html/gcsfuse_run.sh
RUN chmod 777 /var/www/html/service_account_conf.json

# Set fallback mount directory
ENV MNT_DIR /var/www/html/app-dev
RUN /var/www/html/gcsfuse_run.sh

# Use tini to manage processes and signal forwarding
ENTRYPOINT ["/usr/bin/tini", "--"]

# Pass the wrapper script as arguments to tini
# RUN  "/var/www/html/gcsfuse_run.sh"

# Start Apache in foreground
CMD ["apache2-foreground"]