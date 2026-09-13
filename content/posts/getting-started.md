---
title: "Hugo 快速入门"
date: 2026-07-25T10:00:00+08:00
draft: false
tags: ["Hugo", "教程", "private"]
---

## 什么是 Hugo？

Hugo 是一个用 Go 语言编写的快速、现代的静态站点生成器。它接收你的内容，应用主题，然后生成完整的网站。

## 安装

```bash
# Windows (Chocolatey)
choco install hugo-extended

# macOS (Homebrew)
brew install hugo
```

## 创建你的第一个站点

```bash
hugo new site my-site
cd my-site
hugo server
```

然后访问 `http://localhost:1313/` 就能看到你的网站了！
