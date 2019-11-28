#!/bin/bash

set -e

USERNAME=$1
PASSWORD=$2
REPOSITORY=$3
REGISTRY=$4
TAG=$5
FLAG=$6
SUBDIR=$7

if [ -z $USERNAME ]; then
  echo 'Required username parameter'
  exit 1
fi

if [ -z $PASSWORD ]; then
  echo 'Required password parameter'
  exit 1
fi

if [ -z $REPOSITORY ]; then
  echo 'Required repository parameter'
  exit 1
fi

if [[ -z $TAG ]]; then
  echo 'Tag to snapshot'
  TAG=$(date '+%Y%m%d%H%M%S')
fi

IMAGE=$REPOSITORY:$TAG
if [ -n "$REGISTRY" ]; then
  IMAGE=$REGISTRY/$IMAGE
fi

if [ ! -z "$SUBDIR" ]; then
  cd $SUBDIR
fi

docker build -t $IMAGE .
docker login --username "$USERNAME" --password "$PASSWORD" $REGISTRY

if [ "$FLAG" == 'test' ]; then
  echo "Just test, nothing will be pushed to Dockerhub"
elif [ "$FLAG" == 'latest' ]; then
  docker push $IMAGE
  docker tag $IMAGE $REPOSITORY:latest
  docker push $REPOSITORY:latest
elif [ "$FLAG" == 'no-latest' ]; then
  docker push $IMAGE
fi

echo ::set-output name=image::$IMAGE