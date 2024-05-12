FROM debian:stable-slim as builder

# VERSION of BItcoin Core to be build
ARG VERSION=27.0

ENV DEBIAN_FRONTEND=non-interactive

RUN apt-get update && apt-get install -y \
  build-essential \ 
  automake pkg-config  \
  wget curl libzmq3-dev \
  libtool autotools-dev \ 
  bsdmainutils python3 git \ 
  libsqlite3-dev libdb-dev \
  libdb++-dev libevent-dev \ 
  libboost-dev libboost-system-dev \
  libboost-filesystem-dev libboost-test-dev

RUN wget -qO- https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz | tar -xvz

WORKDIR /bitcoin-$VERSION

RUN ./autogen.sh
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
RUN make -j$(( $(nproc) + 1 ))

FROM debian:stable-slim

ENV DEBIAN_FRONTEND=non-interactive

# Only install what we need at runtime
RUN apt-get update && apt-get install -y \
    libminiupnpc-dev libnatpmp-dev libevent-dev libzmq3-dev libsqlite3-dev

COPY --from=builder /bitcoin/src/bitcoind /usr/local/bin/
COPY --from=builder /bitcoin/src/bitcoin-cli /usr/local/bin/

VOLUME /root/bitcoin/.bitcoin

CMD ["bitcoind", "-printtoconsole"]