#!/bin/bash

. bin/constrants

version=`cat version`
ss_image_name="ss-image"
v2ray_image_name="v2ray-image"

function build-ss()
{
    docker build -f shadowsocks/docker/build-ss.docker -t $ss_image_name:$version .
    docker run --restart=always --name shadowsocks -d -p $1:12123 -v `pwd`/shadowsocks/config:/etc/shadowsocks $ss_image_name:$version
}

function build-v2ray()
{
    docker pull v2ray/official
    docker run --restart=always --name v2ray -d -v `pwd`/v2ray/config:/etc/v2ray -p $1:12123 v2ray/official v2ray -config=/etc/v2ray/config.json
}

function build-wg()
{
    wg_folder=/etc/wireguard
    wg_port=$1

    mkdir -p $wg_folder
    chmod 700 $wg_folder
    wg genkey > $wg_folder/server-private-key
    wg genkey > $wg_folder/client-private-key
    wg pubkey < $wg_folder/server-private-key > $wg_folder/server-public-key
    wg pubkey < $wg_folder/client-private-key > $wg_folder/client-public-key
    cp -vp wireguard/config/wg0.conf $wg_folder/wg0.conf
    chmod 600 $wg_folder/*

    s_pri_key=`cat $wg_folder/server-private-key`
    s_pub_key=`cat $wg_folder/server-public-key`
    c_pri_key=`cat $wg_folder/client-private-key`
    c_pub_key=`cat $wg_folder/client-public-key`

    sed -i "s/_server_private_key/${s_pri_key}/g" $wg_folder/wg0.conf
    sed -i "s/_client_public_key/${c_pub_key}/g" $wg_folder/wg0.conf
    sed -i "s/_port/${wg_port}/g" $wg_folder/wg0.conf

    cp -vp wireguard/bin/wg-enable /usr/local/bin/
    chmod 755 /usr/local/bin/wg-enable
    cp -vp wireguard/service/wg.service /etc/systemd/system/
    systemctl enable wg.service
    systemctl start wg.service

    echo "client private key:$c_pri_key"
    echo "client public key:$c_pub_key"
    echo "server public key:$s_pub_key"
}

function print-usage()
{
    echo -e "Usage: bash bin/build-fuckgfw.sh [OPTION]..."
    echo -e "options."
    echo -e "\t-t\tall or type of services, can select ss|v2ray|wg, split with ,"
    echo -e "\t-s\tshadowsocks map port"
    echo -e "\t-v\tv2ray map port"
    echo -e "\t-w\twireguard map port"
}

while getopts 't:s:v:w:' c 
do
    case $c in
        t)
            services_types=$OPTARG
            ;;
        s) 
            ss_map_port=$OPTARG
            ;;
        v)
            v2ray_map_port=$OPTARG
            ;;
        w)
            wg_map_port=$OPTARG
            ;;
        *) 
            print-usage
            exit 1
            ;;
    esac
done

service_type=$TYPE_ALL

if [ "$services_types" == "all" -o "$services_types" == "" ]
then
    if [ "$ss_map_port" == "" -o "$v2ray_map_port" == "" -o "$wg_map_port" == "" ]
    then
        print-usage
        exit 2
    fi

    build-ss $ss_map_port
    build-v2ray $v2ray_map_port
    build-wg $wg_map_port

    exit 0
fi

service_types=`echo $services_types | sed 's/,/ /g'`

for service_type in $service_types
do
    case $service_type in
        ss)
            service_type=$TYPE_SS
            if [ "$ss_map_port" == "" ]
            then
                print-usage
                exit 3
            fi

            build-ss $ss_map_port
            ;;
        v2ray)
            service_type=$TYPE_V2RAY
            if [ "$v2ray_map_port" == "" ]
            then
                print-usage
                exit 4
            fi

            build-v2ray $v2ray_map_port
            ;;
        wg)
            service_type=$TYPE_WG
            if [ "$wg_map_port" == "" ]
            then
                print-usage
                exit 5
            fi

            build-wg $wg_map_port
            ;;
        *)
            print-usage
            exit 6
            ;;
    esac
done

exit 0
