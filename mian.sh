#!/bin/bash
clear
ip_address=$(ifconfig 2>/dev/null | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}' | head -1)
echo "
By: wjsw3369

 欢迎使用 MCSManager-for-Android 小白辅助脚本
 "
echo "本机IP地址： $ip_address"
echo '
bash <(curl -sSL https://raw.githubusercontent.com/HSOS6/MCSManager-for-Android/main/mian.sh)

'

# 修复 Termux 下 Node.js OpenSSL 兼容性问题
fix_termux_node() {
    echo "> 修复 Termux Node.js 环境..."
    echo ""
    echo "  执行以下步骤:"
    echo "  1. 更新 Termux 软件包..."
    pkg update -y && pkg upgrade -y
    echo "  2. 重新安装 Node.js LTS..."
    pkg install nodejs-lts -y
    echo "  3. 验证 Node.js..."
    node -v
    echo ""
    echo "> 修复完成！请重新尝试启动守护进程和Web进程。"
    echo "> 如果仍然报错，请在终端手动执行:"
    echo "  export NODE_OPTIONS=--openssl-legacy-provider"
}

# 获取脚本所在目录（兼容本地运行和远程curl运行）
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

# 一键安装MCSManager-for-Android
MCSManager_Android() {
    echo "> 安装 MCSManager-for-Android"
    if [ -f "$SCRIPT_DIR/install.sh" ]; then
        bash "$SCRIPT_DIR/install.sh"
    else
        bash <(curl -sSL https://raw.githubusercontent.com/HSOS6/MCSManager-for-Android/main/install.sh)
    fi
}

# 安装java21环境
java_install() {
    if [ -f "$SCRIPT_DIR/java21install.sh" ]; then
        bash "$SCRIPT_DIR/java21install.sh"
    else
        bash <(curl -sSL https://raw.githubusercontent.com/HSOS6/MCSManager-for-Android/main/java21install.sh)
    fi
}

# 查找 MCSManager 目录
find_mcsm_dir() {
    if [ -d ~/mcsm/daemon ]; then
        echo "$HOME/mcsm"
    elif [ -d ~/mcsm/panel ]; then
        echo "$HOME/mcsm"
    else
        echo ""
    fi
}

# 启动守护进程
start_Daemon() {
    echo "> 启动守护进程"
    export NODE_OPTIONS=--openssl-legacy-provider
    if [ -d ~/mcsm/daemon ]; then
        cd ~/mcsm/daemon
    elif [ -d ~/mcsm/panel ]; then
        cd ~/mcsm/panel
    else
        echo "错误: 找不到 MCSManager 目录，请先执行选项1安装"
        return
    fi
    node app.js
}

# 启动web进程
start_web() {
    echo "> 启动Web进程"
    export NODE_OPTIONS=--openssl-legacy-provider
    if [ -d ~/mcsm/web ]; then
        cd ~/mcsm/web
    elif [ -d ~/mcsm/panel ]; then
        cd ~/mcsm/panel
    else
        echo "错误: 找不到 MCSManager 目录，请先执行选项1安装"
        return
    fi
    node app.js
}

# 卸载MCSManager
uninstall_MCSManager() {
    echo "> 卸载 MCSManager"
    if [ -f "$SCRIPT_DIR/uninstall.sh" ]; then
        bash "$SCRIPT_DIR/uninstall.sh"
    else
        bash <(curl -sSL https://raw.githubusercontent.com/HSOS6/MCSManager-for-Android/main/uninstall.sh)
    fi
}

# 一键后台启动守护进程+Web面板
start_all_background() {
    MCSM_DIR=$(find_mcsm_dir)
    if [ -z "$MCSM_DIR" ]; then
        echo "错误: 找不到 MCSManager 目录，请先执行选项1安装"
        return
    fi

    export NODE_OPTIONS=--openssl-legacy-provider
    LOG_DIR="$MCSM_DIR/logs"
    mkdir -p "$LOG_DIR"

    # 停止旧进程
    pkill -f "node.*app.js" 2>/dev/null
    sleep 1

    echo "> 后台启动守护进程..."
    DAEMON_DIR="$MCSM_DIR/daemon"
    if [ ! -d "$DAEMON_DIR" ]; then
        DAEMON_DIR="$MCSM_DIR/panel"
    fi
    cd "$DAEMON_DIR"
    nohup node app.js > "$LOG_DIR/daemon.log" 2>&1 &
    echo "  守护进程 PID: $!"

    echo "> 后台启动Web面板..."
    WEB_DIR="$MCSM_DIR/web"
    if [ ! -d "$WEB_DIR" ]; then
        WEB_DIR="$MCSM_DIR/panel"
    fi
    cd "$WEB_DIR"
    nohup node app.js > "$LOG_DIR/web.log" 2>&1 &
    echo "  Web面板 PID: $!"

    echo ""
    echo "============================================"
    echo "  后台启动完成！"
    echo "  守护进程日志: $LOG_DIR/daemon.log"
    echo "  Web面板日志:  $LOG_DIR/web.log"
    echo "  浏览器访问:   http://localhost:23333/"
    echo "============================================"
}

# 查看运行日志
view_logs() {
    MCSM_DIR=$(find_mcsm_dir)
    LOG_DIR="$MCSM_DIR/logs"

    if [ ! -d "$LOG_DIR" ]; then
        echo "暂无日志，请先执行一键后台启动"
        return
    fi

    echo "> 查看 MCSManager 运行日志 (Ctrl+C 退出)"
    echo ""
    echo "============================================"
    echo "  守护进程日志 (daemon.log):"
    echo "============================================"
    if [ -f "$LOG_DIR/daemon.log" ]; then
        tail -20 "$LOG_DIR/daemon.log"
    else
        echo "  (暂无日志)"
    fi

    echo ""
    echo "============================================"
    echo "  Web面板日志 (web.log):"
    echo "============================================"
    if [ -f "$LOG_DIR/web.log" ]; then
        tail -20 "$LOG_DIR/web.log"
    else
        echo "  (暂无日志)"
    fi
    echo ""
    echo "--- 实时日志输出 (Ctrl+C 退出) ---"
    tail -f "$LOG_DIR/daemon.log" "$LOG_DIR/web.log" 2>/dev/null
}

# 脚本入口
if [ $# -gt 0 ]; then
    # 如果有命令行参数，则直接执行对应的函数
    function_name="$1"
    echo "直接进入子功能 $function_name , 更多选项请运行以上命令"
    echo ">"
    shift
    $function_name "$@"
else
    echo ""
    echo "本脚本大部分操作基于 ZeroTermux"
    while true; do
        echo ""
        echo "请选择以下功能："
        echo "1. 安装MCSManager-for-Android"
        echo "2. 安装java-21环境"
        echo "3. 启动守护进程"
        echo "4. 启动Web进程"
        echo "5. 修复Termux-Node.js环境(解决OSSL报错)"
        echo "6. 卸载MCSManager"
        echo "7. 一键后台启动(守护进程+Web面板)"
        echo "8. 查看运行日志(Ctrl+C退出)"
        echo "q. 退出"
        echo ""
        read -p "请输入功能序号: " input
        case $input in
        1) MCSManager_Android ;;
        2) java_install ;;
        3) start_Daemon ;;
        4) start_web ;;
        5) fix_termux_node ;;
        6) uninstall_MCSManager ;;
        7) start_all_background ;;
        8) view_logs ;;
        'q') break ;;
        *) ;;
        esac
    done
fi
echo "脚本执行完毕"