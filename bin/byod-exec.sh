#!/usr/bin/env bash

conId=${1:-NO_CON_ID}
# TODO figure out pid from container id. pid is on the host system for the unshare command
pid=${2:-NO_PID}
echo pid $pid $conId
shift ; shift
cmd="$@"
conDir=/var/byod/containers/$conId

nsenter -t "$pid" -m -u -i -n -p chroot $conDir/fs $cmd
