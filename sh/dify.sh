#!/bin/bash

# 安装docker docker-compose git
# 更新软件包列表
sudo apt-get update

# 安装必备工具
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 的官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 添加 Docker 的 APT 软件包仓库
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 更新软件包列表以包含 Docker 的软件包
sudo apt-get update
''
# 安装 Docker CE（社区版）
sudo apt-get install -y docker-ce

# 安装 Git
sudo apt-get install -y git

# 检查 Docker 是否已正确安装
sudo systemctl status docker

# 启动 Docker 并设置为开机自启动
sudo systemctl start docker
sudo systemctl enable docker

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 设置 Docker Compose 为可执行文件
sudo chmod +x /usr/local/bin/docker-compose

# 验证 Docker Compose 是否已正确安装
docker-compose --version

# 验证 Git 是否已正确安装
git --version
echo "Docker, Docker Compose, and Git have been successfully installed!"

# git clone dify
git clone https://github.com/dify-ai/dify.git

cd docker
cp .env.example .env
docker compose up -d
echo "Dify has been successfully installed!"
