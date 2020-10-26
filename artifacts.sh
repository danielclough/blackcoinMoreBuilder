SYSTYPE=x86_64
BLACKMORE_VERSION=2.13.2.6
USERNAME=danielclough
BASE_DIR=~/BlackcoinMore
BUILDER_DIR=${BASE_DIR}/moreBuilder

docker run -itd -p 15714:15714 -v ${BASE_DIR}/.blackmore:/.black-coin-more danielclough/blackcoin-more-${SYSTYPE}:${BLACKMORE_VERSION} blackmored


docker run -it -v ${BUILDER_DIR}/blackmore-parts:/parts danielclough/blackcoin-more-ubuntu:${BLACKMORE_VERSION}

docker exec danielclough/blackcoin-more-ubuntu:${BLACKMORE_VERSION} \
	cd parts
	cp --parents /usr/local/bin/blackmored ./
	for i in `ldd /usr/local/bin/blackmored | grep -v linux-vdso.so.1 | awk {' if ( $3 == "") print $1; else print $3 '}`; do cp --parents $i ./ ; done \
	cp --parents /usr/local/bin/blackmore-cli ./ \
	for i in `ldd /usr/local/bin/blackmore-cli | grep -v linux-vdso.so.1 | awk {' if ( $3 == "") print $1; else print $3 '}`; do cp --parents $i ./ ; done \
	exit \




cd ${BUILDER_DIR}

tar -C blackmore-parts -c . | docker import - blackcoin-more-${SYSTYPE}

docker image tag blackcoin-more-${SYSTYPE} ${USERNAME}/blackmore-${SYSTYPE}:${BLACKMORE_VERSION}

docker image push $USERNAME/blackcoin-more-${SYSTYPE}:${BLACKMORE_VERSION}



docker exec blackcoin-more-minimal ls
