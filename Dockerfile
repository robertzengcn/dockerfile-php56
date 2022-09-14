FROM php:5.6-fpm
RUN apt-get clean

#更换为国内镜像


RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y \
        autoconf \
        build-essential \
        libbsd-dev \
        libbz2-dev \
        libc-client2007e-dev \
        libc6-dev \
        libcurl3 \
        libcurl4-openssl-dev \
        libedit-dev \
        libedit2 \
        libgmp-dev \
        libgpgme11-dev \
        libicu-dev \
        libjpeg-dev \
        libkrb5-dev \
        libldap2-dev \
        libldb-dev \
        libmagick++-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpcre3-dev \
        libpng-dev \
        libsqlite3-0 \
        libsqlite3-dev \
        libssh2-1-dev \
        libssl-dev \
        libtinfo-dev \
        libtool \
        libvpx-dev \
        libwebp-dev \
        libxml2 \
        libxml2-dev \
        libxpm-dev \
        libxslt1-dev \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu; \
    docker-php-ext-configure gd \
        --with-png-dir=/usr \
        --with-jpeg-dir=/usr \
        --with-freetype-dir=/usr \
        --with-xpm-dir=/usr \
        --with-vpx-dir=/usr; \
    docker-php-ext-configure gmp --with-libdir=lib/x86_64-linux-gnu; \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        dba \
        exif \
        gd \
        gettext \
        gmp \
        imap \
        intl \
        ldap \
        mcrypt \
        mysql \
        mysqli \
        opcache \
        pdo_mysql \
        shmop \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        wddx \
        xmlrpc \
        xsl \
        zip ;


RUN docker-php-ext-enable --ini-name pecl.ini \
        gnupg \
        imagick \
        msgpack \
        redis \
        runkit \
        ssh2 \
    ; \
    curl --connect-timeout 10 -o ioncube.tar.gz -kfSL "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"; \
    tar -zxvf ioncube.tar.gz; \
    cp ioncube/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/ioncube.so; \
    rm -Rf ioncube*; \
    NR_VERSION="$( curl --connect-timeout 10 -skS https://download.newrelic.com/php_agent/release/ | sed -n 's/.*>\(.*linux\).tar.gz<.*/\1/p')"; \
    curl --connect-timeout 10 -o nr.tar.gz -kfSL "https://download.newrelic.com/php_agent/release/$NR_VERSION.tar.gz"; \
    tar -xf nr.tar.gz; \
    cp $NR_VERSION/agent/x64/newrelic-20131226.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/newrelic.so; \
    rm -rf newrelic-php5* nr.tar.gz; \
    echo "zend_extension=ioncube.so" > /usr/local/etc/php/conf.d/01-ioncube.ini; \
    echo "extension=newrelic.so" > /usr/local/etc/php/conf.d/10-newrelic.ini; \
    echo "runkit.internal_override=1" > /usr/local/etc/php/conf.d/10-runkit.ini;

