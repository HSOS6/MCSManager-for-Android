#!/bin/bash
# MCSManager-for-Android 安装脚本
# 最后更新: 2026-07-12

echo "============================================"
echo "  MCSManager-for-Android 安装脚本"
echo "============================================"

# 第一步：更新 Termux 环境（修复 OpenSSL 兼容性问题）
echo ""
echo "> [1/4] 更新 Termux 软件包..."
pkg update -y && pkg upgrade -y

# 第二步：安装 Node.js（从 Termux 官方源安装，确保 OpenSSL 兼容）
echo ""
echo "> [2/4] 安装 Node.js 运行环境..."
pkg install nodejs-lts -y

# 验证 Node.js 是否可用
if ! command -v node &> /dev/null; then
    echo "> Node.js 安装失败，尝试安装 nodejs..."
    pkg install nodejs -y
fi

echo "Node.js 版本: $(node -v)"
echo "npm 版本: $(npm -v)"

# 设置 OpenSSL 兼容模式（防止 legacy provider 错误）
export NODE_OPTIONS=--openssl-legacy-provider

# 第三步：安装下载工具，下载最新 MCSManager 官方 Release
echo ""
echo "> [3/4] 下载最新版 MCSManager..."

# 确保下载工具可用
if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
    echo "  安装 wget..."
    pkg install wget -y 2>/dev/null || true
fi

# 封装下载函数
download_file() {
    local url="$1"
    local output="$2"
    if command -v wget &> /dev/null; then
        wget -O "$output" "$url" --timeout=30
    elif command -v curl &> /dev/null; then
        curl -L -o "$output" "$url" --connect-timeout 30
    else
        return 1
    fi
}

cd ~
rm -rf ~/mcsm
mkdir -p ~/mcsm
cd ~/mcsm

# 从 GitHub 官方 Release 下载最新版本
MCSM_URL="https://github.com/MCSManager/MCSManager/releases/latest/download/mcsmanager_linux_release.tar.gz"
MCSM_FALLBACK_URL="https://github.com/MCSManager/MCSManager/releases/download/v10.16.2/mcsmanager_linux_release.tar.gz"

echo "  下载地址: $MCSM_URL"
echo "  正在下载中，请稍候..."

# 尝试下载，如果失败则使用备用镜像
if ! download_file "$MCSM_URL" mcsmanager.tar.gz; then
    echo "> GitHub 下载失败，尝试使用镜像..."
    download_file "$MCSM_FALLBACK_URL" mcsmanager.tar.gz || {
        echo "> 下载失败！请检查网络连接。"
        echo "> 手动下载地址: https://github.com/MCSManager/MCSManager/releases"
        exit 1
    }
fi

echo "  解压中..."
tar -xzf mcsmanager.tar.gz
rm -f mcsmanager.tar.gz

# 自适应目录结构：如果 daemon/web 不在当前目录，从子目录中移出
if [ ! -d "daemon" ] && [ ! -d "web" ]; then
    # 查找包含 daemon 或 web 的子目录
    SUBDIR=$(find . -maxdepth 2 -type d -name "daemon" 2>/dev/null | head -1)
    if [ -n "$SUBDIR" ]; then
        PARENT_DIR=$(dirname "$SUBDIR")
        echo "  检测到压缩包包含父目录: $PARENT_DIR"
        mv "$PARENT_DIR"/* . 2>/dev/null
        mv "$PARENT_DIR"/.[!.]* . 2>/dev/null
        rmdir "$PARENT_DIR" 2>/dev/null
    fi
fi

# 验证目录结构
if [ ! -d "daemon" ] && [ ! -d "web" ]; then
    echo "  警告: 未找到 daemon/web 目录，当前目录内容:"
    ls -la
fi

# Termux 兼容：修补 daemon/app.js 中的管道目录路径（/tmp 在 Termux 中为只读）
if [ -f "daemon/app.js" ]; then
    sed -i 's|"/tmp/mcsmanager-instance-pipe"|os_1.default.tmpdir() + "/mcsmanager-instance-pipe"|g' daemon/app.js
    echo "  已修补守护进程管道目录路径"
fi

# Termux 兼容：Node.js 在 Termux 中返回 android 平台，需创建 linux->android 软链接
if [ -d "daemon/lib" ]; then
    cd ~/mcsm/daemon/lib
    for f in pty_linux_arm64 file_zip_linux_arm64; do
        if [ -f "$f" ]; then
            ANDROID_NAME="${f//linux_/android_}"
            if [ ! -f "$ANDROID_NAME" ]; then
                echo "  创建 Termux 兼容链接: $f -> $ANDROID_NAME"
                ln -sf "$f" "$ANDROID_NAME"
            fi
        fi
    done
    cd ~/mcsm
fi

# 第四步：安装依赖
echo ""
echo "> [4/4] 安装项目依赖..."

# 安装 Web 面板依赖
if [ -d "web" ]; then
    echo "  安装 Web 面板依赖..."
    cd ~/mcsm/web
    NODE_OPTIONS=--openssl-legacy-provider npm install --production --registry=https://registry.npmmirror.com/ 2>/dev/null || \
    NODE_OPTIONS=--openssl-legacy-provider npm install --production --registry=https://registry.npmmirror.com/
fi

# 安装守护进程依赖
if [ -d "daemon" ]; then
    echo "  安装守护进程依赖..."
    cd ~/mcsm/daemon
    NODE_OPTIONS=--openssl-legacy-provider npm install --production --registry=https://registry.npmmirror.com/ 2>/dev/null || \
    NODE_OPTIONS=--openssl-legacy-provider npm install --production --registry=https://registry.npmmirror.com/
fi

# 检查 MCSManager 目录结构（兼容不同版本）
if [ ! -d "~/mcsm/web" ] && [ -d "~/mcsm/panel" ]; then
    echo "> 检测到新版 MCSManager 目录结构，创建软链接..."
    ln -sf ~/mcsm/panel ~/mcsm/web
fi

echo ""
echo "============================================"
echo "  安装完成！"
echo "============================================"
echo ""
echo "  使用方法:"
echo "  1. 运行 start-daemon.sh 启动守护进程"
echo "  2. 新开终端，运行 start-web.sh 启动 Web 面板"
echo "  3. 浏览器访问 http://localhost:23333/"
echo ""
echo "  如果遇到 Node.js 启动错误:"
echo "  在终端执行: export NODE_OPTIONS=--openssl-legacy-provider"
echo "  然后重新启动即可"
echo ""