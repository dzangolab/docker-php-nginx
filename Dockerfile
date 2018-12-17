FROM php:7.2-fpm

MAINTAINER Olivier Pichon <op@united-asian.com>

ARG build='build'

ARG memory_limit=-1

ARG timezone='Asia/Hong_Kong'

ARG upload_max_filesize='10M'

ARG version='version'

RUN ulimit -n 4096 \
    && apt-get update && apt-get install -y --force-yes --fix-missing  && apt install -y apt-utils \
        build-essential \
        cron \
        git \
        gnupg \
        libcap2-bin \
        libcurl4-gnutls-dev \
        libfreetype6-dev \
        libgeoip-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libpng-dev \
        libxml2-dev \
        libxslt1.1 libxslt1-dev \
        locales \
        netcat \
        nginx \
        openssh-client \
        unzip \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        calendar \
        curl \
        exif \
        gd \
        gettext \
        intl \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        wddx \
        xsl \
        zip

 RUN echo "date.timezone="$timezone > /usr/local/etc/php/conf.d/date_timezone.ini \
    && echo "memory_limit="$memory_limit > /usr/local/etc/php/conf.d/memory_limit.ini \
    && echo "upload_max_filesize="$upload_max_filesize > /usr/local/etc/php/conf.d/upload_max_filesize.ini \
    && echo "display_errors=0" > /usr/local/etc/php/conf.d/display_errors.ini \
    && echo "log_errors=1" > /usr/local/etc/php/conf.d/log_errors.ini \
    && chown -R www-data:www-data /var/www \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN pecl install imagick \
    && docker-php-ext-enable imagick \
    && pecl install geoip-1.1.1  && echo "extension=geoip.so" >> /usr/local/etc/php/conf.d/geoip.ini

RUN /usr/sbin/nginx -v

RUN setcap cap_net_bind_service=+ep /usr/sbin/nginx

ENV PATH "/var/www/.composer/vendor/bin:$PATH"

COPY ./etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY ./etc/conf.d/ /usr/local/etc/php/conf.d/

COPY nginx.conf /etc/nginx/conf.d/nginx.conf

RUN touch /var/run/nginx.pid

RUN  chown -R www-data:www-data /var/run/nginx.pid /var/lib/nginx /var/log

COPY www/index.html /var/www/html/web/

COPY www/index.php /var/www/html/web/

COPY docker-php-nginx-entrypoint /var/www/html/

RUN chown -R www-data:www-data /var/lib/nginx /var/www \
   && chmod -R 777 /var/lib/nginx

WORKDIR /var/www/html

RUN touch /var/log/cron.log

EXPOSE 80 443

ENTRYPOINT ["/bin/sh"]

CMD ["docker-php-nginx-entrypoint"]
