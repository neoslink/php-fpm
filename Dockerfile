FROM php:7.1.11-fpm

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libpcre3-dev \
        curl

RUN docker-php-ext-install -j$(nproc) mysqli                                                        && \
    docker-php-ext-install -j$(nproc) pdo_mysql                                                     && \
    docker-php-ext-install -j$(nproc) iconv mcrypt                                                  && \
    docker-php-ext-configure opcache --enable-opcache                                               && \
    docker-php-ext-install -j$(nproc) opcache                                                       && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/     && \
    docker-php-ext-install -j$(nproc) gd

RUN pecl install xdebug-2.5.0 && \
    docker-php-ext-enable xdebug

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN touch /usr/local/etc/php/php.ini && \
  echo "xdebug.remote_host=$(/sbin/ip route|awk '/default/ { print $3 }')" >> /usr/local/etc/php/php.ini && \
  echo "xdebug.idekey=DRUCKER" >> /usr/local/etc/php/php.ini && \
  echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini && \
  echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/php.ini && \
  echo "xdebug.remote_port=9002" >> /usr/local/etc/php/php.ini && \
  echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/php.ini && \
  echo "memory_limit=512M" >> /usr/local/etc/php/php.ini

RUN curl -fsSL -o /usr/local/bin/drupal "https://drupalconsole.com/installer" && \
  chmod +x /usr/local/bin/drupal