#!/bin/bash

# clone openwrt

git clone -b openwrt-21.02 https://git.openwrt.org/openwrt/openwrt.git
git clone -b main https://github.com/Lienol/openwrt.git openwrt-lienol
git clone -b master https://github.com/immortalwrt/immortalwrt.git openwrt-immortalwrt
git clone -b master https://github.com/immortalwrt/packages.git immortalwrt-packages

# version replace

cd openwrt && sed -i 's/-SNAPSHOT/.1/g' include/version.mk

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

# FullConeNAT

wget -P target/linux/generic/hack-5.4 https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/fullconenat.patch
wget -qO- https://github.com/msylgj/R2S-R4S-OpenWrt/raw/21.02/SCRIPTS/fix_firewall_flock.patch | patch -p1
wget -qO- https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/firewall/luci-app-firewall_add_fullcone.patch | patch -p1
cp -rf ../openwrt-lienol/package/network/fullconenat package/network/fullconenat

# AutoCore

rm -rf feeds/packages/utils/coremark
cp -rf ../immortalwrt-packages/utils/coremark feeds/packages/utils/coremark
cp -rf ../openwrt-immortalwrt/package/emortal/autocore package/autocore
cp -rf ../rpcd_luci package/autocore/rpcd_luci

# KMS

git clone https://github.com/gw826943555/openwrt-vlmcsd.git package/openwrt-vlmcsd

# OpenClash

git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# copy build file and config

cp ../.config .config

# openwrt build dependencies

make defconfig && make download -j8

# make openwrt source

make -j4
