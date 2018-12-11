FROM php:7.1-fpm-alpine
LABEL maintainer="Tom Richards <tom.r@delegator.com>"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="delegator/magento2"
LABEL org.label-schema.description="Opinionated docker image for Magento 2.2+."
LABEL org.label-schema.vcs-url="https://github.com/delegator/docker-magento2"

# Install packages, including runtime dependencies
RUN apk add --update --no-cache \
  nginx nginx-mod-http-headers-more \
  bash runit \
  curl htop git libxml2-utils make openssh vim wget \
  mysql-client redis \
  nodejs sassc yarn \
  msmtp \
  procps patch \
  freetype icu libjpeg-turbo libmcrypt libpng libxml2 libxslt

# Configure msmtp
RUN unlink /usr/sbin/sendmail \
 && ln -s /usr/bin/msmtp /usr/sbin/sendmail

ENV EXTENSION_DEPS freetype-dev icu-dev libjpeg-turbo-dev libmcrypt-dev libpng-dev libxml2-dev libxslt-dev

# Install build dependencies and PHP extensions
RUN apk add --no-cache --virtual .ext-deps $EXTENSION_DEPS \
 && docker-php-ext-install -j$(nproc) bcmath intl mcrypt opcache pdo_mysql soap xsl zip \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd \
 && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
 && pecl install xdebug-2.6.1 \
 && apk del .build-deps \
 && apk del .ext-deps \
 && rm -rf /tmp/pear

# Add non-privileged web server user
# Configure nginx and php
ENV PHP_LOG_STREAM="/var/log/php.log"
RUN deluser xfs \
 && deluser www-data \
 && addgroup -S -g 33 www-data \
 && adduser -S -D -u 33 -G www-data -h /var/www -s /bin/bash www-data \
 && rm -f /etc/nginx/conf.d/default.conf \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 && mkfifo -m 777 $PHP_LOG_STREAM

# Install composer
ENV COMPOSER_VERSION 1.8.0
RUN curl -sL https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar -o /usr/local/bin/composer \
 && chmod +x /usr/local/bin/composer \
 && composer --version

# Install prestissimo for parallel composer downloads
USER www-data
RUN composer global require hirak/prestissimo \
 && rm -rf /var/www/.composer/cache
USER root
RUN composer global require hirak/prestissimo \
 && rm -rf /root/.composer/cache

# Install n98-magerun2
ENV MAGERUN2_VERSION 3.0.1
RUN curl -sL https://files.magerun.net/n98-magerun2-$MAGERUN2_VERSION.phar -o /usr/local/bin/n98-magerun2 \
 && chmod +x /usr/local/bin/n98-magerun2 \
 && n98-magerun2 --version

# Install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && dockerize -version

# Install config files
COPY ./config/nginx /etc/nginx
COPY ./config/php /usr/local/etc/php
COPY ./config/php-fpm.d /usr/local/etc/php-fpm.d
COPY ./config/services /services

# Test nginx configuration
RUN /usr/sbin/nginx -T

# Set working directory
RUN mkdir -p /var/www/magento2 \
 && chown -R www-data:www-data /var/www
WORKDIR /var/www/magento2

# Default command; run nginx and php-fpm services
CMD ["/sbin/runsvdir", "/services"]

# Expose ports
EXPOSE 80
