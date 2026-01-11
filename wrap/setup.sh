#!/bin/bash

# 更新系统并安装依赖
sudo apt update && sudo apt upgrade -y

# 安装 Cloudflare WARP
sudo dpkg -i ./cloudflare_warp.deb
sudo apt --fix-broken install -y
sudo dpkg -i ./cloudflare_warp.deb

# 注册 WARP
warp-cli register

# 查看 cron 服务状态
systemctl status cron

# 设置时区为上海
sudo timedatectl set-timezone Asia/Shanghai

# 打开 crontab 编辑器来编辑定时任务
echo "0 6 * * * bash /a_script/warp_close.sh" | sudo crontab -
echo "0 19 * * * bash /a_script/warp_close.sh" | sudo crontab -

# 刷新 cron 服务以使新的定时任务生效
sudo systemctl restart cron

# 执行开启 WARP 的脚本
bash /a_script/warp_open.sh
