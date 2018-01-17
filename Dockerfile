FROM php:7.2-zts-alpine3.7

# Set version label.
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Circle Eh! version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chris.poupart@gmail.com"

# Global environment settings
# As per the documentation, only Development and Alpha are currently being
# produced as PocketMine is under heavy development.
# See: http://pmmp.readthedocs.io/en/rtfd/links.html#downloads
#ENV POCKETMINE_CHANNEL="Alpha"
# Jenkins is down at the time of writing this, and so we will use the assets available on GitHub
ENV POCKETMINE_PHAR_URL "https://github.com/pmmp/PocketMine-MP/releases/download/1.7dev-516/PocketMine-MP_1.7dev-516_fbd04b0f_API-3.0.0-ALPHA10.phar"

# Install the dependencies
RUN apk --update --no-cache \
        add bash \
            ca-certificates \
            curl \
            file \
            ncurses \
            rsync \
            yaml \
            zlib \
 && update-ca-certificates \
 && apk --update --no-cache --virtual build-dependencies \
        add autoconf \
            automake \
            bison \
            g++ \
            git \
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
 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/pecl_yaml.ini \
 && git clone -b master --single-branch https://github.com/krakjoe/pthreads.git \
 && cd pthreads \
 && phpize \
 && ./configure \
 && make \
 && cp modules/pthreads.so /usr/local/lib/php/extensions/no-debug-zts-20170718/pthreads.so \
 && echo "extension=pthreads.so" > /usr/local/etc/php/conf.d/git_pthreads.ini \
 && cd .. && rm -rf pthreads \
 && apk del build-dependencies
# Installing ptshread from git is a workaround until 3.1.7 is released, at 
# which point we will install with pecl, as per above.
# See: https://github.com/krakjoe/pthreads/issues/779

# Now we setup PocketMine
RUN bash -c "mkdir -p /pocketmine/{players,plugins,resource_packs,worlds}" \
 && cd pocketmine \
 && curl -fsSL https://raw.githubusercontent.com/pmmp/PocketMine-MP/master/start.sh -o start.sh \
 && chmod +x start.sh \
 && curl -fsSL "$POCKETMINE_PHAR_URL" -o PocketMine-MP.phar

COPY src/server.properties src/docker-start.sh /pocketmine/

EXPOSE 19132 19132/udp

VOLUME /config /pocketmine/players /pocketmine/plugins /pocketmine/resource_packs /pocketmine/worlds
WORKDIR /pocketmine

CMD ["./docker-start.sh"]