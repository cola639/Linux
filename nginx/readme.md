# 一键部署 nginx 配置 注意是否开启了 cloudflare

# nginx 文件夹放到同一目录 注意 Vscode LF 格式写 sh 脚本

# 赋予权限 当前目录执行 setup.sh

chmod +x setup.sh
./setup.sh

# 最佳方式 使用 cloudflare flexible

使用 cloudflare flexible

# 重启 nginx

systemctl restart nginx
