#!/bin/bash

# Install Dependent library

sudo apt-get install -y subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip

# Clone Openwrt

git clone --single-branch --depth 1 -b openwrt-21.02 https://git.openwrt.org/openwrt/openwrt.git

git clone --single-branch --depth 1 -b master https://github.com/thisdk/immortalwrt.git immortalwrt-openwrt
git clone --single-branch --depth 1 -b master https://github.com/thisdk/luci.git immortalwrt-luci
git clone --single-branch --depth 1 -b main https://github.com/Lienol/openwrt.git lienol-openwrt
git clone --single-branch --depth 1 -b 21.02 https://github.com/Lienol/openwrt-packages.git lienol-packages
git clone --single-branch --depth 1 -b 21.02 https://github.com/Lienol/openwrt-luci.git lienol-luci

# Version Replace

cd openwrt && sed -i 's/.02-SNAPSHOT/.02.0/g' include/version.mk

# O3

sed -i 's/Os/O3 -funsafe-math-optimizations -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections/g' include/target.mk

# clone openwrt plugin source

./scripts/feeds update -a && ./scripts/feeds install -a

# Config IRQ

sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

# CPU Info

wget -P target/linux/generic/hack-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/generic/hack-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch

# BBRv2

wget -qO- https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/openwrt-kmod-bbr2.patch | patch -p1
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/BBRv2/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch -O target/linux/generic/hack-5.4/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch
wget -qO- https://github.com/openwrt/openwrt/commit/cfaf039.patch | patch -p1

# CacULE
wget -qO - https://github.com/QiuSimons/openwrt-NoTengoBattery/commit/7d44cab.patch | patch -p1
wget https://github.com/hamadmarri/cacule-cpu-scheduler/raw/master/patches/CacULE/v5.4/cacule-5.4.patch -O target/linux/generic/hack-5.4/694-cacule-5.4.patch

# UKSM
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/UKSM/695-uksm-5.4.patch -O target/linux/generic/hack-5.4/695-uksm-5.4.patch

# Fullcone Nat

# wget -P target/linux/generic/hack-5.4 https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
# mkdir package/network/config/firewall/patches
# wget -P package/network/config/firewall/patches https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/config/firewall/patches/fullconenat.patch
# wget -qO- https://raw.githubusercontent.com/msylgj/R2S-R4S-OpenWrt/21.02/PATCHES/001-fix-firewall-flock.patch | patch -p1
# wget -qO- https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/firewall/luci-app-firewall_add_fullcone.patch | patch -p1
# cp -rf ../lienol-openwrt/package/network/fullconenat package/fullconenat

# AutoCore

cp -rf ../immortalwrt-openwrt/package/emortal/autocore package/autocore

# Cpufreq

cp -rf ../immortalwrt-luci/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
ln -sf ../../../feeds/luci/applications/luci-app-cpufreq package/feeds/luci/luci-app-cpufreq
sed -i 's,1512,1608,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq

# ARMv8 AES

sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
wget https://raw.githubusercontent.com/QiuSimons/R2S-R4S-X86-OpenWrt/master/PATCH/mbedtls/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch -O package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch

# CacULE
sed -i '/CONFIG_NR_CPUS/d' target/linux/rockchip/armv8/config-5.4
echo '
CONFIG_NR_CPUS=4
' >> target/linux/rockchip/armv8/config-5.4

# UKSM
echo '
CONFIG_KSM=y
CONFIG_UKSM=y
' >> target/linux/rockchip/armv8/config-5.4

# IRQ eth0 offloading rx/rx

sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 8 "ff160000" "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 1 "ff150000" "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/;;/i\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

# WAN / LAN

sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# 16384 / 65535

sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

# CPU Overclocking
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch

# Other Patch

wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/911-kernel-dma-adjust-default-coherent_pool-to-2MiB.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/807-arm64-dts-nanopi-r2s-add-rk3328-dmc-relate-node.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/201-rockchip-rk3328-add-i2c0-controller-for-nanopi-r2s.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/806-arm64-dts-rockchip-rk3328-add-dfi-node.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/804-clk-rockchip-support-setting-ddr-clock-via-SIP-Version-2-.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/803-PM-devfreq-rockchip-add-devfreq-driver-for-rk3328-dmc.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/802-arm64-dts-rockchip-add-hardware-random-number-genera.patch
# wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/target/linux/rockchip/patches-5.4/801-char-add-support-for-rockchip-hardware-random-number.patch

# KMS

git clone https://github.com/gw826943555/openwrt-vlmcsd.git package/openwrt-vlmcsd

# OpenClash

git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# Xray

# git clone https://github.com/yichya/openwrt-xray.git package/openwrt-xray
# git clone https://github.com/yichya/luci-app-xray.git package/luci-app-xray

# SmartDns

rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
cp -rf ../lienol-packages/net/smartdns feeds/packages/net/smartdns
cp -rf ../lienol-luci/applications/luci-app-smartdns feeds/luci/applications/luci-app-smartdns

# Theme

git clone --single-branch --depth 1 -b master https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
