#!/usr/bin/env bash

conId=${1:NO_CON_ID}
conDir=/var/byod/containers/$conId
conFs=$(readlink $conDir/fs)

# TODO create new image base on the containers file system

