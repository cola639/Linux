#!/bin/bash

# 1. 更新SSL证书
/usr/bin/certbot renew --quiet

# 2. 复制更新后的证书到指定目录
cp /etc/letsencrypt/live/win-gavin.top/fullchain.pem /www/docker/public/public.pem
cp /etc/letsencrypt/live/win-gavin.top/privkey.pem /www/docker/public/public-key.pem

# 3. 重启Nginx服务以应用新的证书
/usr/sbin/nginx -s reload

# 4. 输出操作完成提示
echo "SSL证书更新并应用成功，Nginx已重启。"
