ARG PHP_VERSION=""
FROM php:7.4-fpm-alpine

RUN apk update; \
    apk upgrade; \
    apk add zlib-dev libpng-dev libzip;

# Add couple of php modules
RUN docker-php-ext-install mysqli gd opcache exif bcmath

# Add imagick php module (not available in docker-php-ext-install)
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions imagick

# Add opcache config
ENV OPCACHE_VALIDATE_TIMESTAMP=1
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini