FROM debian:stable-slim as builder

ENV DEBIAN_FRONTEND=non-interactive

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

RUN git clone https://github.com/bitcoin/bitcoin.git /bitcoin

WORKDIR /bitcoin

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

RUN useradd -ms /bin/bash bitcoin
USER bitcoin
WORKDIR /home/bitcoin

# Only install what we need at runtime
RUN apt-get update && apt-get install -y \
  libminiupnpc-dev libnatpmp-dev libevent-dev libzmq3-dev libsqlite3-dev

COPY --from=builder /bitcoin/src/bitcoind /usr/local/bin/
COPY --from=builder /bitcoin/src/bitcoin-cli /usr/local/bin/

EXPOSE 18443 18444

# Prevents `VOLUME $HOME/.bitcoin/` being created as owned by `root`
RUN mkdir -p "$HOME/.bitcoin/"
COPY bitcoin.conf "$HOME/bitcoin.conf"

VOLUME /home/bitcoin/.bitcoin

ENTRYPOINT ["bitcoind", "-printtoconsole"]