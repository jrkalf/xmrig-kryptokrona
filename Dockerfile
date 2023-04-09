ARG ARCH=
FROM ${ARCH}ubuntu as prepare

#LABEL org.label-schema.build-date=2023-04-03T22:35:56Z org.label-schema.name=XMRig org.label-schema.description=Kryptokrona (XKR) CPU miner packaged in a lightweight Docker image that you can easily deploy to a Kubernetes cluster. org.label-schema.url=https://xmrig.com/miner org.label-schema.vcs-url=https://github.com/jrkalf/xmrig-kryptokrona org.label-schema.version=6.19.2 maintainer=Jelle Kalf [https://github.com/jrkalf] version=6.19.2
ENV TZ=Europe/Amsterdam
ENV PATH=/xmrig:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV VERSION "6.17.0"
ENV XMRIG_URL=https://github.com/xmrig/xmrig.git

RUN apt update && apt -y install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

RUN git clone ${XMRIG_URL} /xmrig && \
    cd /xmrig && git checkout ${XMRIG_VERSION}

WORKDIR /xmrig/build
RUN sed -i 's/1;/0;/g' ../src/donate.h
RUN cmake .. -DWITH_OPENCL=OFF -DWITH_CUDA=OFF && \
    make -j$(nproc)

ADD config.json /xmrig/build/conf/

###
FROM ${ARCH}ubuntu

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/jrkalf/xmrig-kryptokrona" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc2"

WORKDIR /xmrig

COPY --from=prepare /xmrig/build/conf/config.json /xmrig/config.json
COPY --from=prepare /xmrig/build/xmrig /xmrig/xmrig
RUN apt update \
    && apt -y --no-install-recommends install libuv1 libhwloc15 \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /xmrig/log 

CMD ["/xmrig/xmrig", "-c", "/xmrig/config.json"]
