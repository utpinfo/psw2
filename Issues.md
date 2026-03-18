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
sed -i '/192\.168\.0\.0\/16/ s/^/#/' /usr/share/passwall2/utils.sh
# 局域網IP規則復原
sed -i 's/^[[:space:]]*#\(.*192\.168\.0\.0\/16.*\)/\1/' /usr/share/passwall2/utils.sh
# 檢測規則
grep '192\.168\.0\.0/16' /usr/share/passwall2/utils.sh
# 列出nftables規則
nft list table inet passwall2 | grep -E '192\.168|passwall2_lan'
```
-->

# DNS配置
## 方案一 (DNS入口: passwall2, 直連流入dnsmasq)
1. DNS 重定向: true


## 方案二 (DNS入口: mosdns, 由mosdns處理後再入passwall2 -> 多DNS備選):
1. passwall2, DNS 重定向: false
2. mosdns, DNS 轉發: true
3. mosdns, DNS 重定向: true


## 方案三 (DNS入口: mosdns, 由mosdns處理後再入passwall2 -> 多DNS備選):
1. passwall2, DNS 重定向: false
2. mosdns, DNS 轉發: true
3. mosdns, DNS 重定向: true