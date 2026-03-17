# 私有IP代理

## 修改代碼(方案一)
開啟fakedns (修改後清理Cookies+DNS)


## 修改代碼(方案二)
1. Wifi設定Openwrt的Socks代理
```
* 此方案可以繞過Nftables透明代理, 導致的XrayServer分流DNS洩漏
* 缺點: 如果passwall2關閉後直連也無法連線
```

## 修改代碼(方案三)
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