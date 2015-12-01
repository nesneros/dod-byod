#!/usr/bin/env bash
# Usage byod-pull.sh <repository name> <tag>

repository=${1:-ubuntu}
tag=${2:-latest}

registry='https://registry-1.docker.io/v1'

token="$(curl -sL -o /dev/null -D- -H 'X-Docker-Token: true' "https://index.docker.io/v1/repositories/$repository/images" | tr -d '\r' | awk -F ': *' '$1 == "X-Docker-Token" { print $2 }')"
echo "Auth token: $token"

id=$(curl -sL -H "Authorization: Token $token" "$registry/repositories/$repository/tags/$tag" | sed 's/"//g')
[[ "${#id}" -ne 64 ]] && echo "No image named '$repository:$tag' exists" && exit 1
echo "Id of image $repository:$tag is $id"

ancestry="$(curl -sL -H "Authorization: Token $token" "$registry/images/$id/ancestry")"
# ancestry is formatted as ["id1", "id2"]
# Simple parser implemented with regular expression
IFS=',' && ancestry=(${ancestry//[\[\] \"]/})
echo "Ancestry: ${ancestry[@]}"

btrfsRoot=/var/byod/btrfs 
parent=$btrfsRoot/empty # Use empty subvolume as parent of first layer

# Iterate over the layers, and make a snapshot for each from the parent layer. 
for ((i = ${#ancestry[@]} - 1;i >= 0;i--)); do
    id=${ancestry[i]}
    # Use /tmp as cache
    tarFile=/tmp/byod-layer$id.tar
    if [ -f $tarFile ] ; then
        echo "Layer $id already downloaded"
    else
        echo "Downloading layer $id ($i)"
        curl -#L -H "Authorization: Token $token" "$registry/images/$id/layer" -o $tarFile
    fi
    current=$btrfsRoot/layer$id
    if [ ! -e $current ] ; then # assume layer is correct if it exists
        btrfs subvolume snapshot $parent $current
        tar xf $tarFile -C $current
    fi
    parent=$current
done

imageId=$id # Use docker id as the byod image id
dir=/var/byod/images/$imageId
mkdir -p $dir
echo "$repository:$tag" > $dir/source
ln -s $parent $dir/fs
echo "Image $imageId created" 
