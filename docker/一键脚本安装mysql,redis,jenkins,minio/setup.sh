#!/bin/bash

# 检查 Docker 是否已安装
if ! command -v docker &>/dev/null; then
  echo "Docker 未安装，正在安装 Docker..."
  sudo apt-get update &&
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
    sudo apt-get update &&
    sudo apt-get install -y docker-ce &&
    docker --version
else
  echo "Docker 已安装，跳过 Docker 安装步骤。"
fi

# 检查 Docker Compose 是否已安装
if ! command -v docker-compose &>/dev/null; then
  echo "Docker Compose 未安装，正在安装 Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
    sudo chmod +x /usr/local/bin/docker-compose &&
    docker-compose --version
else
  echo "Docker Compose 已安装，跳过 Docker Compose 安装步骤。"
fi

# 设置 /www 目录的权限 日志 yml 等权限
echo "设置 /www 目录的权限..."
sudo mkdir -p /www/logs /www/yml
sudo chmod -R 777 /www

# 运行 docker-compose.yml
echo "安装 mysql redis jenkins minio 配置..."
# 使用 docker-compose 启动服务
docker-compose -f docker-compose.yml up -d

#!/bin/bash

echo "安装 mysql, redis, jenkins, minio 配置..."
# 使用 docker-compose 启动服务
docker-compose -f docker-compose.yml up -d

# 检查上一个命令是否成功
if [ $? -eq 0 ]; then
  echo "安装 mysql, redis, jenkins, minio 配置完成！"

  # 获取当前机器的 IP 地址
  CURRENT_IP=$(hostname -I | awk '{print $1}')

  # 等待 6 秒，让 Jenkins 完成初始化
  echo "等待 Jenkins 初始化，6 秒后安装Docker插件..."
  sleep 6

  JENKINS_CONTAINER="jenkins"
  INITIAL_PASSWORD_PATH="/var/jenkins_home/secrets/initialAdminPassword"

  # 检查 Jenkins 容器是否在运行
  if [ $(docker ps -q -f name=$JENKINS_CONTAINER) ]; then
    # 安装 Docker
    echo "正在安装 Docker 到 Jenkins 容器中..."
    docker exec -it $JENKINS_CONTAINER bash -c "
    apt-get update && \
    apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian \$(lsb_release -cs) stable\" && \
    apt-get update && apt-get install -y docker-ce && \
    echo 'Docker 安装完成' &&
    docker --version
  "

    # 打印各个服务的访问地址
    echo "访问地址："
    echo "MySQL: mysql://$CURRENT_IP:3306"
    echo "Redis: redis://$CURRENT_IP:6379"
    echo "MinIO 控制台: http://$CURRENT_IP:9090"
    echo "MinIO 对象存储: http://$CURRENT_IP:9000"
    echo "Jenkins: http://$CURRENT_IP:8080"
    # 输出 Jenkins 容器内的初始管理员密码
    echo "Jenkins 初始管理员密码如下："
    docker exec $JENKINS_CONTAINER cat $INITIAL_PASSWORD_PATH
  else
    echo "无法找到 Jenkins 容器，或容器未启动，请检查 Jenkins 容器是否正确启动。"
  fi

else
  echo "安装过程中出现错误，请检查日志。"
fi
