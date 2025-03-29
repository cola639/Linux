#!/bin/bash

# 获取当前连接到本机的 IP 地址
ip_addr=$(who am i | awk '{print $NF}' | tr -d '()')

# 打印ip_addr
echo $ip_addr

# 添加当前IP地址到白名单
warp-cli add-excluded-route $ip_addr

# 添加所有路由连接IPV4!!不要使用
# warp-cli add-excluded-route 0.0.0.0/0

# 添加常用IP地址段
warp-cli add-excluded-route 112.94.0.0/16
warp-cli add-excluded-route 121.33.0.0/16

# 查看当前排除路由列表
# warp-cli excluded-routes
warp-cli get-excluded-routes

# 连接
warp-cli connect
