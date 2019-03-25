#!/bin/bash
set -e

source scripts/multiArchMatrix.sh

TAG_LATEST=0

showHelp() {
	echo "Usage: $0 -i <image name> -t <tag name> [-l] (add latest tag)"
}

while getopts :hi:t:l opt; do
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
		l)
			TAG_LATEST=1
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

printf "### Pushing to Docker HUB ###\\n"
printf "Docker image: $DOCKER_IMAGE\\n"
printf "Docker tag: $DOCKER_TAG"
if [ $TAG_LATEST == 1 ] ; then
	printf " (latest)"
fi
printf "\\n"


# Push all builded images to Docker HUB
for i in ${!ARCHS[@]}; do
	docker push $DOCKER_IMAGE:$DOCKER_TAG-${ARCHS[i]}
done


### Main tag ###
# Create manifest
cmdCreate="docker manifest create --amend $DOCKER_IMAGE:$DOCKER_TAG "
for i in ${!ARCHS[@]}; do
	cmdCreate+="$DOCKER_IMAGE:$DOCKER_TAG-${ARCHS[i]} "
done
eval $cmdCreate
# Annotate manifest
for i in ${!ARCHS[@]}; do
	cmdAnnotate="docker manifest annotate $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:$DOCKER_TAG-${ARCHS[i]}"
	cmdAnnotate+=" --os linux"
	cmdAnnotate+=" --arch ${DOCKER_ARCHS[i]}"
	if [[ "${ARCH_VARIANTS[i]}" != "NONE" ]]; then
		cmdAnnotate+=" --variant ${ARCH_VARIANTS[i]}"
	fi
	eval $cmdAnnotate
done
# Push manifest to Docker HUB
docker manifest push --purge $DOCKER_IMAGE:$DOCKER_TAG


### Latest tag ###
if [ $TAG_LATEST == 1 ] ; then
	# Create latest manifest
	cmdCreate="docker manifest create --amend $DOCKER_IMAGE:latest "
	for i in ${!ARCHS[@]}; do
		cmdCreate+="$DOCKER_IMAGE:$DOCKER_TAG-${ARCHS[i]} "
	done
	eval $cmdCreate
	
	# Annotate manifest
	for i in ${!ARCHS[@]}; do
		cmdAnnotate="docker manifest annotate $DOCKER_IMAGE:latest $DOCKER_IMAGE:$DOCKER_TAG-${ARCHS[i]}"
		cmdAnnotate+=" --os linux"
		cmdAnnotate+=" --arch ${DOCKER_ARCHS[i]}"
		if [[ "${ARCH_VARIANTS[i]}" != "NONE" ]]; then
			cmdAnnotate+=" --variant ${ARCH_VARIANTS[i]}"
		fi
		eval $cmdAnnotate
	done
	# Push latest manifest to Docker HUB
	docker manifest push --purge $DOCKER_IMAGE:latest
fi
