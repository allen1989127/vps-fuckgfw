#!/bin/bash

version=`cat version`
ss_image_name="ss-image"

function build-ss()
{
    docker build -f docker/build-ss.docker -t $ss_image_name:$version .
    docker run -d -p $1:12123 -v `pwd`/config/shadowsocks:/etc/shadowsocks $ss_image_name:$version
}

function print-usage()
{
    echo -e "Usage: bash bin/build-fuckgfw.sh [OPTION]..."
    echo -e "options."
    echo -e "\t-s\tshadowsocks map port"
}

while getopts 's:' c 
do
    case $c in
        s) 
            ss_map_port=$OPTARG
            ;;
        *) 
            print-usage
            exit 1
            ;;
    esac
done

if [ "$ss_map_port" == "" ]
then
    print-usage
    exit 2
fi

build-ss $ss_map_port
