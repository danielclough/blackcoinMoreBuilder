#!/bin/bash

BASE_DIR=$(dirname $(realpath $0 ))

# Architecture

Alist="\n
aarch64-linux-gnu, \n
arm-linux-gnueabihf, \n
x86_64-linux-gnu"

defaultARCH=x86_64-linux-gnu
echo -e ${Alist}
read -p "For what architecture would you like to build? ($defaultARCH): " ARCH
ARCH=${ARCH:-${defaultARCH}}
if [ $DockerHub != $defaultDockerHub ]; then
	sed -i "s/defaultARCH=x86_64-linux-gnu/defaultARCH=$ARCH/" $0
fi

# DockerHub Account

defaultDockerHub=blackcoinnl
read -p "What is your DockerHub Account Name? ($defaultDockerHub): " DockerHub
DockerHub=${DockerHub:-${defaultDockerHub}}
if [ $DockerHub != $defaultDockerHub ]; then
	sed -i "s/defaultDockerHub=blackcoinnl/defaultDockerHub=$DockerHub/" $0
fi

# Git Account

defaultHubLab=github
read -p "Github or Gitlab? ($defaultHubLab): " HubLab
HubLab=${HubLab:-${defaultHubLab}}
if [ $HubLab != $defaultHubLab ]; then
	sed -i "s|defaultHubLab=github|defaultGit=$HubLab|" $0
	sed -i "s|github|$HubLab|" ${BASE_DIR}/Dockerfile.ubase
fi

defaultGit=CoinBlack
read -p "What is your Git account? ($defaultGit): " Git
Git=${Git:-${defaultGit}}
if [ ${Git} != ${defaultGit} ]; then
	sed -i "s|defaultGit=CoinBlack|defaultGit=$Git|" $0
	sed -i "s|CoinBlack|$Git|" ${BASE_DIR}/Dockerfile.ubase
fi

# Git Branch

defaultBranch=master
read -p "What branch/version? ($defaultBranch): " BRANCH
BRANCH=${BRANCH:-${defaultBranch}}
if [ ${BRANCH} != ${defaultBranch} ]; then
	sed -i "s|defaultBranch=master|defaultBranch=$BRANCH|" $0
	sed -i "s|ENV BRANCH=v2.13.2.7|ENV BRANCH=$BRANCH|" ${BASE_DIR}/Dockerfile.ubase
fi

# timezone
defaultTimezone=America/Los_Angeles
read -p "What is your timezone? (${defaultTimezone}): " timezone
timezone=${timezone:-${defaultTimezone}}
if [ ${timezone} != ${defaultTimezone} ]; then
	sed -i "s|defaultTimezone=America/Los_Angeles|defaultTimezone=$timezone|" $0
	sed -i "s|defaultTimezone=America/Los_Angeles|$timezone|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|defaultTimezone=America/Los_Angeles|$timezone|" ${BASE_DIR}/Dockerfile.ubuntu
fi


echo "Architecture: ${ARCH}"
echo "DockerHub Account: ${DockerHub}"
echo "Git Account: ${Git}"
echo ${BRANCH}
echo ${timezone}

# build ubase

# set current
Dockerfile="${BASE_DIR}/Dockerfile.${base}"
docker build -t ubase-base --network=host - < ${Dockerfile} 

# build ubase
ubase="ubase-${ARCH}"
Dockerfile="${BASE_DIR}/${ARCH}/Dockerfile.${ubase}"
docker build ./${ARCH} -t ${ubase} --network=host -f ${Dockerfile}

# build ubuntu
ubuntu="ubuntu-${ARCH}"
Dockerfile="${BASE_DIR}/${ARCH}/Dockerfile.${ubuntu}"
docker build -t ${ubuntu} - --network=host < ${Dockerfile}
docker image tag ${ubuntu} ${DockerHub}/blackcoin-more-ubuntu-${ARCH}:latest

# build minimal
minimal="minimal-${ARCH}"
docker run -itd --network=host --name ${ubase} ${ubase} bash
docker cp ${ubase}:${ARCH}/parts ${ARCH}/parts
cd ${BASE_DIR}/${ARCH}
tar -C parts -c . | docker import - ${minimal}
docker container rm -f ${ubase}
docker tag ${minimal} ${DockerHub}/blackcoin-more-minimal-${ARCH}:latest