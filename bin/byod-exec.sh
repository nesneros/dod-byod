#!/usr/bin/env bash

conId=${1:-NO_CON_ID}
# TODO figure out pid from container id. pid is on the host system for the unshare command
# To get going assume it is passed in as argument
pid=${2:-NO_PID}
shift ; shift
cmd="$@"
conDir=/var/byod/containers/$conId

# TODO call nsenter and execute $cmd with namespaces of pid

