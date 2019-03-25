#!/bin/bash
set -e

source scripts/multiArchMatrix.sh

showHelp() {
	echo "Usage: $0 -i <image name> -t <tag name> -a <target arch> -b <baseimage branch> -v <version> -r <vcs reference> -g <github token>"
}

while getopts :hi:t:a:b:v:r:g: opt; do
	case ${opt} in
		h)
			showHelp
			exit 0
			;;
		i)
			DOCKER_IMAGE=$OPTARG
			;;
		t)
			DOCKER_TAG=$OPTARG
			;;
		a)
			ARCH=$OPTARG
			;;
		b)
			BASEIMAGE_BRANCH=$OPTARG
			;;
		v)
			VERSION=$OPTARG
			;;
		r)
			VCS_REF=$OPTARG
			;;
		g)
			GITHUB_TOKEN=$OPTARG
			;;
		\?)
			echo "Invalid option: $OPTARG" 1>&2
			showHelp
			exit 1
			;;
		:)
			echo "Invalid option: $OPTARG requires an argument" 1>&2
			showHelp
			exit 1
			;;
		*)
			showHelp
			exit 0
			;;
	esac
done
shift "$((OPTIND-1))"

printf "\\n### Building image ###\\n"
printf "Docker image: $DOCKER_IMAGE\\n"
printf "Docker tag: $DOCKER_TAG\\n"

printf "Architecture: $ARCH\\n"
printf "Baseimage branch: $BASEIMAGE_BRANCH\\n"
printf "Image version: $VERSION\\n"
printf "VCS reference: $VCS_REF\\n"
printf "\\n"

BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

cmdBuilt="docker build"
cmdBuilt+=" --build-arg BUILD_DATE=$BUILD_DATE"
if [[ ! -z $ARCH ]]; then
	cmdBuilt+=" --build-arg ARCH=$ARCH"
fi
if [[ ! -z $BASEIMAGE_BRANCH ]]; then
	cmdBuilt+=" --build-arg BASEIMAGE_BRANCH=$BASEIMAGE_BRANCH"
fi
if [[ ! -z $VERSION ]]; then
	cmdBuilt+=" --build-arg VERSION=$VERSION"
fi
if [[ ! -z $VCS_REF ]]; then
	cmdBuilt+=" --build-arg VCS_REF=$VCS_REF"
fi
cmdBuilt+=" --tag $DOCKER_IMAGE:$DOCKER_TAG-$ARCH"
cmdBuilt+=" ."

eval $cmdBuilt
