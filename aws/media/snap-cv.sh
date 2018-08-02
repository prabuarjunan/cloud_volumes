#! /bin/bash

# script to create snapshots of NetApp Clould Volumes by mountpoint
# Written by Graham Smith, NetApp July 2018
# requires bash, jr and curl
# Version 0.0.1

#set -x

if [ $# -lt 2 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "Create a snapshots of the Cloud volume"
    echo "Usage: snap-cv mountpoint config_file"
    echo
    exit 0
fi

source $2

time=$(date +%Y%m%d%H%M%S)

# get filesystem info
filesystems=$(curl -s -H accept:application/json -H "Content-type: application/json" -H api-key:$apikey -H secret-key:$secretkey -X GET $url/v1/FileSystems)

# get filesystemIds
ids=$(echo $filesystems |jq -r ''|grep fileSystemId |cut -d '"' -f 4)

if [ "${#ids}" == "0" ]; then
	echo "Please check that the apikey and secretkey are valid"
	exit 0
fi

# get region
region=$(echo $filesystems |jq -r '' | grep -i -B 1 $1 |grep region |cut -d '"' -f 4)

# Find matching filesystemId
fileSystemId=$(echo $filesystems |jq -r ''| grep -i -B 10 $1 |grep fileSystemId | cut -d '"' -f 4)

if [ "${#fileSystemId}" == "0" ]; then
	echo "Please check the mountpoint is correct"
	exit
fi

# Create snapshot
curl -s -H accept:application/json -H "Content-type: application/json" -H api-key:$apikey -H secret-key:$secretkey -X POST $url/v1/FileSystems/$fileSystemId/Snapshots -d '{"name": "snap_'$time'","region": "'$region'"}' |jq -r '' 
