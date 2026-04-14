# codepad_editor

A new Flutter project.


# ✏️ CodePad Editor

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>


**CodePad Editor** is a lightweight code and text editor for Android, built with Flutter. Featuring a VS Code Dark-inspired theme, built-in multi-language syntax highlighting, real-time Markdown preview, line numbers, pinch-to-zoom font scaling, and more — it delivers a smooth, professional editing experience on mobile.

---

## 📸 Screenshots

| Code Editing | Syntax Highlighting (Read-only) | Markdown Preview |
|:---:|:---:|:---:|
| Line numbers + monospace editing | Multi-language keyword coloring | Live-rendered MD documents |

---

## ✨ Features

### 🎨 Multi-Language Syntax Highlighting

Supports syntax highlighting for **15+ programming languages**, styled after the classic VS Code Dark theme:

| Language | Extensions |
|----------|-----------|
| HTML | `.html`, `.htm` |
| CSS | `.css` |
| JavaScript | `.js`, `.mjs`, `.cjs`, `.jsx` |
| TypeScript | `.ts`, `.tsx` |
| Python | `.py`, `.pyw` |
| Java | `.java` |
| Dart | `.dart` |
| Kotlin | `.kt`, `.kts` |
| C | `.c`, `.h` |
| C++ | `.cpp`, `.cc`, `.cxx`, `.hpp` |
| XML / SVG | `.xml`, `.svg` |
| JSON | `.json`, `.jsonc` |
| Shell / Bash | `.sh`, `.bash`, `.zsh` |
| Markdown | `.md`, `.markdown` |
| YAML | `.yaml`, `.yml` |

Highlighted elements include: keywords, strings, comments, numbers, function names, types, decorators, preprocessor directives, HTML tags/attributes, and more.

### 📝 Professional Code Editing

- **Line Numbers** — Real-time line numbers displayed on the left side, synchronized scrolling with the editor
- **Monospace Font** — Uses `monospace` font family for proper code alignment
- **Word Wrap Toggle** — One-tap toggle to enable/disable word wrapping
- **Line & Character Count** — Status bar displays real-time line count and character count
- **Language Badge** — Auto-detects language by file extension and displays a color-coded badge in the title bar
- **Modification Indicator** — An orange dot `●` appears next to the filename when there are unsaved changes

### 📂 Full File Operations

- **New File** — Creates a blank document, defaults to `untitled.txt`
- **Open File** — Opens local text files via the system file picker (SAF), supporting 40+ file extensions
- **Save** — Saves the current content to the original file path
- **Save As** — Saves with a custom filename to the device's Documents directory
- **Unsaved Changes Alert** — Before creating or opening a new file, a dialog prompts the user to Save / Discard / Cancel if there are unsaved modifications

### 📖 Real-Time Markdown Preview

When a `.md` / `.markdown` file is opened, a "MD Preview" button automatically appears in the floating menu. Supported Markdown elements include:

Headings (h1–h6), paragraphs, bold/italic, inline code, code blocks, blockquotes, lists, tables, horizontal rules — all rendered with a dark theme stylesheet.

### 🔍 Read-Only Mode

Switching to read-only mode disables text input and enables **syntax-highlighted rendering** for code files (via `SelectableText.rich`), allowing users to select and copy text. A lock icon appears in the title bar as a visual indicator.

### 🔎 Font Size Adjustment

- **Pinch-to-Zoom** — Use a two-finger pinch gesture in the editor area to adjust font size in real time (8px – 48px)
- **Menu Buttons** — The floating menu provides dedicated "Increase Font" / "Decrease Font" buttons
- **Preference Persistence** — Font size and word wrap settings are automatically saved to `SharedPreferences` and restored on next launch

### 🎯 Floating Action Menu

A expandable/collapsible floating action button (FAB-style) is positioned at the bottom-right corner. When expanded, it reveals all available actions: New, Open, Save, Save As, Read-Only/Edit mode toggle, Markdown preview toggle, and font size controls. The menu button features a smooth rotation animation.


## 🏗️ Project Structure

```text
lib/
├── main.dart                       # App entry point, Provider setup, theme config
├── models/
│   └── editor_state.dart           # Global editor state (ChangeNotifier)
├── screens/
│   └── editor_screen.dart          # Main editor screen UI & interaction logic
├── services/
│   └── file_service.dart           # File operations service (open/save/permissions)
├── utils/
│   └── syntax_highlighter.dart     # Multi-language syntax highlighting engine
└── widgets/
    └── code_editor.dart            # Line-numbered editor & highlighted read-only view
```



--

**CodePad Editor** 是一款基于 Flutter 开发的 Android 端轻量级代码与文本编辑器。它拥有 VS Code Dark 风格的深色主题界面，内置多语言语法高亮、Markdown 实时预览、行号显示、双指缩放字体等实用功能，为移动端编程和文本编辑提供流畅、专业的体验。

---

## 📸 功能预览

| 代码编辑 | 语法高亮（只读） | Markdown 预览 |
|:---:|:---:|:---:|
| 行号 + 等宽字体编辑 | 多语言关键字着色 | 实时渲染 MD 文档 |

