#!/bin/bash
#获取root权限
if [ "$EUID" -ne 0 ]
    then echo -e "\033[31m注意：此脚本需要root权限，正在尝试获取root权限...\033[0m"
    sudo "$0" "$1"
    exit
fi

usermod -aG $(eval echo ~${SUDO_USER}) docker
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://ctzga3he.mirror.aliyuncs.com"],
  "live-restore": true,
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload
systemctl restart docker
echo -e "\033[32mdocker 初始化完成！\033[0m" # 绿色
