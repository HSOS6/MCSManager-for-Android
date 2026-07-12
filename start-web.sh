#!/bin/bash
# MCSManager Web 面板启动脚本
# 兼容 Termux 和标准 Linux 环境

# 修复 Termux 环境下 OpenSSL 兼容性问题
export NODE_OPTIONS=--openssl-legacy-provider

# 兼容新旧版 MCSManager 目录结构
if [ -d ~/mcsm/web ]; then
    cd ~/mcsm/web
elif [ -d ~/mcsm/panel ]; then
    cd ~/mcsm/panel
else
    echo "错误: 找不到 MCSManager 目录，请先运行 install.sh 安装"
    exit 1
fi

echo "============================================"
echo "  启动 MCSManager Web 面板 (Panel)"
echo "============================================"
echo ""

node app.js