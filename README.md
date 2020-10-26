This image is compiled with `ENV TZ=America/Los_Angeles`

# To change the timezone compile your own image.
## To Build

#### Set latest version and your docker hub username:

`BLACKMORE_VERSION=2.13.2.6`

`USERNAME=danielclough`

#### Create `Dockerfile.ubase` with Local Time Zone:
```
FROM ubuntu

# Set Local Time Zone
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt-get install -yqq \
                          git \ 
                          make \
                          file \
                          autoconf \
                          automake \ 
                          libtool \
                          libevent-dev \
                          build-essential \
                          autotools-dev \
                          pkg-config \
                          bsdmainutils \
                          python3 \
                          libevent-dev \
                          libboost-all-dev \
                          libminiupnpc-dev \
                          libzmq3-dev \
                          libssl-dev \
                          gperf \
                          wget
RUN git clone https://github.com/danielclough/blackcoin-more.git
RUN (wget https://admin.blackcoin.nl/static/db-6.2.38.NC.tar.gz && \
      tar -xvf db-6.2.38.NC.tar.gz && \
      cd db-6.2.38.NC/build_unix && \
      mkdir -p build && \
      BDB_PREFIX=$(pwd)/build && \
      ../dist/configure --disable-shared --enable-cxx --with-pic  --prefix=$BDB_PREFIX && \
      make install && \
      cd ../.. && \
      cd blackcoin-more/  && ./autogen.sh && \
      ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/" --disable-tests --disable-bench --enable-reduce-exports && \
      make -j4 && \
      cd src/ && \
      strip blackmore*)
```

#### Create `Dockerfile.ubuild` with Local Time Zone:
```
FROM blackmore-ubase as build

RUN echo "In build stage"

FROM ubuntu

# Set Local Time Zone
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
	apt-get  -yqq upgrade && \
	apt-get  -yqq install \
						libboost-all-dev \
						libzmq3-dev \ 
						libminiupnpc-dev 

# Copy the binaries from ubuild to blackcoin-more-ubuntu
COPY --from=build /blackcoin-more/src/blackmored /usr/local/bin
COPY --from=build /blackcoin-more/src/blackmore-cli /usr/local/bin

# Expose the port for the RPC interface
EXPOSE 15714/tcp
```

#### Docker Build
`docker build -f Dockerfile.ubase -t blackmore-ubase . && docker build -f Dockerfile.ubuild -t blackcoin-more-ubuntu .`

#### Upload to docker hub

`docker image tag blackcoin-more-ubuntu $USERNAME/blackcoin-more-ubuntu:$BLACKMORE_VERSION`

`docker image push $USERNAME/blackcoin-more-ubuntu:$BLACKMORE_VERSION`






To Build for Alpine: (broken)

docker build -f ~/blackcoin-more-docker/moreBuilder/Dockerfile.abase -t blackmore-abase . && \
docker build -f ~/blackcoin-more-docker/moreBuilder/Dockerfile.abuild -t blackcoin-more-alpine .
