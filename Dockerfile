ARG PHP_VERSION=""
ARG ARCH=
FROM ${ARCH}php:8.4-fpm-alpine

RUN apk update; \
    apk upgrade; \
    apk add zlib-dev libpng-dev jpeg-dev libzip-dev ssmtp;

RUN apk add tzdata; \
    cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime; \
    echo "Europe/Amsterdam" > /etc/timezone; \
    apk del tzdata;

# Add couple of php modules
RUN docker-php-ext-configure gd --with-jpeg; \
    docker-php-ext-install mysqli gd opcache exif bcmath zip calendar

# Add imagick php module (not available in docker-php-ext-install)
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions imagick

# Add opcache config
ENV OPCACHE_VALIDATE_TIMESTAMP=1
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY default.ini /usr/local/etc/php/conf.d/default.ini

# Add localization
ENV MUSL_LOCALE_DEPS="cmake make musl-dev gcc gettext-dev libintl"
ENV MUSL_LOCPATH="/usr/share/i18n/locales/musl"
RUN apk add --no-cache \
    $MUSL_LOCALE_DEPS \
    && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
    && unzip musl-locales-master.zip \
      && cd musl-locales-master \
      && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install \
      && cd .. && rm -r musl-locales-master

# Add Sendmail. To make it work, a valid config file must be set in /etc/ssmtp/ssmtp.conf (not included).
RUN echo "sendmail_path=sendmail -i -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini
COPY ssmtp.conf /etc/ssmtp/ssmtp.conf