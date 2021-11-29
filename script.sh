#!/bin/bash

#delete android
sudo rm -rf /usr/local/lib/android/

#show disk space
df -h

#install dependent library
sudo apt-get install -y subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip

#clone openwrt source
git clone https://github.com/openwrt/openwrt.git

#version
cd openwrt && sed -i 's/,SNAPSHOT/,21.11.1/g' include/version.mk

#clone openwrt plugin source
./scripts/feeds update -a && ./scripts/feeds install -a

#kms
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/vlmcsd

#smartdns
rm -rf feeds/packages/net/smartdns
svn co https://github.com/Lienol/openwrt-packages/trunk/net/smartdns feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
svn co https://github.com/immortalwrt/luci/branches/openwrt-18.06/applications/luci-app-smartdns feeds/luci/applications/luci-app-smartdns

#docker
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/collections/luci-lib-docker
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker feeds/luci/collections/luci-lib-docker

#theme
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
rm -f package/luci-theme-argon/htdocs/luci-static/argon/background/README.md

#end
