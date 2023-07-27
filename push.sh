#!/bin/bash

source .env

major=`echo $NEXTCLOUD_VERSION | cut -d. -f1`
minor=`echo $NEXTCLOUD_VERSION | cut -d. -f2`
revision=`echo $NEXTCLOUD_VERSION | cut -d. -f3`

docker login

docker push habidat/nextcloud:$major.$minor.$revision
docker push habidat/nextcloud:$major.$minor
docker push habidat/nextcloud:$major

if [ "$1" == "latest" ] 
then
  docker push habidat/nextcloud
fi

echo "FINISHED"