FROM debian:stable-slim as builder

# VERSION of BItcoin Core to be build
ARG VERSION=27.0

RUN apt-get update && apt-get install -y \
  build-essential \ 
  automake pkg-config  \
  wget curl libzmq3-dev \
  libtool autotools-dev \ 
  bsdmainutils python3 \ 
  libsqlite3-dev libdb-dev \
  libdb++-dev libevent-dev \ 
  libboost-dev libboost-system-dev \
  libboost-filesystem-dev libboost-test-dev

RUN wget -qO- https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz | tar -xvz

WORKDIR /bitcoin-$VERSION

RUN cd ./depends && make NO_QT=1 NO_UPNP=1 && cd .. && ./autogen.sh

RUN ./configure \
  CXXFLAGS="-O2" \
  --disable-man \
  --disable-shared \
  --disable-ccache \
  --disable-tests \
  --enable-static \
  --enable-reduce-exports \
  --without-gui \
  --without-libs \
  --with-utils \
  --with-zmq \
  --with-sqlite=yes \
  --without-miniupnpc \
  --with-incompatible-bdb

RUN make clean
RUN make -j$(( $(nproc) + 1 )) check
RUN make install

RUN mv ./src/bitcoind /bitcoind && \
  mv ./src/bitcoin-cli /bitcoin-cli

FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-thread-dev \
  libevent-dev \
  libsodium-dev \
  libdb-dev \
  libdb++-dev \
  libzmq3-dev \
  libsqlite3-dev 

RUN useradd -ms /bin/bash bitcoin
USER bitcoin


COPY --from=builder /bitcoind /usr/local/bin/bitcoind
COPY --from=builder /bitcoin-cli /usr/local/bin/bitcoin-cli

# Prevents `VOLUME $HOME/.bitcoin/` being created as owned by `root`
RUN mkdir -p "$HOME/.bitcoin/"
COPY bitcoin.conf "$HOME/bitcoin.conf"

ENTRYPOINT [ "bitcoind" ]
