FROM php:7.2-zts-alpine3.7

# Set version label.
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Circle Eh! version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chris.poupart@gmail.com"



RUN apk --update --no-cache \
        add bash \
            ca-certificates \
            curl \
            git \
            ncurses \
            wget \
            yaml \
            zlib \
 && update-ca-certificates \
 && apk --update --no-cache --virtual build-dependencies \
        add autoconf \
            automake \
            bison \
            g++ \
            libtool \
            m4 \
            make \
            make \
            openssl-dev \
            yaml-dev \
            zlib-dev \
 && docker-php-ext-install -j$(nproc) bcmath sockets zip \
 && pecl channel-update pecl.php.net \
 && pecl config-set php_ini /usr/local/etc/php/php.ini \
 && pecl install yaml-2.0.0 \
 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/pecl_yaml.ini

# This is a work-around until pthreads 3.1.7 is released, at which point we
# will install with pecl, as per above.
# See: https://github.com/krakjoe/pthreads/issues/779
RUN git clone -b master --single-branch https://github.com/krakjoe/pthreads.git \
 && cd pthreads \
 && phpize \
 && ./configure \
 && make \
 && cp modules/pthreads.so /usr/local/lib/php/extensions/no-debug-zts-20170718/pthreads.so \
 && echo "extension=pthreads.so" > /usr/local/etc/php/conf.d/git_pthreads.ini \
 && cd .. && rm -rf pthreads

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

#RUN adduser -S -h /data -s /bin/bash -u 1000 minecraft

RUN git clone https://github.com/pmmp/pocketmine-mp.git --recursive \
 && cd /pocketmine-mp \
 && composer install --no-dev --classmap-authoritative \
 && composer -n clearcache 

RUN apk del build-dependencies

EXPOSE 19132 19132/udp

VOLUME ["/worlds", "/configs", "/plugins"]
WORKDIR /pocketmine-mp

CMD ["/pocketmine-mp/start.sh" "--no-wizard"]
#CMD ["/docker-start.sh"]