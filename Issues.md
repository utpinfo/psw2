# DNS洩漏

## 方案一
開啟fakedns (修改後清理Cookies+DNS)


<!--
## 方案二
1. Wifi設定Openwrt的Socks代理
```
* 此方案可以繞過Nftables透明代理, 導致的XrayServer分流DNS洩漏
* 缺點: 如果passwall2關閉後直連也無法連線
```

## 方案三
```shell
# 局域網IP規則註解處理
sed -i '/192\.168\.0\.0\/16/ s/^[[:space:]]*/&#/' /usr/share/passwall2/utils.sh
# 局域網IP規則復原
sed -i 's/^[[:space:]]*#\(.*192\.168\.0\.0\/16.*\)/\1/' /usr/share/passwall2/utils.sh
# 檢測規則
grep '192\.168\.0\.0/16' /usr/share/passwall2/utils.sh
# 列出nftables規則
nft list table inet passwall2 | grep -E '192\.168|passwall2_lan'
```
-->

# DNS配置

## * 方案一 (DNS入口: passwall2, 直連流入mosdns)
1. passwall2 => 远程 DNS 协议: DOH
2. passwall2 => 远程 DNS: cloudflare
3. passwall2 => DNS 重定向: true
4. mosdns => DNS 轉發: true
5. mosdns => DNS 重定向: false
<!--
├── 国内域名: 客户端 → Passwall2→ MosDNS(国内DNS) → 返回
└── 国外域名: 客户端 → Passwall2(远程 DNS) → Xray → 返回
-->

## 方案二 (DNS入口: passwall2, 直連流入dnsmasq)
1. passwall2 => 远程 DNS 协议: DOH
2. passwall2 => 远程 DNS: cloudflare
3. passwall2 => DNS 重定向: true

## 方案三 (DNS入口: mosdns, 由mosdns處理後再入passwall2 -> 多DNS備選):
1. passwall2 => 远程 DNS 协议: UDP
2. passwall2 => 远程 DNS: 127.0.0.1:5335
3. passwall2 => DNS 重定向: false
4. mosdns => DNS 轉發: true
5. mosdns => DNS 重定向: true
<!--
├── 国内域名: 客户端 → MosDNS(国内DNS) → 返回
└── 国外域名: 客户端 → MosDNS(远程DNS) → Passwall2 → Xray → 返回
-->


## * 特殊規則
```
The geosite:cn rule must come after the geosite:proxy rule,otherwise www.gstatic.com gets matched by cn and goes direct (which is broken in China).
```