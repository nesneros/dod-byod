#!/usr/bin/env bash
# Usage byod-pull.sh <repository name> <tag>

conId=${1:NO_CON_ID}
conDir=/var/byod/containers/$conId
conFs=$(readlink $conDir/fs)

imageId=$(uuidgen)
imageDir=/var/byod/images/$imageId
imageFs=/var/byod/btrfs/$imageId

btrfs subvolume snapshot $conFs $imageFs

mkdir -p $imageDir
ln -s $imageFs $imageDir/fs
echo "Image $imageId created from container $conId" 
