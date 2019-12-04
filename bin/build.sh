#!/bin/bash

version=`cat version`
ss_image_name="ss-image"
v2ray_image_name="v2ray-image"

function build-ss()
{
    docker build -f docker/build-ss.docker -t $ss_image_name:$version .
    docker run --name shadowsocks -d -p $1:12123 -v `pwd`/config/shadowsocks:/etc/shadowsocks $ss_image_name:$version
}

function build-v2ray()
{
    docker pull v2ray/official
    docker run --name v2ray -d -v `pwd`/config/v2ray:/etc/v2ray -p $1:12123 v2ray/official v2ray -config=/etc/v2ray/config.json
}

function print-usage()
{
    echo -e "Usage: bash bin/build-fuckgfw.sh [OPTION]..."
    echo -e "options."
    echo -e "\t-s\tshadowsocks map port"
    echo -e "\t-v\tv2ray map port"
}

while getopts 's:v:' c 
do
    case $c in
        s) 
            ss_map_port=$OPTARG
            ;;
        v)
            v2ray_map_port=$OPTARG
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

if [ "$v2ray_map_port" == "" ]
then
    print-usage
    exit 2
fi

build-ss $ss_map_port
build-v2ray $v2ray_map_port
