# vps-fuckgfw

## 前言

狗啃伟大的GFW的傻逼们,就TMD喜欢瞎JB的整这些狗玩意儿,懂的整,诅咒你们他娘的祖宗十八代

本项目整合了翻过GFW的几个常用工具,分别是shadowsocks,v2ray,wireguard

可一次性在VPS上部署好几个服务,记得多备几个VPS,不然进入FQ得先FQ的情况就尴尬了

## 部署步骤

linode和vultr均使用ubuntu 18.04部署过,均可正常部署

### 预备环境

* 更新环境,安装docker

    apt update && apt upgrade -y && apt install -y docker.io

* 重启vps,安装wireguard驱动

    add-apt-repository ppa:wireguard/wireguard -y && apt update && apt install -y wireguard

* 将wireguard驱动设置为开机加载,编辑/etc/modules-load.d/modules.conf文件,加入wireguard,重启vps

### 部署环境

* 下载vps-fuckgfw项目
* 进入vps-fuckgfw目录,修改shadowsocks的配置文件,文件位于shadowsocks/config/config.json,将{{your-password}}改为自己的密码
* 修改v2ray的配置文件,文件位于v2ray/config/config.json,将{{your-uuid}}以及{{your-id}}改为自己的id,uuid可以通过/proc/sys/kernel/random/uuid中生成,id可随意更改为自己所需的值
* 修改trojan的配置文件,将trojan/env中的常量修改成自己vps对应的参数,IP为vps的公网IP,URL为申请的域名,记得将自己域名绑定到vps的公网IP上,由于我自己申请的域名位于godaddy上,因此其余的变量均为godaddy上的配置,godaddy的key,secret均可在**https://developer.godaddy.com/keys**上获取.同时将trojan/etc/trojan/config.json中的{{your-password}}改为你自己的密码即可
* 以上步骤即配置完成shadowsocks以及v2ray,当然,这些只是基础配置,也可以针对配置文件进行更加复杂的配置,这里不再进行阐述
* 完成配置后通过类似下面的命令执行部署

    bin/build-fuckgfw.sh -s 38747 -v 23823 -w 38237

其中-s表示shadowsocks映射出来的端口,-v表示v2ray映射出来的端口,-w表示wireguard映射出来的端口

当然,也可以用-t参数对服务进行单独部署

## 结语

至此vps上服务的部署就完成了,只需要等待部署完成即可,wireguard在客户端只可放行10.0.0.2的IP,该问题会在后续版本修复

最后的最后,送给gfw的开发人们...您娘可好啊!
