#!/bin/bash

# 网络名称
NETWORK="tldraw" # 根据实际情况修改网络名称

# 后端容器名称
BACK_CONTAINER="tldraw-server" # 根据实际情况修改容器名称

# 前端容器名称
FRONT_CONTAINER="tldraw-ui" # 根据实际情况修改容器名称

# 检查 Docker 网络是否存在
if [ $(docker network ls | grep -c $NETWORK) -eq 0 ]; then
    echo "Creating Docker network: $NETWORK"
    docker network create $NETWORK
else
    echo "Docker network $NETWORK already exists"
fi

# 检查容器是否存在并连接到网络
connect_container_to_network() {
    CONTAINER_NAME=$1
    if [ $(docker ps -a --format "{{.Names}}" | grep -c $CONTAINER_NAME) -eq 0 ]; then
        echo "Container $CONTAINER_NAME does not exist"
    else
        if [ $(docker network inspect $NETWORK --format "{{json .Containers}}" | grep -c $CONTAINER_NAME) -eq 0 ]; then
            echo "Connecting $CONTAINER_NAME to $NETWORK"
            docker network connect $NETWORK $CONTAINER_NAME
        else
            echo "Container $CONTAINER_NAME is already connected to $NETWORK"
        fi
    fi
}

# 连接后端容器到网络
connect_container_to_network $BACK_CONTAINER

# 连接前端容器到网络
connect_container_to_network $FRONT_CONTAINER

echo "Setup completed."

# 1 创建网络组
# 2 连结已运行前后端容器
# 3 配置nginx
# docker network create yws
# docker network connect yws y-websocket
# docker network inspect yws
# docker network connect yws nginx-y-websocket
# curl http://<宿主机IP>:1235
# docker-compose down
# docker-compose up -d