---

## ✨ 功能特性

### 🎨 多语言语法高亮

支持 **15+ 种编程语言**的语法高亮渲染，配色方案采用经典 VS Code Dark 主题风格：

| 语言 | 扩展名 |
|------|--------|
| HTML | `.html`, `.htm` |
| CSS | `.css` |
| JavaScript | `.js`, `.mjs`, `.cjs`, `.jsx` |
| TypeScript | `.ts`, `.tsx` |
| Python | `.py`, `.pyw` |
| Java | `.java` |
| Dart | `.dart` |
| Kotlin | `.kt`, `.kts` |
| C | `.c`, `.h` |
| C++ | `.cpp`, `.cc`, `.cxx`, `.hpp` |
| XML / SVG | `.xml`, `.svg` |
| JSON | `.json`, `.jsonc` |
| Shell / Bash | `.sh`, `.bash`, `.zsh` |
| Markdown | `.md`, `.markdown` |
| YAML | `.yaml`, `.yml` |

高亮元素包括：关键字、字符串、注释、数字、函数名、类型、装饰器、预处理指令、HTML 标签/属性等。

### 📝 专业代码编辑体验

- **行号显示** — 编辑区左侧实时显示行号，行号栏与编辑区同步滚动
- **等宽字体** — 使用 `monospace` 字体，确保代码对齐
- **自动换行切换** — 一键开启/关闭自动换行（Word Wrap）
- **字符与行数统计** — 顶部状态栏实时显示当前文件的行数和字符数
- **语言标签** — 根据文件扩展名自动识别语言，并在标题栏以彩色标签显示
- **修改标记** — 文件有未保存的修改时，文件名旁显示橙色圆点 `●` 提示

### 📂 完整的文件操作

- **新建文件** — 创建空白文档，默认为 `untitled.txt`
- **打开文件** — 通过系统文件选择器（SAF）打开本地文本文件，支持 40+ 种文件扩展名
- **保存文件** — 将编辑内容保存到原始路径
- **另存为** — 自定义文件名，保存到设备 Documents 目录
- **未保存提醒** — 在新建或打开文件前，若当前文件有未保存的修改，弹窗提示用户选择「保存 / 不保存 / 取消」

### 📖 Markdown 实时预览

当打开 `.md` / `.markdown` 文件时，悬浮菜单自动出现「MD预览」按钮。支持渲染以下 Markdown 元素：

标题（h1–h6）、段落、粗体/斜体、行内代码、代码块、引用块、列表、表格、水平线等，均使用深色主题样式渲染。

### 🔍 只读模式

切换为只读模式后，编辑器禁止输入，同时对代码文件启用**语法高亮渲染**展示（基于 `SelectableText.rich`），用户仍可选择和复制文本。标题栏出现锁定图标提示。

### 🔎 字体大小调节

- **双指缩放** — 在编辑区域使用双指捏合手势即可实时调节字体大小（8px ~ 48px）
- **菜单按钮** — 悬浮菜单提供「放大字体 / 缩小字体」按钮
- **偏好持久化** — 字体大小和换行设置自动保存到本地 `SharedPreferences`，下次启动自动恢复

### 🎯 悬浮操作菜单

屏幕右下角提供一个可展开/收起的悬浮菜单按钮（FAB 风格），展开后呈现所有操作选项：新建、打开、保存、另存为、只读/编辑模式切换、Markdown 预览切换、字体大小调节。菜单按钮带有旋转动画效果。

---

## 🏗️ 项目结构
```text
lib/
├── main.dart                       # 应用入口，Provider 初始化，主题配置
├── models/
│   └── editor_state.dart           # 全局编辑器状态（ChangeNotifier）
├── screens/
│   └── editor_screen.dart          # 主编辑器页面 UI 与交互逻辑
├── services/
│   └── file_service.dart           # 文件操作服务（打开/保存/权限管理）
├── utils/
│   └── syntax_highlighter.dart     # 多语言语法高亮引擎
└── widgets/
    └── code_editor.dart            # 行号编辑器组件 & 高亮只读视图组件
```

### 架构说明

本项目采用 **Provider** 进行状态管理。`EditorState` 作为全局状态中心，管理文件内容、文件路径、修改状态、字体大小、换行模式、只读模式、Markdown 预览模式等所有编辑器状态。UI 层通过 `Consumer<EditorState>` 响应式重建，实现数据与视图的解耦。

语法高亮引擎采用**基于正则表达式的分段着色**方案：针对每种语言定义一组有序的正则模式与对应颜色，通过通用的 `_applyPatterns()` 方法按优先级顺序匹配并切割文本为带颜色的 `TextSpan` 片段，最终组合为富文本渲染。

---

## 🚀 快速开始

### 环境要求

- **Flutter SDK** ≥ 3.0.0（< 4.0.0）
- **Dart SDK** ≥ 3.0.0
- **Android SDK** — 支持 Android 5.0+（API 21+）
- 开发工具：Android Studio / VS Code（推荐安装 Flutter 插件）

