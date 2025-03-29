# ubuntu 一键部署 warp 访问 gpt

创建一个 a_script 全部文件都放进去
chmod +x setup.sh
./setup.sh

# warp 安装 PS 在 deb 安装包目录打开命令行 注意 sudo apt --fix-broken install -y 避免依赖失败问题

sudo dpkg -i cloudflare_warp.deb
apt --fix-broken install
sudo dpkg -i cloudflare_warp.deb
sudo apt update
sudo apt upgrade
warp-cli register
warp-cli --help

# 查看 cron 定时任务状态 active (running)为正常

systemctl status cron

# cron 设置执行时区

sudo timedatectl set-timezone Asia/Shanghai

# 打开定时任务

# 在 nano 编辑器中，您可以按 Ctrl + X，然后按 Y，再按 Enter 来保存。在 vi 或 vim 编辑器中，您可以按 :wq 然后按 Enter 来保存。

sudo crontab -e

# 配置每天 6 点/19 点 关闭 warp-cli

0 6 \* \* _ bash /a_script/warp_close.sh
0 19 _ \* \* bash /a_script/warp_close.sh

# 刷新 cron 定时任务

sudo systemctl restart cron

# 开启 warp 脚本

bash /a_script/warp_open.sh

# 关闭 warp

bash /a_script/warp_close.sh

# 检查时区

timedatectl

# 选择编辑器

select-editor

# 查看 cron 定时任务日志

grep CRON /var/log/syslog

# 移除 IP

warp-cli remove-excluded-route 112.94.0.0/16
