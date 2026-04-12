# Customize installed packages and/or first boot script
```text
https://firmware-selector.immortalwrt.org
```

## 一. Installed Packages
autocore automount base-files block-mount ca-bundle default-settings-chn dnsmasq-full dropbear fdisk firewall4 fstools kmod-gpio-button-hotplug kmod-nf-nathelper kmod-nf-nathelper-extra kmod-nft-offload libc libgcc libustream-openssl logd luci-app-cpufreq luci-app-package-manager luci-compat luci-lib-base luci-lib-ipkg luci-light mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg partx-utils ppp ppp-mod-pppoe procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd kmod-r8125 kmod-rtw88-8822ce rtl8822ce-firmware wpad-openssl iwinfo bash tree curl unzip zoneinfo-asia netdata luci-app-netdata luci-i18n-netdata-zh-cn luci-i18n-firewall-zh-cn luci-i18n-filebrowser-zh-cn luci-app-argon-config luci-i18n-argon-config-zh-cn luci-i18n-package-manager-zh-cn luci-i18n-ttyd-zh-cn openssh-sftp-server kmod-nft-socket kmod-nft-tproxy kmod-tcp-bbr irqbalance

## 二. Script to run on first boot (uci-defaults)
```shell
# 1️⃣ 系統日誌
uci set system.@system[0].conloglevel='4'
uci set system.@system[0].cronloglevel='9'

# 2️⃣ LAN & DHCP
uci set network.lan.ipaddr='192.168.100.1'
uci set network.lan.netmask='255.255.255.0'
uci set dhcp.lan=dhcp
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='50'
uci set dhcp.lan.leasetime='6h'

# 3️⃣ Conntrack（高並發 NAT）
sysctl -w net.netfilter.nf_conntrack_max=524288
echo "net.netfilter.nf_conntrack_max=524288" >> /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_tcp_timeout_established=3600" >> /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_tcp_timeout_time_wait=120" >> /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_udp_timeout=60" >> /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_udp_timeout_stream=180" >> /etc/sysctl.conf
sysctl -p

# 增大 backlog
echo 3 > /sys/class/net/eth0/queues/rx-*/rps_cpus
sysctl -w net.core.netdev_max_backlog=8192

# 5️⃣ IPv6 / WAN6 禁用
uci set network.wan6.disabled='1'
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'
uci commit network

# 6️⃣ Flow Offload / NAT
uci set firewall.@defaults[0].flow_offloading='0'
uci set firewall.@defaults[0].flow_offloading_hw='0'
uci set firewall.@defaults[0].fullcone='0'
uci commit firewall
/etc/init.d/firewall restart

# 7️⃣ 網卡 RPS + Softnet / TCP Buffer 極限優化
# 修改 eth0 / eth1 根據實際 WAN/LAN
for IF in eth0 eth1; do
    printf '%x\n' $(( (1 << $(grep -c ^processor /proc/cpuinfo)) - 1 )) > /sys/class/net/$IF/queues/rx-0/rps_cpus
done

echo 32768 > /proc/sys/net/core/rps_sock_flow_entries
echo 65536 > /proc/sys/net/core/netdev_max_backlog
echo 67108864 > /proc/sys/net/core/rmem_max
echo 67108864 > /proc/sys/net/core/wmem_max
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
echo bbr > /proc/sys/net/ipv4/tcp_congestion_control
echo 1 > /proc/sys/net/ipv4/tcp_mtu_probing

# 8️⃣ 配置鏡像源
sed -e 's,https://downloads.immortalwrt.org,https://mirrors.cernet.edu.cn/immortalwrt,g' \
    -e 's,https://mirrors.vsean.net/openwrt,https://mirrors.cernet.edu.cn/immortalwrt,g' \
    -i.bak /etc/opkg/distfeeds.conf

# 9️⃣ 重啟必要服務
/etc/init.d/network restart
/etc/init.d/odhcpd restart
/etc/init.d/firewall restart
```