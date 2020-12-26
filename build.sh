#!/bin/bash

BASE_DIR=$(dirname $(realpath $0 ))
Alist="\n
\t \t \t aarch64-linux-gnu \n
\t \t \t arm-linux-gnueabihf \n
\t \t \t x86_64-linux-gnu \n
"

usage="Usage: \n \t 
\`build.sh -o <architecture> <DockerHub> <HubLab> <repository> <branch> <timezone>\` \t for option mode. \n \n
\t \t \t \t \t \t \t \t \t \t \`build.sh -i\` \t for interactive mode. \n \n
\t \t \t \t \t \t \t \t \t \t \`build.sh -h\` \t for help mode. \n \n
"

h1="<architecture> Choose one of the following: ${Alist}"
h2="<DockerHub> \t Enter your Docker Hub account name."
h3="<HubLab> \t Enter \`github\` or \`gitlab\`."
h4="<repository> \t Enter the repository name."
h5="<branch> \t Enter the branch name."
h6="<timezone> \t Enter your timezone."

help="
\n $h1 \n
\n $h2 \n
\n $h3 \n
\n $h4 \n
\n $h5 \n
\n $h6 \n
"

case $1 in

-h)
	echo -e ${help}
;;

-i|-o)


# Architecture

defaultARCH=${${2}:-x86_64-linux-gnu}
echo -e ${Alist}
read -p "For what architecture would you like to build? ($defaultARCH): " architecture
architecture=${architecture:-${defaultARCH}}
if [ $DockerHub != $defaultDockerHub ]; then
	sed -i "s/defaultARCH=x86_64-linux-gnu/defaultARCH=$architecture/" $0
fi

# DockerHub Account

defaultDockerHub=${${3}:-blackcoinnl}
read -p "What is your DockerHub Account Name? ($defaultDockerHub): " DockerHub
DockerHub=${DockerHub:-${defaultDockerHub}}
if [ $DockerHub != $defaultDockerHub ]; then
	sed -i "s/defaultDockerHub=blackcoinnl/defaultDockerHub=$DockerHub/" $0
fi

# Git Account

defaultHubLab=${${4}:-github}
read -p "Github or Gitlab? ($defaultHubLab): " HubLab
HubLab=${HubLab:-${defaultHubLab}}
if [ $HubLab != $defaultHubLab ]; then
	sed -i "s|defaultHubLab=github|defaultHubLab=$HubLab|" $0
	sed -i "s|github|$HubLab|" ${BASE_DIR}/Dockerfile.ubase
fi

defaultRepo=${${5}:-CoinBlack}
read -p "What is your repository name? ($defaultRepo): " repository
repository=${repository:-${defaultRepo}}
if [ ${repository} != ${defaultRepo} ]; then
	sed -i "s|defaultRepo=CoinBlack|defaultRepo=$repository|" $0
	sed -i "s|CoinBlack|$repository|" ${BASE_DIR}/Dockerfile.ubase
fi

# branch

defaultBranch=${${6}:-master}
read -p "What branch/version? ($defaultBranch): " branch
branch=${branch:-${defaultBranch}}
if [ ${branch} != ${defaultBranch} ]; then
	sed -i "s|defaultBranch=master|defaultBranch=$branch|" $0
	sed -i "s|ENV branch=v2.13.2.7|ENV branch=$branch|" ${BASE_DIR}/Dockerfile.ubase
fi

# timezone
defaultTimezone=${${7}:-America/Los_Angeles}
read -p "What is your timezone? (${defaultTimezone}): " timezone
timezone=${timezone:-${defaultTimezone}}
if [ ${timezone} != ${defaultTimezone} ]; then
	sed -i "s|defaultTimezone=America/Los_Angeles|defaultTimezone=$timezone|" $0
	sed -i "s|defaultTimezone=America/Los_Angeles|$timezone|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|defaultTimezone=America/Los_Angeles|$timezone|" ${BASE_DIR}/Dockerfile.ubuntu
fi


echo "Architecture: ${architecture}"
echo "DockerHub Account: ${DockerHub}"
echo "repository Account: ${HubLab}.com/${repository} ${branch}"
echo ${timezone}

# build ubase

# set current
Dockerfile="${BASE_DIR}/Dockerfile.${base}"
docker build -t ubase-base --network=host - < ${Dockerfile} 

# build ubase
ubase="ubase-${architecture}"
Dockerfile="${BASE_DIR}/${architecture}/Dockerfile.${ubase}"
docker build ./${architecture} -t ${ubase} --network=host -f ${Dockerfile}

# build ubuntu
ubuntu="ubuntu-${architecture}"
Dockerfile="${BASE_DIR}/${architecture}/Dockerfile.${ubuntu}"
docker build -t ${ubuntu} - --network=host < ${Dockerfile}
docker image tag ${ubuntu} ${DockerHub}/blackcoin-more-ubuntu-${architecture}:latest

# build minimal
minimal="minimal-${architecture}"
docker run -itd --network=host --name ${ubase} ${ubase} bash
docker cp ${ubase}:${architecture}/parts ${architecture}/parts
cd ${BASE_DIR}/${architecture}
tar -C parts -c . | docker import - ${minimal}
docker container rm -f ${ubase}
docker tag ${minimal} ${DockerHub}/blackcoin-more-minimal-${architecture}:latest
;;
*)
echo -e ${usage}
;;
esac