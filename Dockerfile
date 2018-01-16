FROM alpine

# PocketMine requires reading and agreeing to their EULA.
# https://github.com/pmmp/PocketMine-MP/blob/master/LICENSE
ARG AGREE_EULA=false
ENV EULA=$AGREE_EULA

#RUN apk add --no-cache
RUN apk --update \
        --no-cache add autoconf \
                     automake \
                     bash \
                     bison \
                     ca-certificates \
                     g++ \
                     gcc \
                     libtool \
                     m4 \
                     make \
                     wget \
 && update-ca-certificates

RUN if [ "$EULA" = "true" ]; then echo 'eula=true' > /; fi

COPY installer.sh /
COPY docker-start.sh /

RUN adduser -S -h /data -s /bin/bash -u 1000 minecraft

EXPOSE 19132
VOLUME ["/data"]
WORKDIR /data

CMD ["/docker-start.sh"]
