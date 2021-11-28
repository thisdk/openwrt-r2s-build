#!/bin/bash

# Install Dependent library
sudo apt-get install -y subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip

# Clone Openwrt
git clone https://git.openwrt.org/openwrt/openwrt.git && cd openwrt

# clone openwrt plugin source
./scripts/feeds update -a && ./scripts/feeds install -a

# openclash
git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# kms
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/vlmcsd

#webdav
svn co https://github.com/messense/aliyundrive-webdav/trunk/openwrt/aliyundrive-webdav package/aliyundrive-webdav
svn co https://github.com/messense/aliyundrive-webdav/trunk/openwrt/luci-app-aliyundrive-webdav package/luci-app-aliyundrive-webdav

#diskman
svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman package/luci-app-diskman
mkdir package/parted && wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Parted.Makefile

#docker
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/collections/luci-lib-docker
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker feeds/luci/collections/luci-lib-docker
