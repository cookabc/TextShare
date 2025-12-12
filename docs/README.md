# TextToShare 项目文档

欢迎来到 TextToShare 项目的技术文档！这里包含了学习该 macOS 应用所需的全部技术资料。

## 📖 文档简介

TextToShare 是一个轻量级的 macOS 应用，可以将剪贴板中的文本快速转换为美观的分享图片。本项目使用 Swift 和 AppKit 开发，展示了如何创建一个功能完整且用户友好的桌面工具。

## 🎯 学习目标

通过这些文档，您将学到：
- macOS 应用的基础架构设计
- AppKit 框架的核心使用
- 全局快捷键的实现方法
- 图片生成和文本渲染技术
- 剪贴板操作和安全机制
- 主题系统的设计与实现
- 后台应用的开发模式

## 📚 学习路径

### 1. 快速入门路径（30分钟）
适合想快速了解项目概览的开发者：

1. [📋 项目概览](01-overview.md) - 了解项目背景和功能
2. [🏗️ 架构设计](02-architecture.md) - 理解整体架构
3. [⚙️ 开发指南](10-development-guide.md) - 搭建开发环境

### 2. 深入学习路径（2小时）
适合需要全面掌握项目实现的开发者：

1. [📋 项目概览](01-overview.md)
2. [🏗️ 架构设计](02-architecture.md)
3. [🚀 程序入口](03-main-entry.md)
4. [🎮 应用代理](04-app-delegate.md)
5. [🎨 图片生成](05-image-generator.md)
6. [🖼️ 预览窗口](06-popup-window.md)
7. [🔧 构建系统](07-build-system.md)
8. [🎨 主题系统](08-themes-system.md)
9. [📋 剪贴板集成](09-clipboard-integration.md)
10. [⚙️ 开发指南](10-development-guide.md)

### 3. 专题学习路径
根据兴趣选择特定方向深入学习：

#### UI 开发方向
- [🖼️ 预览窗口](06-popup-window.md) → [🎨 主题系统](08-themes-system.md)

#### 图形处理方向
- [🎨 图片生成](05-image-generator.md) → [📋 剪贴板集成](09-clipboard-integration.md)

#### 系统集成方向
- [🚀 程序入口](03-main-entry.md) → [🎮 应用代理](04-app-delegate.md) → [🔧 构建系统](07-build-system.md)

## 📑 文档列表

| 文档 | 描述 | 关键内容 |
|------|------|----------|
| [01-overview.md](01-overview.md) | 项目概览 | 功能介绍、技术栈、应用场景 |
| [02-architecture.md](02-architecture.md) | 架构设计 | 模块划分、设计模式、数据流 |
| [03-main-entry.md](03-main-entry.md) | 程序入口 | main.swift 解析、应用初始化 |
| [04-app-delegate.md](04-app-delegate.md) | 应用代理 | 生命周期管理、快捷键、状态栏 |
| [05-image-generator.md](05-image-generator.md) | 图片生成 | 文本渲染、主题实现、图片算法 |
| [06-popup-window.md](06-popup-window.md) | 预览窗口 | UI 布局、事件处理、窗口管理 |
| [07-build-system.md](07-build-system.md) | 构建系统 | 编译脚本、配置文件、打包部署 |
| [08-themes-system.md](08-themes-system.md) | 主题系统 | 主题配置、颜色系统、扩展方法 |
| [09-clipboard-integration.md](09-clipboard-integration.md) | 剪贴板集成 | NSPasteboard 使用、权限管理 |
| [10-development-guide.md](10-development-guide.md) | 开发指南 | 环境搭建、调试技巧、最佳实践 |

## 💡 使用建议

1. **配合源码阅读**：建议将代码和文档对照阅读，加深理解
2. **动手实践**：按照文档中的建议尝试修改代码，观察效果
3. **循序渐进**：按推荐的学习路径逐步深入，不要跳跃式学习
4. **做好笔记**：记录关键概念和自己的理解
5. **查阅参考**：遇到不明白的概念时，查阅 Apple 官方文档

## 🛠️ 技术栈

- **语言**: Swift 5.0+
- **框架**: AppKit, Foundation, CoreGraphics
- **工具**: Swift 编译器（命令行）
- **平台**: macOS 13.0+

## 📄 项目文件结构

```
TextToShare/
├── AppDelegate.swift      # 应用代理
├── ImageGenerator.swift   # 图片生成引擎
├── PopupWindow.swift      # 预览窗口
├── main.swift            # 程序入口
├── Info.plist           # 应用配置
├── build.sh             # 构建脚本
└── docs/                # 📖 本文档目录
    └── *.md             # 各专题文档
```

## ❓ 常见问题

**Q: 这个项目适合什么水平的开发者学习？**
A: 适合有一定 Swift 基础，想学习 macOS 应用开发的开发者。

**Q: 需要准备什么开发环境？**
A: Xcode 或 Swift 命令行工具，macOS 13.0+ 系统。详见 [开发指南](10-development-guide.md)。

**Q: 文档中的代码示例可以直接运行吗？**
A: 可以，这些代码片段都来自项目源码，经过测试验证。

**Q: 如果遇到问题怎么办？**
A: 首先查阅各文档中的常见问题部分，然后查看 [开发指南](10-development-guide.md) 的调试部分。

## 🔄 文档维护

本文档会随着项目更新同步维护。如果您发现文档有误或有改进建议，欢迎提出。

---

**开始您的学习之旅吧！建议从 [项目概览](01-overview.md) 开始。** 🚀