#!/bin/bash

# 1. 替换 /etc/nginx/conf/nginx.conf
if [ -f "./nginx.conf" ]; then
    echo "复制并替换 /etc/nginx/conf/nginx.conf..."
    sudo cp ./nginx.conf /etc/nginx/conf/nginx.conf
else
    echo "当前目录下未找到 nginx.conf 文件。"
    exit 1
fi

# 2. 确保 /www/ 目录存在，如果不存在则创建
if [ ! -d "/www" ]; then
    echo "创建 /www 目录..."
    sudo mkdir /www
fi

# 3. 复制 conf 文件夹到 /www/
if [ -d "./conf" ]; then
    echo "复制 conf 文件夹到 /www/..."
    sudo cp -r ./conf /www/
else
    echo "当前目录下未找到 conf 文件夹。"
    exit 1
fi

# 4. 重启Nginx服务
echo "重启Nginx服务..."
sudo systemctl restart nginx

# 5. 完成提示
echo "操作完成。"
