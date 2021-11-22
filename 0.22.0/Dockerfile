FROM debian:stable as builder

# VERSION of BItcoin Core to be build
ARG VERSION=22.0

RUN apt-get update && apt-get install -y \
  wget curl build-essential \ 
  libtool autotools-dev \ 
  automake pkg-config  \
  bsdmainutils  python3 \ 
  libsqlite3-dev libdb-dev \
  libdb++-dev libevent-dev \ 
  libboost-dev libboost-system-dev \
  libboost-filesystem-dev libboost-test-dev

RUN wget -qO- https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz | tar -xvz

WORKDIR /bitcoin-$VERSION

RUN  ./autogen.sh

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
  --with-sqlite=yes \
  --without-miniupnpc \
  --with-incompatible-bdb

RUN make clean
RUN make -j$(( $(nproc) + 1 )) check
RUN make install

RUN mv ./src/bitcoind /bitcoind && \
  mv ./src/bitcoin-cli /bitcoin-cli

FROM debian:buster-slim

RUN apt-get update && apt-get install -y libboost-filesystem-dev \
  libboost-thread-dev \
  libevent-dev \
  libsodium-dev \
  libdb-dev \
  libzmq3-dev \
  libsqlite3-dev 

RUN useradd -ms /bin/bash bitcoin
USER bitcoin


COPY --from=builder /bitcoind /usr/local/bin/bitcoind
COPY --from=builder /bitcoin-cli /usr/local/bin/bitcoin-cli

# Prevents `VOLUME $HOME/.bitcoin/` being created as owned by `root`
RUN mkdir -p "$HOME/.bitcoin/"

ENTRYPOINT [ "bitcoind" ]

