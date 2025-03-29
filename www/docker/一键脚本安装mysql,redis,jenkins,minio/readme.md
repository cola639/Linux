# 一键部署 mysql redis jenkins

# 文件夹放到同一目录 注意 Vscode LF 格式写 sh 脚本

# 赋予权限 当前目录执行 setup.sh

chmod +x setup.sh
./setup.sh

# Jenkins 运行安装需要 docker

chmod +x start_jenkins_with_docker.sh
./start_jenkins_with_docker.sh

# 命令行安装 jenkins

docker-compose -f jenkins.yml up -d

FAQ

# 彻底删除 jenkins

docker stop jenkins
docker rm jenkins
docker rmi jenkins/jenkins:lts
sudo rm -rf /var/lib/jenkins # 如果你使用的是默认的 Jenkins 数据目录
sudo rm -rf /home/jenkins # 如果你在 docker-compose.yml 中指定了该路径

# 彻底删除容器

docker stop $(docker ps -aq) # 停止全部容器
docker rm $(docker ps -aq) # 删除全部容器
docker rmi $(docker images -aq) # 删除全部镜像

# 进去 jenkins 容器查看密码

docker exec -it jenkins /bin/bash
cat /var/jenkins_home/secrets/initialAdminPassword

# 进去 jenkins 插件 docker pipeline

插件市场安装 docker pipeline

# 进去 jenkins 配置 docker

docker exec -it jenkins bash

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

dockerd &

ps aux | grep dockerd # 检查 Docker 是否已经在运行

docker --version

sudo chmod -R 755 /path/to/jenkins_home
sudo chown -R 1000:1000 /path/to/jenkins_home

# 查找 容器挂载的卷

docker inspect jenkins
ctrl + f 搜索 Mounts 查看挂载的卷

# 检测网络容器

docker network ls
docker network inspect bridge
docker network inspect web

ctrl + f 搜索 containers 查看挂载的卷
docker logs colaclub-admin
