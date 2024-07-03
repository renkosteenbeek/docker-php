ARG PHP_VERSION=""
ARG ARCH=
FROM ${ARCH}php:8.3-fpm-alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        zlib-dev \
        libpng-dev \
        jpeg-dev \
        libzip-dev \
        ssmtp \
        imagemagick \
        imagemagick-dev

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime && \
    echo "Europe/Amsterdam" > /etc/timezone && \
    apk del tzdata

# Add couple of php modules
RUN docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install mysqli gd opcache exif bcmath zip calendar

# Add imagick php module (using pecl with a specific version)
RUN apk add php83-pecl-imagick --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk --update add imagemagick imagemagick-dev

# Add opcache config
ENV OPCACHE_VALIDATE_TIMESTAMP=1
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Add php config
COPY default.ini /usr/local/etc/php/conf.d/default.ini
COPY php-ini-development.php /usr/local/etc/php/php.ini-development
COPY php.ini-production.php /usr/local/etc/php/php.ini-production

# Add localization
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl
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