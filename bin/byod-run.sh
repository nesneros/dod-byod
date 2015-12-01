#!/usr/bin/env bash

# Run an image (i.e. create a container and start it).
# Usage: byod-run <imageId> cmd...
imageId=$1
shift
cmd="$@"
imageDir=/var/byod/images/$imageId
conId=$(uuidgen)
conDir=/var/byod/containers/$conId
mkdir $conDir

imageFs=$(readlink $imageDir/fs)
conFs=/var/byod/btrfs/con$conId
btrfs subvolume snapshot $imageFs $conFs

# Add google dns to container
echo 'nameserver 8.8.8.8' > $conFs/etc/resolv.conf

ln -s $conFs $conDir/fs

echo "Container $conId created. Cmd: $cmd"

# Function to define network for network isolation
function setupNetwork {
    # Return if byod interfaces already created
    [[ -f /var/run/netns/netns_byod ]] && return
    ip link add dev byod0 type veth peer name byod1
    ip link set dev byod0 up
    ip link set byod0 master bridge0
    ip netns add netns_byod
    ip link set byod1 netns netns_byod
    ip netns exec netns_byod ip link set dev lo up
    ip netns exec netns_byod ip link set byod1 address 02:42:ac:11:00:42
    ip netns exec netns_byod ip addr add 10.0.0.42/24 dev byod1
    ip netns exec netns_byod ip link set dev byod1 up
    ip netns exec netns_byod ip route add default via 10.0.0.1
}

# TODO call unshare and chroot to execute cmd 'containerized'
# TOTO for network isolation also call 'ip netns exec netns_byod'



