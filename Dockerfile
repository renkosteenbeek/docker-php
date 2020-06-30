ARG PHP_VERSION=""
FROM php:7.4-fpm-alpine

RUN apk update; \
    apk upgrade; \
    apk add zlib-dev libpng-dev jpeg-dev libzip-dev ssmtp;

RUN apk add tzdata; \
    cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime; \
    echo "Europe/Amsterdam" > /etc/timezone; \
    apk del tzdata;

# Add couple of php modules
RUN docker-php-ext-configure gd --with-jpeg; \
    docker-php-ext-install mysqli gd opcache exif bcmath zip

# Add imagick php module (not available in docker-php-ext-install)
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions imagick

# Add opcache config
ENV OPCACHE_VALIDATE_TIMESTAMP=1
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Add Sendmail. To make it work, a valid config file must be set in /etc/ssmtp/ssmtp.conf (not included).
RUN echo "sendmail_path=sendmail -i -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini
COPY ssmtp.conf /etc/ssmtp/ssmtp.conf