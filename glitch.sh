######请添加环境变量"uuid",否则xray无效
#删除panindex并重新启动以更新PanIndex.

#!/bin/bash

chmod 777 ~/nginx/sbin/nginx

if [ ! -f "xray" ];then
  curl -L https://github.com/XTLS/Xray-core/releases/download/v1.5.3/Xray-linux-64.zip -o xray.zip
unzip -o xray.zip
rm -f xray.zip
fi
chmod +x xray

if [ $uuid ];then
    cat > config.json <<EOF
{
    "log": null,
    "routing": {
      "rules": [
        {
          "inboundTag": [
            "api"
          ],
          "outboundTag": "api",
          "type": "field"
        },
        {
          "ip": [
            "geoip:private"
          ],
          "outboundTag": "blocked",
          "type": "field"
        },
        {
          "outboundTag": "blocked",
          "protocol": [
            "bittorrent"
          ],
          "type": "field"
        }
      ]
    },
    "dns": null,
    "inbounds": [
      {
        "listen": "127.0.0.1",
        "port": 62789,
        "protocol": "dokodemo-door",
        "settings": {
          "address": "127.0.0.1"
        },
        "streamSettings": null,
        "tag": "api",
        "sniffing": null
      },
{
    "listen": null,
    "port": 23333,
    "protocol": "vless",
    "settings": {
      "clients": [
        {
          "id": "$uuid",
          "flow": "xtls-rprx-direct"
        }
      ],
      "decryption": "none",
      "fallbacks": [
        {
          "name": "panindex",
          "alpn": "",
          "path": "",
          "dest": "5238",
          "xver": 0
        }
      ]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "none",
      "tcpSettings": {
        "header": {
          "type": "http",
          "request": {
            "method": "GET",
            "path": [
              "/"
            ],
            "headers": {}
          },
          "response": {
            "version": "1.1",
            "status": "200",
            "reason": "OK",
            "headers": {}
          }
        }
      }
    },
    "tag": "inbound-23333",
    "sniffing": {
      "enabled": true,
      "destOverride": [
        "http",
        "tls"
      ]
    }
  }
],
"outbounds": [
  {
    "protocol": "freedom",
    "settings": {}
  },
  {
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }
],
"transport": null,
"policy": {
  "system": {
    "statsInboundDownlink": true,
    "statsInboundUplink": true
  }
},
"api": {
  "services": [
    "HandlerService",
    "LoggerService",
    "StatsService"
  ],
  "tag": "api"
},
"stats": {},
"reverse": null,
"fakeDns": null
}
EOF
fi

if [ ! -f "panindex" ];then
  curl -L https://github.com/libsgh/PanIndex/releases/latest/download/PanIndex-linux-amd64.tar.gz -o panindex.tar.gz
tar -zxvf panindex.tar.gz
mv PanIndex-linux-amd64 panindex
rm -f panindex.tar.gz & rm -f LICENSE
fi
chmod +x panindex


./xray &
./panindex
