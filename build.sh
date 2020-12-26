#!/bin/bash

BASE_DIR=$(dirname $(realpath $0 ))
Alist="\n
\t \t \t \t aarch64-linux-gnu \t (eg. Raspi4 with Ubuntu) \n
\t \t \t \t arm-linux-gnueabihf \t (eg. Other Raspi) \n
\t \t \t \t x86_64-linux-gnu \t (aka. Linux AMD64) \n
"

usage="Usage: \n 
\t option mode: \t \`build.sh -o <architecture> <DockerHub> <HubLab> <GitAccount> <branch> <timezone>\` \n
\t interactive: \t \`build.sh -i\` \n 
\t \t \t help: \t \`build.sh -h\` \n 
\n Architectures: ${Alist} \n
"

h1="<architecture>  \t Choose your architecture. ${Alist}"
h2="<DockerHub> \t \t Enter your Docker Hub Account name."
h3="<HubLab> \t \t \t Enter \"github\" or \"gitlab\"."
h4="<GitAccount> \t Enter the git account name. (eg. \"CoinBlack\" on GitHub, or \"blackcoin\" on GitLab)"
h5="<branch> \t \t \t Enter the branch name."
h6="<timezone> \t \t Enter your timezone."

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

defaultARCH=${2:-x86_64-linux-gnu}
echo -e ${Alist}
read -p "For what architecture would you like to build? ($defaultARCH): " architecture
architecture=${architecture:-${defaultARCH}}
if [ ${architecture} != ${defaultARCH} ]; then
	sed -i "s/-x86_64-linux-gnu/-${architecture}/" $0
fi


if [[ -f ${BASE_DIR}/depends-${architecture}.tar.xz ]]; then
	echo "Dependencies exist!" 
else
	wget -O ${BASE_DIR}/depends-${architecture}.tar.xz https://admin.blackcoin.nl/static/depends-${architecture}.tar.xz > /dev/null

	case $architecture in
	aarch64-linux-gnu)
		checkSUM=`echo "f6f1b099d876db90396d0d56eb5b3f366f14c90e077524e2b10bfdaaa1aa5805 ${BASE_DIR}/depends-${architecture}.tar.xz" | sha256sum --check | awk '{print $2}' 2> /dev/null`
		[[ "${checkSUM}" != "OK" ]] && echo 'SHASUM FAIL' && exit 1
		tar xJf ${BASE_DIR}/depends-${architecture}.tar.xz -C ${BASE_DIR}
	;;
	arm-linux-gnueabihf)
		checkSUM=`echo "339c1159adcccecb45155b316f1f5772009b92acb8cfed29464dd7f09775fb79 ${BASE_DIR}/depends-${architecture}.tar.xz" | sha256sum --check | awk '{print $2}' 2> /dev/null`
		[[ "${checkSUM}" != "OK" ]] && echo 'SHASUM FAIL' && exit 1
		tar xJf ${BASE_DIR}/depends-${architecture}.tar.xz -C ${BASE_DIR}
	;;
	x86_64-linux-gnu)
		checkSUM=`echo "eed063b26f4c4e0fa35dc085fe09bafd4251cffa76cdabb26bf43077da03b84e ${BASE_DIR}/depends-${architecture}.tar.xz" | sha256sum --check | awk '{print $2}' 2> /dev/null`
		[[ "${checkSUM}" != "OK" ]] && echo 'SHASUM FAIL' && exit 1
		tar xJf ${BASE_DIR}/depends-${architecture}.tar.xz -C ${BASE_DIR}
	;;
	esac
	echo -e "
	Dependencies SHA256SUM GOOD!
	"
fi



# DockerHub Account

defaultDockerHub=${3:-blackcoinnl}
read -p "What is your DockerHub Account Name? ($defaultDockerHub): " DockerHub
DockerHub=${DockerHub:-${defaultDockerHub}}
if [ $DockerHub != $defaultDockerHub ]; then
	sed -i "s/blackcoinnl/$DockerHub/" $0
fi

# Git Account

defaultHubLab=${4:-github}
read -p "Github or Gitlab? ($defaultHubLab): " HubLab
HubLab=${HubLab:-${defaultHubLab}}
if [ $HubLab != $defaultHubLab ]; then
	sed -i "s|github|$HubLab|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|github|$HubLab|" $0
fi

defaultRepo=${5:-CoinBlack}
read -p "What is your GitAccount name? ($defaultRepo): " GitAccount
GitAccount=${GitAccount:-${defaultRepo}}
if [ ${GitAccount} != ${defaultRepo} ]; then
	sed -i "s|CoinBlack|$GitAccount|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|CoinBlack|$GitAccount|" $0
fi

# branch

defaultBranch=${6:-v2.13.2.7}
read -p "What branch/version? ($defaultBranch): " branch
branch=${branch:-${defaultBranch}}
if [ ${branch} != ${defaultBranch} ]; then
	sed -i "s|ENV branch=v2.13.2.7|ENV branch=${branch}|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|v2.13.2.7|${branch}|" $0
fi

# timezone
defaultTimezone=${7:-America/Los_Angeles}
read -p "What is your timezone? (${defaultTimezone}): " timezone
timezone=${timezone:-${defaultTimezone}}
if [ ${timezone} != ${defaultTimezone} ]; then
	sed -i "s|America/Los_Angeles|${timezone}|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|America/Los_Angeles|${timezone}|" ${BASE_DIR}/Dockerfile.ubuntu
	sed -i "s|America/Los_Angeles|${timezone}|" $0
fi


echo "Architecture: ${architecture}"
echo "DockerHub Account: ${DockerHub}"
echo "Git Account: ${HubLab}.com/${GitAccount} ${branch}"
echo ${timezone}

# build ubase-base
Dockerfile="${BASE_DIR}/Dockerfile.ubase-base"
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