FROM php:7.2-fpm-alpine

COPY php.ini /usr/local/etc/php/

# Install dependencies
RUN apk --no-cache --update add \
    libxml2-dev \
    sqlite-dev \
    curl-dev \
    gmp \
    gmp-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libmcrypt-dev \
    libressl-dev \
    openssh-client \
    freetype-dev \
    icu-dev \
    $PHPIZE_DEPS && \
    # Configure PHP extensions
    docker-php-ext-configure json && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-configure curl && \
    docker-php-ext-configure ctype && \
    docker-php-ext-configure dom && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure intl && \
    docker-php-ext-configure tokenizer && \
    docker-php-ext-configure simplexml && \
    docker-php-ext-configure mbstring && \
    docker-php-ext-configure zip && \
    docker-php-ext-configure pdo && \
    docker-php-ext-configure pdo_sqlite && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure mysqli && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure iconv && \
    docker-php-ext-configure session && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure xml && \
    docker-php-ext-configure phar && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    # Build and install PHP extensions
    docker-php-ext-install json \
    session \
    bcmath \
    ctype \
    exif \
    intl \
    tokenizer \
    simplexml \
    dom \
    gmp \
    mbstring \
    zip \
    pdo \
    pdo_sqlite \
    pdo_mysql \
    mysqli \
    opcache \
    curl \
    iconv \
    soap \
    sockets \
    xml  \
    phar \
    gd && \
    # Install XDebug
    pecl install -f xdebug-2.6.1 && \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > $PHP_INI_DIR/conf.d/xdebug.ini && \
    echo "display_errors = On" >> $PHP_INI_DIR/conf.d/xdebug.ini && \
    # Clean up dev packages
    apk del $PHPIZE_DEPS \
    libressl-dev \
    && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 30/g" /usr/local/etc/php-fpm.d/www.conf

# Install git
RUN apk add --update --no-cache git && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Replace shell with bash so we can source files
RUN apk add --update --no-cache bash && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm /bin/sh && \
    ln -s /bin/bash /bin/sh

# Create user 1000
RUN adduser -D -u 1000 php && \
    mkdir -p /home/php/.ssh && \
    chmod 700 /home/php/.ssh && \
    chown -R php.php /home/php

# Install rsync
RUN apk add --update rsync && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Install mysql client
RUN apk add --update mysql-client && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Install nodejs, npm and yarn
RUN apk add --update nodejs npm yarn && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Install python and compilers to be able to make node-gyp
#RUN apk --no-cache add python cairo-dev make g++
