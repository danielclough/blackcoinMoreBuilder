SYSTYPE=arm8
BLACKMORE_VERSION=2.13.2.6
USERNAME=danielclough

cd ~/BlackcoinMore/moreBuilder/blackmore-parts
cp --parents /usr/local/bin/blackmored ./
for i in `ldd ~/more/blackmored | grep -v linux-vdso.so.1 | awk {' if ( $3 == "") print $1; else print $3 '}`; do cp --parents $i ./ ; done 
cp --parents /usr/local/bin/blackmore-cli ./ 
for i in `ldd ~/more/blackmore-cli | grep -v linux-vdso.so.1 | awk {' if ( $3 == "") print $1; else print $3 '}`; do cp --parents $i ./ ; done 
exit 

cd ~/BlackcoinMore/moreBuilder/

tar -C blackmore-parts -c . | docker import - blackcoin-more-${SYSTYPE}

docker image tag blackcoin-more-${SYSTYPE} ${USERNAME}/blackcoin-more-${SYSTYPE}:${BLACKMORE_VERSION}

docker image push $USERNAME/blackcoin-more-${SYSTYPE}:${BLACKMORE_VERSION}


# docker run -itd -p 15714:15714 -v ~/BlackcoinMore/.blackmore:/.blackmore danielclough/blackmore-${SYSTYPE} blackcoinMored:${BLACKMORE_VERSION}