RUN set -ex ; \
    \
    apt-get update && apt-get install -y --no-install-recommends \
        libc-client2007e \
        libgpgme11 \
        libicu57 \
        libmagickwand-6.q16-3 \
        libmcrypt4 \
        libmemcached11 \
        libmemcachedutil2 \
        libpng16-16 \
        libvpx4 \
        libwebp6 \
        libxpm4 \
        libxslt1.1 \
        ssmtp \
        ; \
    rm -rf /tmp/pear /usr/share/doc /usr/share/man /var/lib/apt/lists/*; \
    cd /usr/local/etc/php; \
    php-fpm -v 2>/dev/null | sed -E 's/PHP ([5|7].[0-9]{1,2}.[0-9]{1,2})(.*)/\1/g' | head -n1 > php_version.txt;


RUN pear install --alldeps \
        Auth_SASL \
        Auth_SASL2-beta \
        Benchmark \
        pear.php.net/Console_Color2-0.1.2 \
        Console_Table \
        HTTP_OAuth-0.3.1 \
        HTTP_Request2 \
        Log \
        Mail \
        MDB2 \
        Net_GeoIP \
        Net_SMTP \
        Net_Socket \
        XML_RPC2 \
        pear.symfony.com/YAML \
    ;


RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev

RUN docker-php-ext-install zip


RUN echo "date.timezone = America/Los_Angeles" > /usr/local/etc/php/conf.d/php.ini
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install posix
EXPOSE 9000
RUN apt-get install -y nscd

RUN apt-get clean && \
    apt-get update && \
    apt-get install -y memcached

# RUN docker-php-source extract \
#     && curl -Lk -o /tmp/redis.tar.gz https://codeload.github.com/phpredis/phpredis/tar.gz/refs/tags/2.2.8 \
#     && tar xfz /tmp/redis.tar.gz \
#     && rm -r /tmp/redis.tar.gz \
#     && mv phpredis-2.2.8 /usr/src/php/ext/redis \
#     && docker-php-ext-install redis \
#     && docker-php-source delete

COPY ./phpredis-2.2.8.tar.gz /tmp/redis.tar.gz

RUN docker-php-source extract \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-2.2.8 /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && docker-php-source delete

RUN apt-get update && apt-get install -y libmemcached11 libmemcachedutil2 build-essential libmemcached-dev libz-dev
# RUN pecl install memcached-2.2.0
# RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

# RUN docker-php-source extract \
#     && curl -L /tmp/mongodb-1.4.2.tgz 'http://pecl.php.net/get/mongodb-1.4.2.tgz'\
#     && pecl install mongodb-1.4.2.tgz \
# 	&& docker-php-ext-enable memcache


# RUN cd /tmp \
#     && curl -o php-memcache.tgz http://pecl.php.net/get/memcache-3.0.8.tgz \
#     && tar -xzvf php-memcache.tgz \
#     && cd memcache-3.0.8 \
#     && curl -o memcache-faulty-inline.patch http://git.alpinelinux.org/cgit/aports/plain/main/php5-memcache/memcache-faulty-inline.patch?h=3.4-stable \
#     && patch -p1 -i memcache-faulty-inline.patch \
#     && phpize \
#     && ./configure --prefix=/usr \
#     && make INSTALL_ROOT=/ install \
#     && install -d ./etc/php/conf.d \
#     && echo "extension=memcache.so" > /usr/local/etc/php/conf.d/memcache.ini


# RUN curl -o php-memcache.tgz http://pecl.php.net/get/memcached-2.2.0.tgz \
#      && pecl install php-memcache.tgz \
#      && docker-php-ext-enable memcache

# RUN pecl install memcache-3.0.6.tgz\
# 	&& docker-php-ext-enable memcache

RUN docker-php-source extract \
    && mkdir -p /usr/src/php/ext/memcache \
    && curl -fsSL http://pecl.php.net/get/memcache-2.2.7.tgz | tar xvz -C /usr/src/php/ext/memcache --strip 1 \
    && docker-php-ext-install memcache \
    # cleanup
    && docker-php-source delete

RUN docker-php-source extract \
    && mkdir -p /usr/src/php/ext/memcached \
    && curl -fsSL http://pecl.php.net/get/memcached-2.2.0.tgz | tar xvz -C /usr/src/php/ext/memcached --strip 1 \
    && docker-php-ext-install memcached \
    # cleanup
    && docker-php-source delete  

RUN curl -fsSLk 'https://xdebug.org/files/xdebug-2.4.0.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
    cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r xdebug \
    && docker-php-ext-enable xdebug

RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.auto_trace=false" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.trace_output_dir = /var/www/html/foxitlog/" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.trace_output_name=trace.%t%R" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.profiler_output_dir = /var/www/html/foxitlog/" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini
   
 

    
  






# RUN build_deps="curl" && \
#     apt-get update && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${build_deps} ca-certificates && \
#     curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --allow-unauthenticated git-lfs && \
#     git lfs install && \
#     DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${build_deps} && \
#     rm -r /var/lib/apt/lists/*  

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

RUN apt-get install -y p7zip \
    p7zip-full \
    unace \
    zip \
    unzip \
    xz-utils \
    sharutils \
    uudeview \
    mpack \
    arj \
    cabextract \
    file-roller \
    && rm -rf /var/lib/apt/lists/*  

RUN apt-get update && apt-get install -y expect 

RUN docker-php-ext-install zip

RUN curl https://phar.phpunit.de/phpunit-5.7.phar -L -o phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit
RUN apt-get update && apt-get install zlibc

RUN curl --silent --show-error https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer    

RUN docker-php-ext-install mbstring
EXPOSE 9000
CMD ["php-fpm"]    
    