FROM alpine:latest

#LABEL org.label-schema.build-date=2023-04-03T22:35:56Z org.label-schema.name=XMRig org.label-schema.description=Kryptokrona (XKR) CPU miner packaged in a lightweight Docker image that you can easily deploy to a Kubernetes cluster. org.label-schema.url=https://xmrig.com/miner org.label-schema.vcs-url=https://github.com/jrkalf/xmrig-kryptokrona org.label-schema.version=6.19.2 maintainer=Jelle Kalf [https://github.com/jrkalf] version=6.19.2
ENV TZ=Europe/Amsterdam PATH=/xmrig:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV VERSION "6.19.2"
ENV XMRIG_USER "xmrig" 
ENV XMRIG_GROUP "xmrig"

WORKDIR /xmrig

COPY config.json .

RUN apk update && \
    apk add --no-cache --virtual .build-deps make cmake libstdc++ gcc g++ automake libtool autoconf bash linux-headers && \
    wget https://github.com/xmrig/xmrig/archive/refs/tags/v${VERSION}.zip && \
    apk add --no-cache tzdata && \
    addgroup -S ${XMRIG_GROUP} && \
    adduser -S -g "XMRig User" -h /tmp -D ${XMRIG_USER} -G ${XMRIG_GROUP} && \
    unzip -q v${VERSION}.zip && \
    mv xmrig-* xmrig-src && \
    mkdir xmrig-src/build && \
    sed -i 's/1;/0;/g' xmrig-src/src/donate.h && \
    cd xmrig-src/scripts && \
    ./build_deps.sh && \
    cd ../build && \
    cmake .. -DXMRIG_DEPS=scripts/deps -DBUILD_STATIC=ON && \
    make -j$(nproc) && \
    mv xmrig ../../ && \
    apk del .build-deps && \
    rm -r /xmrig/xmrig-src /xmrig/*.zip && \
    mkdir /xmrig/etc /xmrig/log && \
    chmod +x /xmrig/xmrig && \
    chown -R ${XMRIG_USER}:${XMRIG_GROUP} /xmrig/log && \
    apk del make cmake libstdc++ gcc g++ automake libtool autoconf bash linux-headers &&\
    rm -rf /var/tmp/ && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

USER xmrig

CMD ["xmrig"]