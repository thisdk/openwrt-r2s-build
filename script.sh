#!/bin/bash

#delete android & dotnet
sudo rm -rf /usr/local/lib/android/
sudo rm -rf /usr/share/dotnet

#show disk space
df -h

#install dependent library
sudo apt-get install -y subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip

#clone openwrt source
git clone https://github.com/openwrt/openwrt.git

#version
cd openwrt && sed -i 's/,SNAPSHOT/,21.11.0/g' include/version.mk

#clone openwrt plugin source
./scripts/feeds update -a && ./scripts/feeds install -a

#openclash
git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/luci-app-openclash

#kms
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/vlmcsd

#diskman
svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman package/luci-app-diskman
mkdir package/parted && wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Parted.Makefile

#docker
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/collections/luci-lib-docker
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker feeds/luci/collections/luci-lib-docker

#end
