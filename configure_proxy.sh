#!/bin/bash

# 获取Windows主机的IP地址
WIN_HOST_IP=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')

# 配置环境变量
cat <<EOT > /etc/environment
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
http_proxy="http://$WIN_HOST_IP:10808/"
https_proxy="http://$WIN_HOST_IP:10808/"
ftp_proxy="http://$WIN_HOST_IP:10808/"
no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
EOT

# 配置APT代理
cat <<EOT > /etc/apt/apt.conf.d/95proxies
Acquire::http::Proxy "http://$WIN_HOST_IP:10808/";
Acquire::https::Proxy "http://$WIN_HOST_IP:10808/";
Acquire::ftp::Proxy "http://$WIN_HOST_IP:10808/";
EOT

echo "Proxy set to $WIN_HOST_IP"
