#!/bin/bash

source .env

major=`echo $NEXTCLOUD_VERSION | cut -d. -f1`
minor=`echo $NEXTCLOUD_VERSION | cut -d. -f2`
revision=`echo $NEXTCLOUD_VERSION | cut -d. -f3`

if [ "$1" == "latest" ] 
then
  docker build . --build-arg NEXTCLOUD_VERSION=$NEXTCLOUD_VERSION -t habidat/nextcloud -t habidat/nextcloud:$major.$minor.$revision -t habidat/nextcloud:$major.$minor -t habidat/nextcloud:$major
else
  docker build . --build-arg NEXTCLOUD_VERSION=$NEXTCLOUD_VERSION -t habidat/nextcloud:$major.$minor.$revision -t habidat/nextcloud:$major.$minor -t habidat/nextcloud:$major
fi

echo "FINISHED"