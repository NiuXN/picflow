#!/bin/bash

# Flutter 环境配置脚本

echo "开始配置 Flutter 运行环境..."

# 1. 配置 ANDROID_HOME 环境变量
echo "配置 ANDROID_HOME 环境变量..."
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/bin

# 将环境变量添加到 shell 配置文件
if [[ -f ~/.zshrc ]]; then
    echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/bin' >> ~/.zshrc
    echo "已添加环境变量到 ~/.zshrc"
elif [[ -f ~/.bash_profile ]]; then
    echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.bash_profile
    echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bash_profile
    echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bash_profile
    echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/bin' >> ~/.bash_profile
    echo "已添加环境变量到 ~/.bash_profile"
fi

# 2. 创建 cmdline-tools 目录结构
echo "创建 cmdline-tools 目录结构..."
mkdir -p $ANDROID_HOME/cmdline-tools/latest

# 3. 提示用户手动下载 cmdline-tools
echo ""
echo "请手动下载 Android SDK Command-line Tools:"
echo "1. 打开浏览器访问: https://developer.android.com/studio#command-line-tools-only"
echo "2. 下载 macOS 版本的 commandlinetools"
echo "3. 解压并移动到: $ANDROID_HOME/cmdline-tools/latest/"
echo "4. 确保目录结构为: $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
echo ""

# 4. 接受 Android SDK 许可证
echo "准备接受 Android SDK 许可证..."
echo "请在下载 cmdline-tools 后运行: sdkmanager --licenses"

# 5. 安装必要的 SDK 组件
echo ""
echo "安装必要的 SDK 组件..."
echo "请运行: sdkmanager \"platform-tools\" \"platforms;android-34\" \"build-tools;34.0.0\""

echo ""
echo "环境配置脚本执行完成!"
echo "请按照上述提示完成剩余步骤。"
