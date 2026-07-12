**此仓库原于 [zhuyejun520/Android-for-MCSManager](https://github.com/zhuyejun520/Android-for-MCSManager)**

因原作者地址失效无法使用，固此修改及完善与创新

**最新更新 (2026-07-12):**
- 修复 Termux 环境下 Node.js OpenSSL 兼容性问题（`OSSL_PROVIDER_add_conf_parameter` 错误）
- 更新安装脚本，从 MCSManager 官方 GitHub Release 下载最新版本
- 兼容新版 MCSManager 目录结构（panel/daemon 目录）

---

### 前置工作：

更换清华源（也可在ZeroTermux左侧工具栏更换）

```shell
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list && apt update -y && apt upgrade -y
```

### 使用方法：

一. 拉取 mian.sh 运行 MCSManager-for-Android 小白辅助脚本

```shell
bash <(curl -sSL https://raw.githubusercontent.com/wjsw3369/MCSManager-for-Android/main/mian.sh)
```

```shell
By: wjsw3369

欢迎使用 MCSManager-for-Android 小白辅助脚本
 
本机IP地址：(你的IP地址，用于局域网连接等使用)

bash <(curl -sSL https://raw.githubusercontent.com/wjsw3369/MCSManager-for-Android/main/mian.sh)



本脚本大部分操作基于 ZeroTermux

请选择以下功能：
1. 安装MCSManager-for-Android
2. 安装java-21环境
3. 启动守护进程
4. 启动Web进程
5. 修复Termux-Node.js环境(解决OSSL报错)
q. 退出

请输入功能序号:
```

二. 输入 1 安装 MCSManager-for-Android

三. 输入 2 安装 java 环境

四. 输入 3 启动守护进程

五. 切换窗口，重新运行脚本，输入 4 启动 web 进程

六. 网页打开：http://localhost:23333/

---

### 常见问题解决

#### 问题1: `CANNOT LINK EXECUTABLE "node": cannot locate symbol "OSSL_PROVIDER_add_conf_parameter"`

**原因:** Termux 中的 Node.js 与 OpenSSL 版本不兼容。

**解决方法 (按顺序尝试):**

方法一（推荐）：在脚本菜单中选择 `5. 修复Termux-Node.js环境`

方法二：手动执行以下命令：
```shell
pkg update -y && pkg upgrade -y
pkg install nodejs-lts -y
```

方法三：如果以上方法无效，在启动前设置环境变量：
```shell
export NODE_OPTIONS=--openssl-legacy-provider
```
然后再启动守护进程或 Web 进程。

===========================================================================

国内加速脚本：

  gitee：---
    
  cloudflare代理：[proxy分支](https://github.com/wjsw3369/MCSManager-for-Android/tree/proxy)