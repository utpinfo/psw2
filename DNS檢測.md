# TCP測試拥塞實際行為（真實流量）
```
# 延遲測試 [傳輸層]
ping www.facebook.com

# -r：報告模式, -w：完整顯示, -z：顯示 AS(判斷 CN2), -b：IP + hostname, -c 100：測100 次, --tcp：模擬真實流量, -P 443：模擬 HTTPS / Reality, -s 1400：模擬真實封包
mtr -rwzbc100 --tcp -P 10001 -s 1400 116.236.30.11

# 兩個節點之間的極限吞吐量(bandwidth), 延遲(Latency)較不完整, -P: 4線， -R： 反向
iperf3 -c server -P 4 #多線（-P 4 / 8）
# iperf3 -c server -R

# 延遲測試 [應用層]
curl -o /dev/null -s -w "\
dns: %{time_namelookup}\n\
connect: %{time_connect}\n\
tls: %{time_appconnect}\n\
first_byte: %{time_starttransfer}\n\
total: %{time_total}\n" https://www.netflix.com \
| awk '{printf "%s %s ms\n", $1, $2*1000}'


# 診斷速度慢、延遲高、丟包 [傳輸層]
ss -ti
```

# WireShark

## DNS測試
```filter
1. 查詢所有DNS
dns
|| tcp.port == 853
|| udp.port == 5353
|| udp.port == 5355
|| udp.port == 137
|| tls
|| quic
tls.handshake.extensions_server_name

2. DNS查詢
dns && dns.flags.response == 0

3. DNS回應
dns && dns.flags.response == 1
```


# iPhone testing using Mac RVI (Remote Virtual Interface)
```shell
rvictl -s 00008140-001128861813C01C
```