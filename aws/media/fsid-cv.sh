#! /bin/bash

# script to find NetApp Clould Volumes Service fileSystemId by mountpoint
# Written by Graham Smith, NetApp July 2018
# requires bash, jr and curl
# Version 0.0.1

#set -x

if [ $# -lt 2 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "Find the FileSystemId for a cloud volume by export name"
    echo "Usage: fsid-cv mountpoint config_file"
    echo
    exit 0
fi

source $2

# get filesystem info
filesystems=$(curl -s -H accept:application/json -H "Content-type: application/json" -H api-key:$apikey -H secret-key:$secretkey -X GET $url/v1/FileSystems)

# get filesystemIds
ids=$(echo $filesystems |jq -r ''|grep fileSystemId |cut -d '"' -f 4)

if [ "${#ids}" == "0" ]; then
	echo "Please check that the apikey and secretkey are valid"
	exit
fi

# Find matching filesystemId
fileSystemId=$(echo $filesystems |jq -r ''| grep -i -B 10 $1 |grep fileSystemId | cut -d '"' -f 4)

if [ "${#fileSystemId}" == "0" ]; then
	echo "Please check the mountpoint is correct"
	exit
fi

echo -n "The fileSystemId for "$1" is :" 
echo $fileSystemId


