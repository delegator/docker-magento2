FROM php:7.1-fpm-alpine
LABEL maintainer="Tom Richards <tom.r@delegator.com>"

# Install packages, including runtime dependencies
RUN apk add --update --no-cache \
  nginx nginx-mod-http-headers-more nginx-mod-http-geoip \
  bash runit \
  curl htop git libxml2-utils make openssh vim wget \
  mysql-client \
  redis \
  nodejs yarn \
  sassc \
  procps \
  freetype icu libjpeg-turbo libmcrypt libpng libxml2 libxslt

ENV EXTENSION_DEPS freetype-dev icu-dev libjpeg-turbo-dev libmcrypt-dev libpng-dev libxml2-dev libxslt-dev

# Install build dependencies and PHP extensions
RUN apk add --no-cache --virtual .ext-deps $EXTENSION_DEPS \
 && docker-php-ext-install -j$(nproc) bcmath intl mcrypt opcache pdo_mysql soap xsl zip \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd \
 && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
 && pecl install xdebug-2.6.1 \
 && apk del .build-deps \
 && apk del .ext-deps

# Add non-privileged web server user
# Configure nginx and php
ENV PHP_LOG_STREAM="/var/log/php.log"
RUN deluser xfs \
 && deluser www-data \
 && addgroup -S -g 33 www-data \
 && adduser -S -D -u 33 -G www-data -s /bin/bash www-data \
 && rm -f /etc/nginx/conf.d/default.conf \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 && mkfifo -m 777 $PHP_LOG_STREAM

# Install composer
RUN curl -sL https://getcomposer.org/download/1.7.3/composer.phar -o /usr/local/bin/composer \
 && chmod +x /usr/local/bin/composer \
 && composer --version

# Install n98-magerun2
RUN curl -sL https://files.magerun.net/n98-magerun2-2.3.2.phar -o /usr/local/bin/n98-magerun2 \
 && chmod +x /usr/local/bin/n98-magerun2 \
 && n98-magerun2 --version

# Install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && dockerize -version

# Install prestissimo
RUN composer global require hirak/prestissimo

# Install config files and tester site
COPY ./config/nginx /etc/nginx
COPY ./config/php /usr/local/etc/php
COPY ./config/services /services
COPY ./tester /usr/share/nginx/tester

# Test nginx configuration
RUN /usr/sbin/nginx -T

# Set working directory
RUN chown -R www-data:www-data /var/www
WORKDIR /var/www

# Default command; run nginx and php-fpm services
CMD ["/sbin/runsvdir", "/services"]

# Expose ports
EXPOSE 80
