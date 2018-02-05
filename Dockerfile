FROM php:5.6-fpm-alpine

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
    openssh-client \
    freetype-dev \
    $PHPIZE_DEPS && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Configure PHP extensions
RUN docker-php-ext-configure json && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-configure curl && \
    docker-php-ext-configure ctype && \
    docker-php-ext-configure dom && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure tokenizer && \
    docker-php-ext-configure simplexml && \
    docker-php-ext-configure mbstring && \
    docker-php-ext-configure zip && \
    docker-php-ext-configure pdo && \
    docker-php-ext-configure pdo_sqlite && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure mysql && \
    docker-php-ext-configure mysqli && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure iconv && \
    docker-php-ext-configure session && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure mcrypt && \
    docker-php-ext-configure xml && \
    docker-php-ext-configure phar && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
    
# Build and install PHP extensions
RUN docker-php-ext-install json \
    session \
    bcmath \
    ctype \
    exif \
    tokenizer \
    simplexml \
    dom \
    gmp \
    mbstring \
    mcrypt \
    zip \
    pdo \
    pdo_sqlite \
    pdo_mysql \
    mysql \
    mysqli \
    opcache \
    curl \
    iconv \
    soap \
    sockets \
    xml  \
    phar \
    gd

RUN pecl install -f xdebug-2.5.5

RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > $PHP_INI_DIR/conf.d/xdebug.ini
RUN echo "display_errors = On" >> $PHP_INI_DIR/conf.d/xdebug.ini

RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 30/g" /usr/local/etc/php-fpm.d/www.conf

# Install git
RUN apk add --update --no-cache git && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install npm and yarn

# Replace shell with bash so we can source files
RUN apk add --update --no-cache bash && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# https://github.com/mhart/alpine-node/blob/master/Dockerfile

ENV VERSION=v8.9.4 NPM_VERSION=5 YARN_VERSION=latest

ENV CONFIG_FLAGS="" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
  for server in pgp.mit.edu keyserver.pgp.com ha.pool.sks-keyservers.net; do \
    gpg --keyserver $server --recv-keys \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
      77984A986EBC2AA786BC0F66B01FBB92821C587A && break; \
  done && \
  curl -sfSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sfSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
    grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep ': OK$' && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -z "$CONFIG_FLAGS" ]; then \
    if [ -n "$NPM_VERSION" ]; then \
      npm install -g npm@${NPM_VERSION}; \
    fi; \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
    if [ -n "$YARN_VERSION" ]; then \
      for server in pgp.mit.edu keyserver.pgp.com ha.pool.sks-keyservers.net; do \
        gpg --keyserver $server --recv-keys \
          6A010C5166006599AA17F08146C2130DFD2497F5 && break; \
      done && \
      curl -sfSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
      gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
      mkdir /usr/local/share/yarn && \
      tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
      ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
      ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
      rm ${YARN_VERSION}.tar.gz*; \
    fi; \
  fi && \
  apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS} && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts

RUN npm install yarn -g

# Create user 1000
RUN adduser -D -u 1000 php

# Install rsync
RUN apk add --update rsync && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Install mysql client
RUN apk add --update mysql-client && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /home/php/.ssh
RUN chmod 700 /home/php/.ssh

RUN chown -R php.php /home/php

