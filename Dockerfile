FROM php:7.2-zts-alpine3.7

# PocketMine requires reading and agreeing to their EULA.
# https://github.com/pmmp/PocketMine-MP/blob/master/LICENSE
ARG AGREE_EULA=false
ENV EULA=$AGREE_EULA

RUN apk --update add bash \
                       ca-certificates \
                       curl \
                       git \
                       wget \
                       yaml \
                       zlib \
 && update-ca-certificates

RUN apk --update --no-cache --virtual build-dependencies add \
    g++ make autoconf yaml-dev bison make m4 automake libtool zlib-dev openssl-dev

RUN docker-php-ext-install -j$(nproc) bcmath sockets zip

RUN pecl channel-update pecl.php.net \
 && pecl install yaml-2.0.0 \
 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/pecl_yaml.ini

# This is a work-around until pthreads 3.1.7 is released, at which point we
# will install with pecl, as per above.
RUN git clone -b master --single-branch https://github.com/krakjoe/pthreads.git \
 && cd pthreads \
 && phpize \
 && ./configure \
 && make \
 && cp modules/pthreads.so /usr/local/lib/php/extensions/no-debug-zts-20170718/pthreads.so \
 && echo "extension=pthreads.so" > /usr/local/etc/php/conf.d/git_pthreads.ini \
 && cd .. && rm -rf pthreads

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN if [ "$EULA" = "true" ]; then echo 'eula=true' > /; fi

#RUN adduser -S -h /data -s /bin/bash -u 1000 minecraft

RUN git clone https://github.com/pmmp/pocketmine-mp.git /data --recursive \
 && cd pocketmine-mp \
 && composer install --no-dev --classmap-authoritative

RUN apk del build-dependencies

EXPOSE 19132
VOLUME ["/data"]
WORKDIR /data

CMD ["./start.sh" "-r"]
#CMD ["/docker-start.sh"]
