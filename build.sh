#!/bin/bash

# 编译脚本
echo "编译文字分享图应用..."

# 创建构建目录
mkdir -p build

# 编译Swift文件
swiftc \
    -o build/TextToShare \
    -framework Cocoa \
    *.swift

if [ $? -eq 0 ]; then
    echo "编译成功！"
    echo "可执行文件: build/TextToShare"
    echo ""
    echo "运行方法："
    echo "1. 双击运行 build/TextToShare"
    echo "2. 或在终端执行 ./build/TextToShare"
    echo ""
    echo "使用说明："
    echo "1. 复制任意文本 (⌘C)"
    echo "2. 按 ⌘⇧C 生成分享图"
    echo "3. 图片会自动复制到剪贴板"
    echo "4. 点击菜单栏图标可以打开预览窗口"
else
    echo "编译失败！"
    exit 1
fi