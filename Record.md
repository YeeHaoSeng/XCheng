---
date: 2026-07-31
---

# Hugo PaperMod 站点配置记录

## 环境

| 项 | 值 |
|---|---|
| Hugo | v0.164.0 extended (替换 Chocolatey 标准版) |
| 主题 | PaperMod (zip 安装于 `themes/PaperMod/`) |
| 代理 | Clash 7897 端口，Git 不走代理需通过 PowerShell 下载 zip |
| Dev Server | `hugo server --noHTTPCache --disableFastRender` 后台启动 |

---

## 文章《黄氏物语》修正

### frontmatter 修复

```diff
- date: 2022-4-24 20:17:00
+ date: 2022-04-24T20:17:00+08:00
+ lastmod: 2026-07-31T00:00:00+08:00
- categories: 日志
+ draft: false
- cover: /img/Hstory.jpg
+ cover:
+   image: /img/Hstory.jpg
```

### 图片路径修复

```diff
- src="./黄氏物语/1.jpg"
+ src="/img/黄氏物语/1.jpg"
```

图片从 `content/posts/黄氏物语/` 移到 `static/img/黄氏物语/`，修正相对路径 404。

### 内联样式 → CSS class 重构

全文去除固定像素宽度的内联 style，替换为响应式 CSS 类：

| 原写法 | 替换为 |
|---|---|
| `<div style="width:600px;...">` | `<div class="verse-section">` |
| `<p style="..."><font color=#a30000>` | `<p class="quote-red">` |
| `<font color=#FFD700>` | `<div class="gold-section">` |
| `<img width="500" height="400">` | `<img>` (CSS `max-width:100%`) |

CSS 定义于 `assets/css/extended/article-styles.css`。

### 竖排文言标点清理

文言竖排部分，所有标点替换为空格：

```diff
- 时维三月，序属三春。
+ 时维三月 序属三春
```

### 现代诗文横排

"闭上双眼 ~ 继续摇摆" 及 "壬寅·秋" 改为横版，保留标点。

---

## 自定义模板

### `layouts/_partials/extend_footer.html`

底部栏扩展：显示博客运行年份跨度 + 文章总数 + 全站字数。

渲染效果：`2022 - 2026 · 共 4 篇文章 · 总计 XXX 字`

> 注：模板文件中使用 HTML 实体（`&#20849;` 等）替代直接中文，规避 Windows 下 PowerShell 写文件的 UTF-8 编码问题。

### `layouts/_partials/post_meta.html`

覆盖默认元数据：显示 `发布: YYYY-MM-DD · 更新: YYYY-MM-DD · X 分钟 · X 字`。

修改时间仅在不同于发布时间时显示。

### `layouts/_default/term.html`

标签页（点击标签后）使用归档风格紧凑列表替代默认卡片布局。

### `layouts/_default/list.html`

文章列表页元数据改用自定义 post_meta。

---

## 自定义 CSS

### `assets/css/extended/background.css`

- body 伪元素背景图 (`/bg.jpg`)，透明度 0.2
- 内容区域白底卡片（`.post-content`、`.post-entry` 等使用 `var(--theme)`）
- 内容区宽度 900px（手机 `100% - 2rem`）

### `assets/css/extended/article-styles.css`

《黄氏物语》专用响应式样式：
- `.verse-section` / `.verse-text` — 竖排古诗，768px 断点适配
- `.quote-red` / `.quote-darkred` — 红色强调句，字号 `em` 单位
- `.gold-section` — 金色段落
- `.chapter-title` — 续章标题
- `.postscript` — 后记
- `.end-section` — END 标记

### `assets/css/extended/mobile-fix.css`

通用移动端修复：内联样式的 div 和 img 在 ≤768px 时强制 100% 宽。

---

## hugo.yaml 关键配置

```yaml
theme: "PaperMod"
params:
  defaultTheme: auto         # 自动浅色/深色
  ShowReadingTime: true
  ShowWordCount: true
  ShowCodeCopyButtons: true
  ShowToc: true
```

menu 使用英文标识符，避免编码问题。

---

## 追加配置

### emoji 支持

`hugo.yaml` 添加 `enableEmoji: true`，文章中的 `:angry:` `:rofl:` `:sweat_smile:` `:older_man:` 等短码自动转换为 emoji 表情。

### 搜索功能

#### 配置

`hugo.yaml` 添加 JSON 输出格式，生成搜索索引：

```yaml
outputs:
  home:
    - HTML
    - JSON
```

索引文件：`/index.json`（~17KB，含 title、content、summary、permalink）。

#### 实现

主题自带的 `fastsearch.js` 被劫持禁用（`extend_head.html` 拦截 `addEventListener('load')` 调用），替换为自定义搜索逻辑：

- Fuse.js 7.0 CDN（`cdn.jsdelivr.net`）替代内置 `fuse.basic.min.js`
- 搜索词 ≥ 2 字符触发，最多 8 条结果
- 高亮算法：先 `stripHtml` 去除标签 → `indexOf` 在纯文本中定位 → 前后各取 40/60 字符 → `<em>` 标记高亮
- 避开 Fuse 原始索引位置与去 HTML 后文本偏移不同步导致的错位问题

CSS 样式（搜索卡片 + 高亮标记）内联在 `extend_head.html` 中。

### 图片点击放大（Lightbox）

`extend_head.html` 注入 CSS + JS：
- 点击 `.post-content img` → 全屏暗色遮罩 + 放大预览
- 点击遮罩 / Esc → 关闭
- 缩放动画 0.2s

CSS 定义于 `assets/css/extended/lightbox.css`。

### 三篇 Acwing 算法文章

修正（与黄氏物语规则相同）：日期 ISO 8601、cover 对象格式、去 categories、加 lastmod+draft、图片路径修正到 `/img/acwing/chapter{1,2,3}/`。

### 文章密码保护

#### 模板

`layouts/_default/single.html` 覆盖 PaperMod 默认单页模板。当文章 frontmatter 含 `password` 字段时，前端启用密码门：

- 存储 SHA-256 哈希值（非明文），防源码直接暴露
- 浏览器端用 Web Crypto API 对输入做 SHA-256 比对
- 正确则移除 `display:none` 显示内容
- 其他文章无 `password` 字段则正常显示

#### 使用方式

```yaml
password: "sha256-hash-value"
```

生成 hash：

```powershell
$sha = [Security.Cryptography.SHA256]::Create()
[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes("password"))).Replace("-","").ToLower()
```

#### 局限性

静态站点无服务端，内容仍在 HTML 源码中（仅隐藏）。F12 删 `display:none` 即可绕过，属"防君子"级别。