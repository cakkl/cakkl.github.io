#!/bin/bash

# 判断是否为ubuntu系统
if [ ! -f /etc/os-release ]; then
    echo "此脚本仅支持ubuntu系统"
    exit 1
fi

# 获取root权限
if [ "$EUID" -ne 0 ]
    then echo "注意：此脚本需要root权限，正在尝试获取root权限..."
    sudo "$0" "$@"
    exit
fi

# 更换清华源
echo "更换清华源..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list << EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF

apt update && apt full-upgrade

# 配置环境
echo ""
echo "配置环境..."
cat >> $(eval echo ~${SUDO_USER})/.bashrc << EOF
alias df='df -h'
alias du='du -h'

alias dc='exit'
EOF
source $(eval echo ~${SUDO_USER})/.bashrc

cat >> $(eval echo ~${SUDO_USER})/.profile << EOF
if [ -d "$HOME/scripts" ] ; then
    PATH="$PATH:$HOME/scripts"
fi

export LESSHISTFILE=-
EOF
source $(eval echo ~${SUDO_USER})/.profile

# 安装常用软件
echo ""
echo "安装常用软件..."
apt install aptitude nmap net-tools -y > /dev/null 2>&1

# 安装中文语言包
echo ""
echo "安装中文语言包..."

apt install language-pack-zh-hans manpages-zh -y > /dev/null 2>&1
echo "zh_CN.UTF-8" | tee /etc/locale-gen > /dev/null
locale-gen > /dev/null 2>&1
echo "LANG=zh_CN.UTF-8" | tee /etc/default/locale > /dev/null
echo ""
echo "请重启终端以应用语言包！"
