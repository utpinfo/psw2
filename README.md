## 首次使用
### 配置網路介面 (/etc/config/network)
- 配置PPPOE
```
uci set network.wan.proto='pppoe'
uci set network.wan.username='15618476128' 
uci set network.wan.password='Rh19870128'
uci add_list network.wan.dns='114.114.114.114'
uci add_list network.wan.dns='8.8.8.8'
uci commit network
/etc/init.d/network restart
```
- 配置二級路由
```
uci set network.wan.proto='static'
uci set network.wan.ipaddr='192.168.201.190'
uci set network.wan.netmask='255.255.255.0'
uci set network.wan.gateway='192.168.201.254'
uci add_list network.wan.dns='114.114.114.114'
uci add_list network.wan.dns='8.8.8.8'
uci commit network
/etc/init.d/network restart
```

### 安装iStore商店
```shell
opkg update
wget --no-check-certificate -qO imm.sh https://cafe.cpolar.top/wkdaily/zero3/raw/branch/main/zero3/imm.sh && chmod +x imm.sh && ./imm.sh
is-opkg install luci-i18n-quickstart-zh-cn
```

### PASSWALL2 (https://github.com/xiaorouji/openwrt-passwall2/releases/expanded_assets/$VERSION)
```
opkg update
wget --no-check-certificate -q https://raw.githubusercontent.com/utpinfo/psw2/main/download.sh && chmod +x download.sh && ./download.sh
opkg install *.ipk --force-reinstall
```

************************************************************************************************************************************************************
## 訂製固件

### 固件下載
https://firmware-selector.immortalwrt.org/?version=24.10.2&target=rockchip%2Farmv8&id=friendlyarm_nanopi-r5c
<!--
- 插件查詢
https://mirror.nju.edu.cn/immortalwrt/releases/packages-24.10/
- 鏡項源
https://help.mirrors.cernet.edu.cn/immortalwrt/
-->

### 預安裝軟件包
bash tree curl unzip zoneinfo-asia netdata luci-app-netdata luci-i18n-netdata-zh-cn luci-i18n-firewall-zh-cn luci-i18n-filebrowser-zh-cn luci-app-argon-config luci-i18n-argon-config-zh-cn luci-i18n-package-manager-zh-cn luci-i18n-ttyd-zh-cn openssh-sftp-server kmod-nft-socket kmod-nft-tproxy kmod-tcp-bbr
<!-- openwrt 23
bash tree curl unzip zoneinfo-asia netdata luci-app-netdata luci-i18n-netdata-zh-cn luci-i18n-firewall-zh-cn luci-i18n-filebrowser-zh-cn luci-app-argon-config luci-i18n-argon-config-zh-cn luci-i18n-base-zh-cn luci-i18n-ttyd-zh-cn openssh-sftp-server kmod-nft-socket kmod-nft-tproxy kmod-tcp-bbr
-->


###  首次启动时运行的脚本（uci-defaults）增加
```
# 日誌等級
uci set system.@system[0].conloglevel='4'
uci set system.@system[0].cronloglevel='9'
# 配置LAN (等效: 網路 > 接口 > lan)
uci set network.lan.ipaddr='192.168.100.1'
uci set network.lan.netmask='255.255.255.0'
# 配置 DHCP
uci set dhcp.lan=dhcp
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='50'
uci set dhcp.lan.leasetime='6h'
# 禁用 wan6
uci set network.wan6.disabled='1'
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'
#  關閉24.10版本預設流量卸載 (部分ISP 檢測封包格式異常或缺乏一些特徵, 導致限速)
uci set firewall.@defaults[0].flow_offloading='0'
uci set firewall.@defaults[0].flow_offloading_hw='0'
# 關閉 fullcone NAT，改回傳統 NAT 模式
uci set firewall.@defaults[0].fullcone='0'
uci commit
# /etc/init.d/network restart
# /etc/init.d/odhcpd restart
# /etc/init.d/firewall restart
# 配置鏡像源
sed -e 's,https://downloads.immortalwrt.org,https://mirrors.cernet.edu.cn/immortalwrt,g' \
    -e 's,https://mirrors.vsean.net/openwrt,https://mirrors.cernet.edu.cn/immortalwrt,g' \
    -i.bak /etc/opkg/distfeeds.conf
```

## 安裝插件 (第三方)
```text
# 網速測速 (https://github.com/sirpdboy/luci-app-netspeedtest/releases/download/v5.0.5/openwrt-22.03-x86_64.tar.gz)
# 網路嚮導 (https://github.com/sirpdboy/luci-app-netwizard/releases/expanded_assets/v1.9.2)
```



## ESXI VMDK 製作 (二次轉換)   
```shell
# MAC安裝轉換工具
brew install qemu
# MAC上執行轉換 (img -> vmdk)
qemu-img convert -f raw -O vmdk istoreos-24.10.2-2025071110-x86-64-squashfs-combined-efi.img openwrt.vmdk
# 上傳儲存區 (ESXI)
cd /Users/yangfengkai/Downloads
scp openwrt.vmdk root@192.168.201.210://vmfs/volumes/636ed8f8-89d1b6a0-d723-e0db550e08b4/istoreos
# EXSI上執行轉換 (vmdk -> esxi-vmdk)
ssh root@192.168.201.210
cd /vmfs/volumes/636ed8f8-89d1b6a0-d723-e0db550e08b4/openwrt
vmkfstools -i openwrt.vmdk -d thin openwrt-esxi.vmdk
```
<!--
# 虛擬器新增
- 选择创建类型：创建新虚拟机 > 客户机操作系统版本：其他 6.x 或更高版本 Linux (64 位)
- 删除默认添加的「硬盘1」

- 转换完成的以 -esxi.vmdk
-->