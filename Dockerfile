FROM buildpack-deps:bullseye as builder

WORKDIR /build

RUN apt update && apt install -y git bison pkg-config cmake devscripts debconf \
debhelper automake bison ca-certificates \
libcurl4-openssl-dev cmake debhelper libaio-dev \
libncurses-dev libssl-dev libtool zlib1g-dev libgcrypt20-dev libev-dev \
lsb-release build-essential rsync libdbd-mysql-perl \
libnuma1 socat librtmp-dev libtinfo5 vim-common \
libudev-dev libprocps-dev doxygen \
liblz4-tool liblz4-1 liblz4-dev libzstd1

RUN --mount=type=bind,source=./percona-xtrabackup,target=/build/percona-xtrabackup \
    --mount=type=cache,target=/build/boost \
    mkdir -p /build/output && cd /build/output && \
    cmake -DWITH_DEBUG=0 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/build/boost -DBUILD_CONFIG=xtrabackup_release -DWITH_MAN_PAGES=0 /build/percona-xtrabackup

RUN --mount=type=bind,source=./percona-xtrabackup,target=/build/percona-xtrabackup \
    --mount=type=cache,target=/build/boost \
    cd /build/output && \
    make -j$(nproc --all) && \
    strip ./bin/x*

#RUN --mount=type=cache,target=/build/output \
#    mkdir /build/bin/ && cp -f /build/output/bin/x* /build/bin/


FROM debian:11-slim

RUN apt update && apt install -y libaio1 libprocps8 libev4 libcurl4 libzstd1 && apt clean && rm -rf /var/cache/apt/*
COPY --from=builder /build/output/bin/x* /usr/bin/

ENTRYPOINT ["/usr/bin/xtrabackup"]
