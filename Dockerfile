# !/usr/bin docker build
# coding:utf-8
# Copyright (C) 2019-2021 All rights reserved.
# FILENAME:  Dockerfile
# VERSION: 	 1.0
# CREATED: 	 2021-04-11 13:48
# AUTHOR: 	 Aekasitt Guruvanich <sitt@coinflex.com>
# DESCRIPTION:
#
# HISTORY:
#*************************************************************
FROM alpine:3.13.4
LABEL MAINTAINER 'Aekasitt Guruvanich <sitt@coinflex.com>'

# versions
ARG GCC_VERSION=8.4.0
ARG GO_VERSION=1.16.3
ARG MOEINGEVM_VERSION=0.1.0
ARG ROCKSDB_VERSION=6.15.5

# install essential image dependencies
RUN essentials=" \
    bash \
    build-base \
    cmake \
    dejagnu \
    git \
    gmp \
    isl-dev \
    linux-headers \
    mpc1 mpc1-dev \
    mpfr-dev \
    musl musl-dev \
    zlib zlib-dev \
  " && apk add --update --no-cache $essentials;

# download specific version of `gcc`
RUN cd /tmp && \
  wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
  tar -xzf gcc-${GCC_VERSION}.tar.gz && \
  rm -f gcc-${GCC_VERSION}.tar.gz && \
  cd gcc-${GCC_VERSION} && \
  ./configure \
    --prefix=/usr/local \
    --build=$(uname -m)-alpine-linux-musl \
    --host=$(uname -m)-alpine-linux-musl \
    --target=$(uname -m)-alpine-linux-musl \
    --with-pkgversion="Alpine ${GCC_VERSION}" \
    --enable-checking=release \
    --disable-fixed-point \
    --disable-libmpx \
    --disable-libmudflap \
    --disable-libsanitizer \
    --disable-libssp \
    --disable-libstdcxx-pch \
    --disable-multilib \
    --disable-nls \
    --disable-symvers \
    --disable-werror \
    --enable-__cxa_atexit \
    --enable-default-pie \
    --enable-languages=c,c++ \
    --enable-shared \
    --enable-threads \
    --enable-tls \
    --with-linker-hash-style=gnu \
    --with-system-zlib && \
  make --silent -j $(nproc) && \
  make --silent -j $(nproc) install-strip && \
  ln -s /usr/bin/gcc /usr/local/bin/cc && \
  rm -R /tmp/gcc-${GCC_VERSION}

# install `golang`
RUN apk add --no-cache go && \
  cd /tmp && \
  wget -O go.tgz https://golang.org/dl/go${GO_VERSION}.src.tar.gz  && \
  tar -C /usr/local -xzf go.tgz && \
  rm -f go.tgz && \
  cd /usr/local/go/src/ && \
  ./make.bash && \
  apk del go
# configure `golang`
ENV PATH /usr/local/go/bin:$PATH
ENV GOPATH /opt/go/ 
ENV PATH $PATH:$GOPATH/bin

# install misc. build dependencies
RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories
RUN buildDeps=" \
    bzip2          bzip2-dev \
    gflags-dev \
    libtbb@testing libtbb-dev@testing \
    lz4            lz4-dev \
    snappy         snappy-dev \
    zstd           zstd-dev \
  " && apk add --update --no-cache $buildDeps;

# install `facebook/rocksdb`
RUN cd /tmp && \
  git clone --depth 1 --branch v${ROCKSDB_VERSION} https://github.com/facebook/rocksdb.git && \
  cd rocksdb && \
  sed -i 's/install -C/install -c/g' Makefile && \
  make shared_lib && \
  make install-shared && \
  rm -R /tmp/rocksdb
ENV ROCKSDB_PATH="$HOME/usr/local/rocksdb"
ENV CGO_CFLAGS="-I/$ROCKSDB_PATH/include"
ENV CGO_LDFLAGS="-L/$ROCKSDB_PATH -lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy -llz4 -lzstd"
ENV LD_LIBRARY_PATH=$ROCKSDB_PATH:/usr/lib

# clone the moeingevm repo, and build dynamically linked library
RUN cd /tmp && \
  git clone https://github.com/smartbch/moeingevm.git && \
  cd moeingevm && \
  git checkout v${MOEINGEVM_VERSION} && \
  cd evmwrap && make && \
  mkdir -p /usr/local/moeingevm/evmwrap && \
  cp -r /tmp/moeingevm/evmwrap/* /usr/local/moeingevm/evmwrap/ && \
  rm -R /tmp/moeingevm
ENV EVMWRAP=/usr/local/moeingevm/evmwrap/host_bridge/libevmwrap.so

# clone the source code of `smartbch` and build the executable of smartbchd.
RUN cd /tmp && \
  git clone https://github.com/smartbch/smartbch.git && \
  cd smartbch && \
  go install ./... && \
  rm -R /tmp/smartbch

EXPOSE 8545
VOLUME [ "/root/.smartbchd" ]
ENTRYPOINT [ "smartbchd" ]