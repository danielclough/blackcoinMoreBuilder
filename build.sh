#!/bin/bash

# info

BASE_DIR=$(dirname $(realpath $0 ))
moreBuilder=${BASE_DIR}/moreBuilder

defaultBranch=v2.13.2.7
defaultUsername=blackcoinnl
read -p "Are you ${defaultUsername}? (default yes, type your username to change): " USERNAME
USERNAME=${USERNAME:-${defaultUsername}}
if [ $USERNAME != $defaultUsername ]; then
	sed -i "s/defaultUsername=blackcoinnl/defaultUsername=$USERNAME/" $0
fi
echo ${USERNAME}
SYSTYPE=`lscpu | head -1 | tr -s ' ' | cut -d ' ' -f2`
echo $SYSTYPE
read -p "What version? (default $defaultBranch)" BRANCH
BRANCH=${BRANCH:-${defaultBranch}}
if [ $BRANCH != $defaultBranch ]; then
	sed -i "s/defaultBranch=v2.13.2.7/defaultBranch=$BRANCH/" $0
fi

# change names for multi-stage build

defaultUbase=blackcoinnl/blackmore-ubase-x86_64:v2.13.2.7
ubase="${USERNAME}/blackmore-ubase-$SYSTYPE:$BRANCH"
if [ $defaultUbase != $ubase ]; then
	cat ${moreBuilder}/Dockerfile.ubuntu
	sed -i "s|FROM $defaultUbase as build|FROM $ubase as build|" ${BASE_DIR}/Dockerfile.ubuntu
	sed -i "s|FROM $defaultUbase as build|FROM $ubase as build|" ${BASE_DIR}/Dockerfile.minimal
	sed -i "s|defaultUbase=blackcoinnl/blackmore-ubase-x86_64:v2.13.2.7|defaultUbase=$ubase|" $0
fi

ubuntu="${USERNAME}/blackcoin-more-ubuntu-$SYSTYPE:$BRANCH"
minimal="${USERNAME}/blackcoin-more-minimal-$SYSTYPE:$BRANCH"

# build

docker build -t $ubase - --network=host < ${BASE_DIR}/Dockerfile.ubase

docker run -itd  --network=host --name ubase $ubase bash

docker cp ubase:/parts $moreBuilder
cd $moreBuilder
tar -C parts -c . | docker import - $minimal

docker container rm -f ubase

# push to docker hub

docker image push $minimal
docker image push $ubuntu