#!/bin/bash

# install Dependent library

sudo apt-get install subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip

# clone openwrt

git clone --single-branch --depth 1 -b openwrt-21.02 https://git.openwrt.org/openwrt/openwrt.git

# version replace

cd openwrt && sed -i 's/-SNAPSHOT/.0/g' include/version.mk

# O3

sed -i 's/Os/O3 -funsafe-math-optimizations -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections/g' include/target.mk

# wan / lan

sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# 16384 / 65535

sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

# clone openwrt plugin source

./scripts/feeds update -a && ./scripts/feeds install -a

# BBRv2

wget -qO- https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/openwrt-kmod-bbr2.patch | patch -p1
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch -O target/linux/generic/hack-5.4/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch
wget -qO- https://github.com/openwrt/openwrt/commit/cfaf039.patch | patch -p1

# ARMv8 AES

sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/mbedtls/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch -O package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch

# CPU Info

wget -P target/linux/generic/hack-5.4/ https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch

# KMS

git clone https://github.com/gw826943555/openwrt-vlmcsd.git package/openwrt-vlmcsd

# OpenClash

git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# Theme

git clone --single-branch --depth 1 -b master https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# copy build file and config

# cp ../.config .config

# openwrt build dependencies

# make defconfig && make download -j8

# make openwrt source

# make -j4
