#!/bin/bash

# Install Dependent library

sudo apt install -y subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip

# Clone Openwrt

git clone --single-branch --depth 1 -b openwrt-21.02 https://git.openwrt.org/openwrt/openwrt.git

git clone --single-branch --depth 1 -b master https://github.com/thisdk/immortalwrt.git immortalwrt-openwrt
git clone --single-branch --depth 1 -b master https://github.com/thisdk/luci.git immortalwrt-luci

# Version Replace

cd openwrt && sed -i 's/-SNAPSHOT/.0/g' include/version.mk

# ARMv8 AES

sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/mbedtls/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch -O package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch

# IRQ eth0 offloading rx/rx

sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 8 "ff160000" "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 1 "ff150000" "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/;;/i\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

# WAN / LAN

sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# O3

sed -i 's/Os/O3 -funsafe-math-optimizations -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections/g' include/target.mk

# 16384 / 65535

sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

# clone openwrt plugin source

./scripts/feeds update -a && ./scripts/feeds install -a

# Config IRQ

sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

# BBRv2

wget -qO- https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/openwrt-kmod-bbr2.patch | patch -p1
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch -O target/linux/generic/hack-5.4/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch
wget -qO- https://github.com/openwrt/openwrt/commit/cfaf039.patch | patch -p1

# CPU

wget -P target/linux/generic/hack-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/generic/hack-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch

# Patch

wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/201-rockchip-rk3328-add-i2c0-controller-for-nanopi-r2s.patch
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/802-arm64-dts-rockchip-add-hardware-random-number-genera.patch
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/807-arm64-dts-nanopi-r2s-add-rk3328-dmc-relate-node.patch
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/806-arm64-dts-rockchip-rk3328-add-dfi-node.patch
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/805-PM-devfreq-rockchip-dfi-add-more-soc-support.patch
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/803-PM-devfreq-rockchip-add-devfreq-driver-for-rk3328-dmc.patch

# AutoCore

cp -rf ../immortalwrt-openwrt/package/emortal/autocore package/autocore

# Cpufreq

cp -rf ../immortalwrt-luci/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq
sed -i 's,1512,1608,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq

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
