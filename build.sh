#!/bin/bash

source .env

major=`echo $NEXTCLOUD_VERSION | cut -d. -f1`
minor=`echo $NEXTCLOUD_VERSION | cut -d. -f2`
revision=`echo $NEXTCLOUD_VERSION | cut -d. -f3`

docker build . -t habidat/nextcloud:$major.$minor.$revision
docker build . -t habidat/nextcloud:$major.$minor
docker build . -t habidat/nextcloud:$major

if [ "$1" == "latest" ] 
then
  docker build . -t habidat/nextcloud
fi

echo "FINISHED"