FROM php:7.3-fpm-alpine

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
    libzip-dev \
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
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ && \
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
    gd \
# Clean up dev packages
 && apk del $PHPIZE_DEPS \
    libressl-dev \
#RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 30/g" /usr/local/etc/php-fpm.d/www.conf
 && sed -i -e "s/\;log_level = notice/log_level = debug/g" /usr/local/etc/php-fpm.conf \
# Install git
 && apk add --update --no-cache git \
# Install composer
 && curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer \
# Replace shell with bash so we can source files
 && apk add --update --no-cache bash && \
    rm /bin/sh && \
    ln -s /bin/bash /bin/sh \
# Create user 1000
 && adduser -D -u 1000 php && \
    mkdir -p /home/php/.ssh && \
    chmod 700 /home/php/.ssh && \
    chown -R php.php /home/php \
# Install rsync
 && apk add --update rsync \
# Install mysql client
 && apk add --update mysql-client \
# Install nodejs, npm and yarn
#RUN curl -L https://git.io/n-install | N_PREFIX=/n bash -s -- -y \
# && ln -s /n/bin/node /usr/bin/node \
# && ln -s /n/bin/npm /usr/bin/npm \
# && curl -0 -L https://npmjs.com/install.sh | clean=no sh \
# && npm install --global yarn \
# && ln -s /n/bin/yarn /usr/bin/yarn
# Install nodejs, npm and yarn
 && apk add --update nodejs npm yarn \
# Install vim
 && apk add --update vim \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*
