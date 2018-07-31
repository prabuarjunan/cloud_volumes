#! /bin/bash

# script to print details of a NetApp Clould Volume by mountpoint
# Written by Graham Smith, NetApp July 2018
# requires bash, jr and curl
# Version 0.0.1

#set -x

if [ $# -lt 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "Lists cloud volumes with high level details"
    echo "Usage: list-cvs config_file"
    echo
    exit 0
fi

source $1

# get filesystem info
filesystems=$(curl -s -H accept:application/json -H "Content-type: application/json" -H api-key:$apikey -H secret-key:$secretkey -X GET $url/FileSystems)

# Show info
echo $filesystems |jq -r ''

