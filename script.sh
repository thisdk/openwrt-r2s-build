#!/bin/bash

# clone openwrt

git clone -b openwrt-21.02 https://git.openwrt.org/openwrt/openwrt.git

# version replace

cd openwrt && sed -i 's/-SNAPSHOT/.1/g' include/version.mk

# wan / lan

sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# 16384 / 65535

sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

# BBRv2

wget -qO - https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/openwrt-kmod-bbr2.patch | patch -p1
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch -O target/linux/generic/hack-5.4/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch
wget -qO - https://github.com/openwrt/openwrt/commit/cfaf039.patch | patch -p1

# ARMv8 AES
sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/mbedtls/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch -O package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch

# clone openwrt plugin source

./scripts/feeds update -a && ./scripts/feeds install -a

# copy build file and config

cp ../.config .config

# openwrt build dependencies

make defconfig && make download -j8

# make openwrt source

make -j4
