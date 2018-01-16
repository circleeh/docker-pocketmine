FROM alpine:3.7

# PocketMine requires reading and agreeing to their EULA.
# https://github.com/pmmp/PocketMine-MP/blob/master/LICENSE
ARG AGREE_EULA=false
ENV EULA=$AGREE_EULA

RUN apk --update add bash \
                       ca-certificates \
                       curl \
                       git \
                       wget \
 && update-ca-certificates

# Install a repo that provides up-to-date PHP for Alpine
ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo "@php https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories \
 && apk --update add php7@php \
                       php7-bcmath@php \
                       php7-curl@php \
                       php7-dom@php \
                       php7-iconv@php \
                       php7-json@php \
                       php7-mbstring@php \
                       php7-openssl@php \
                       php7-pear@php \
                       php7-phar@php \
                       php7-sockets@php \
                       php7-zip@php \
                       php7-zlib@php 

RUN apk --update --no-cache --virtual .build-deps add \
    g++ make autoconf yaml-dev bison make automake libtool php7-dev@php

RUN pecl channel-update pecl.php.net \
 && pecl install yaml-2.0.0

# This is a work-around until pthreads 3.1.7 is released, at which point we
# will install with pecl, as per above.
RUN git clone -b master --single-branch https://github.com/krakjoe/pthreads.git \
 && cd pthreads \
 && pfize

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN if [ "$EULA" = "true" ]; then echo 'eula=true' > /; fi

#RUN adduser -S -h /data -s /bin/bash -u 1000 minecraft

RUN git clone https://github.com/pmmp/pocketmine-mp.git --recursive \
 && cd pocketmine-mp \
 && composer install --no-dev --classmap-authoritative

EXPOSE 19132
VOLUME ["/data"]
WORKDIR /data

CMD ["./start.sh" "-r"]
#CMD ["/docker-start.sh"]
