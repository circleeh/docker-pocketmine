FROM php:7.2-zts-alpine3.7

# Set version label.
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Circle Eh! version: ${VERSION} Build-date: ${BUILD_DATE}"
LABEL maintainer="chris.poupart@gmail.com"

ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL

# Global environment settings

# set the version for the s6 overlay
ARG OVERLAY_VERSION="v1.22.1.0"
ARG OVERLAY_ARCH="amd64"

# As per the documentation, only Development and Alpha are currently being
# produced as PocketMine is under heavy development.
# See: http://pmmp.readthedocs.io/en/rtfd/links.html#downloads

ARG POCKETMINE_CHANNEL="Alpha"
ENV PMMP_CHANNEL=$POCKETMINE_CHANNEL
ARG POCKETMINE_RELEASE="PocketMine-MP_1.7dev-516_fbd04b0f_API-3.0.0-ALPHA10.phar"
ENV PMMP_RELEASE=$POCKETMINE_RELEASE
ENV POCKETMINE_PHAR_URL "https://jenkins.pmmp.io/job/PocketMine-MP/${PMMP_CHANNEL}/artifact/${PMMP_RELEASE}"

# Install the dependencies
RUN \
 echo "**** install the runtime packages ****" \
 && apk --update --no-cache \
        add bash \
            ca-certificates \
            curl \
            coreutils \
            file \
            ncurses \
            shadow \
            tzdata \
            rsync \
            yaml \
            zlib \
 && update-ca-certificates \
 && echo "**** install the build packages ****" \
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
 && echo "**** install the extra php modules ****" \
 && docker-php-ext-install -j$(nproc) bcmath mysqli sockets zip \
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
 && echo "**** add s6 overlay ****" \
 && curl -o \
            /tmp/s6-overlay.tar.gz -L \
            "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
 && tar zxf /tmp/s6-overlay.tar.gz -C / \
 && echo "**** create minecraft user and make our folders ****" \
 && groupmod -g 1000 users \
 && useradd -u 911 -U -d /config -s /bin/false minecraft \
 && usermod -G users minecraft \
 && echo "**** cleanup ****" \
 && apk del --purge build-dependencies \
 && rm -rf /tmp/*
# NOTE: Installing ptshread from git is a workaround until 3.1.7 is released,
# at which point we will install with pecl, as per above.
# See: https://github.com/krakjoe/pthreads/issues/779

# Now we setup PocketMine
RUN bash -c "mkdir -p /pocketmine" \
 && cd pocketmine \
 && curl -fsSL "$POCKETMINE_PHAR_URL" -o PocketMine-MP.phar

# Add local files
COPY src/ /

EXPOSE 19132 19132/udp

VOLUME /config
WORKDIR /pocketmine

ENTRYPOINT ["/init"]
#CMD ["./start.sh", "--no-wizard"]
