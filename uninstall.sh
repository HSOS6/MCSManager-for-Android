#!/bin/bash
# MCSManager-for-Android 卸载脚本

echo "============================================"
echo "  MCSManager-for-Android 卸载脚本"
echo "============================================"
echo ""

MCSM_DIR="$HOME/mcsm"

if [ ! -d "$MCSM_DIR" ]; then
    echo "未检测到 MCSManager 安装目录 ($MCSM_DIR)，无需卸载。"
    exit 0
fi

echo "检测到 MCSManager 安装目录: $MCSM_DIR"
echo ""
echo "此操作将删除以下内容:"
echo "  - $MCSM_DIR (MCSManager 全部文件)"
echo ""

read -p "确认卸载? (输入 yes 确认): " confirm

if [ "$confirm" != "yes" ]; then
    echo "已取消卸载。"
    exit 0
fi

echo ""
echo "正在停止 MCSManager 进程..."
# 停止所有 MCSManager 相关 node 进程
pkill -f "node.*mcsm" 2>/dev/null
pkill -f "node.*app.js" 2>/dev/null

echo "正在删除 MCSManager 文件..."
rm -rf "$MCSM_DIR"

echo ""
echo "============================================"
echo "  卸载完成！"
echo "============================================"
echo ""
echo "  MCSManager 已从系统中移除。"
echo "  如需重新安装，请运行 install.sh"
echo ""