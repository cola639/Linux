#!/bin/bash

# 定义Cron Job内容
cron_job="0 5 * * * /path/to/renew_and_reload.sh >> /var/log/cron_certbot.log 2>&1"

# 检查Cron Job是否已经存在
(crontab -l | grep -q "$cron_job") && echo "Cron job already exists" || (
    # 如果不存在，则添加到Cron Job
    (crontab -l; echo "$cron_job") | crontab -
    echo "Cron job added successfully"
)

# 提示用户确认Cron Job已设置
echo "Current crontab:"
crontab -l
