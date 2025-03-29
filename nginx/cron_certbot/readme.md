# 不用 cloudflare flexible 的话 定时执行 certbot 更新 SSL 证书

# 赋予执行权限

chmod +x setup_cron_job.sh
chmod +x renew_and_reload.sh

# 执行自动添加 Cron Job 的脚本

./setup_cron_job.sh
