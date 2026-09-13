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

- 背景照片（`/bg.jpg` 或 `/img/cs.jpg`）**只渲染在首页 hero**（全透明容器 + 白色粗体字 + 柔和暗角），正文页不再注入/加载背景图，回归纯净主题色背景，保证阅读零干扰（参考 hugo-paper / bearblog 的阅读优先做法）
- 背景层由 `extend_head.html` 脚本在检测到 `.profile`（首页）时才创建
- 内容区域白底卡片（`.post-content`、`.post-entry` 等使用 `var(--theme)`）
- 内容区域卡片底/白卡片样式不变；内容区宽度 980px（手机 `100% - 2rem`）

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

---

## 阅读体验优化（电子书风格）

参考优秀项目设计：Bear Blog / hugo-bearblog（极简+排版优先）、hugo-book（章节侧边栏）、Medium 与 Kindle（阅读进度、字号/行距/主题调节），在 PaperMod 上叠加"阅读器"层，全部原生 CSS + JS，无新依赖。

### 新增/修改文件

| 文件 | 作用 |
|---|---|
| `assets/css/extended/reader.css` | 阅读器样式：字号/行距/栏宽/字体变量、衬线字栈、章节侧栏、进度条、设置面板、护眼色板 |
| `layouts/_partials/reader_toc.html` | 文章右侧固定章节目录（≥1440px 显示） |
| `layouts/_partials/reader_tools.html` | 进度条 + 设置面板 + 滚动高亮（scroll 事件 + rAF 兜底） |
| `layouts/_partials/extend_head.html` | 末尾追加 reader_tools 引入（仅普通文章页，跳过密码页） |
| `layouts/_default/single.html` | ShowToc 分支：渲染侧栏目录 + 内联目录容器；密码文章不渲染目录（防章节标题泄露） |

### 阅读排版（作用于 `.post-single .post-content`）

- 默认正文：宋体系衬线字栈、18px、行距 1.9、860px 栏宽（卡片共 924px，对齐参考博客正文 ~900px 量级），中文两端对齐
- 标题改为 em 相对字号，h2 加细分隔线；代码/表格/引用/分割线（居中短横线）细节美化
- 设置项：字号 15–24px、行距 1.5–2.4、宋体/黑体、栏宽 720/860/980、首行缩进 2em、主题（日间/护眼/夜间）
- 设置存 localStorage（reader_fs / reader_lh / reader_font / reader_w / reader_indent / reader_theme），head 内联脚本在首帧渲染前恢复，避免闪跳
- 护眼为 Kindle 式**暗绿墨绿**色板（`--theme #1e2a22`、正文 `#b8ccb4`、代码块 `#141c16`），属深色调、切换时同时置 `data-theme=dark`（与「夜间」档合并）；顶栏日/夜按钮一键退出护眼

### 交互

- 顶部 3px 阅读进度条（仅文章页）
- 右侧固定目录（≥1440px）：Hugo 原生 `.TableOfContents` 渲染，随滚动高亮当前章节
- <1440px 自动回退 PaperMod 原有可折叠目录
- 右下 `Aa` 悬浮按钮打开设置面板，Esc / 点击外部关闭
- 面板打开期间自动隐藏 `Aa` 与「返回顶部」按钮避免重叠，关闭后按滚动位置恢复（移动端断点下按钮间距已拉开）

### 首页改版

- `layouts/index.html` 新增：居中衬线大标题 + 毛玻璃「最近文章」面板（最新 10 篇、列表区固定 210px 高、内部纵向细白滚动条，标题与「全部文章」入口固定不动）+ 右下角社交图标（保留原位）+ 鼠标视差（照片反向位移 ≤24px，触摸屏 / prefers-reduced-motion 自动关闭）
- 标题字体：仿参考页 banner 的「YeeHaoSeng」品牌大字（实测为 **Playball** 手写草书、白色、700、`0 3px 6px rgba(0,0,0,.3)` 深影），据此应用到首页 `XCheng`（Playball 为主、Merriweather/宋体兜底；jsDelivr @fontsource 字源，CN 可达）——注：参考页代码里 "YeeHaoSeng" 注释为「用户名」，它是 banner 上显示的品牌字；Merriweather 是参考页正文标题「箫骋」用的衬线。副标题参数 `homeSubtitle` 已从 hugo.yaml 删除，如需副标题重新添加即可
- `assets/css/extended/home.css`：hero / 毛玻璃面板（`backdrop-filter: blur(12px)`）/ 入场动画（home-rise，reduced-motion 时禁用）
- `layouts/_partials/home_tools.html` 新增：首页设置面板（右下角 `Aa`，与文章页阅读设置同款视觉，位于 GitHub 图标上方）：**气泡**（精致/原味切换，脚本经 `window.__bubbleSetMode` 重建粒子场）+ **主题**（日间/护眼/夜间，与文章页共用 `pref-theme`/`reader_theme` 存储，全站生效、跨页一致），Esc/点外部关闭
  - 注意：**护眼只作用于阅读页**——首页是照片 hero 设计，切护眼仅在首页存档（不设 `data-reader-theme`、照片与颜色完全不动），进入文章页后自动以护眼渲染；顶栏日/夜按钮会同步并清除护眼态
- 气泡上升粒子（参考 cnblogs yxc1203 首页 banner 画布实测参数：光点集中底部 40% 高度、近圆形、亮度峰值约 0.49）：**双模式**（默认精致，选择存 `localStorage.bubble_mode`，经首页设置面板切换）
  - **精致模式**（默认）：CSS 大圆泡层 + canvas 细泡层。CSS 层（`.home-circles`）12 个（触摸屏 7 个）40–140px 半透明白色描边圆，16–32s 缓慢上升、负 delay 错位满场；canvas 层「肥皂泡」精灵（渐变亮核 + 高光、近圆形 1:2.4），透明度 0.32–0.60、半径 6–30px、上升 16–42px/s、数量 ≤150（触摸屏 60%）
  - **原味模式**（参考页同款）：关闭大圆泡层；canvas 画**绵密中亮度微尘云**（1400 个/触摸屏 750）：6% 亮核点（2–5px、α 0.24–0.36）+ 94% 微尘（1.2–2.6px、α 0.08–0.22，体积主要集中在 α16–60 中亮度层，对齐参考实测），底部 60%–98% 高度预分布、y<0.55H 淡出后**回收直返底部（源源不断）**、0.72H 起变淡、顶部留空——实测同口径分层：总量 14514（参考 6638）、中亮度 7990（参考 5686）、亮星 842（参考 137）
  - 两模式共用：底部 6–12% 淡入、`prefers-reduced-motion` 与标签页隐藏时停绘、画布 `z-index:-1`
- 首页背景照片流程不变（`extend_head` 检测 `.profile` 后注入）
- 参考：Bear Blog（居中标题）、Hugo Vela（毛玻璃）、摄影类 minimal 首页（整屏 hero）

### 归档页左侧树视图

- `layouts/_partials/archive_tree.html` 新增：年份 → 文章标题 两级简树（省去月份层），服务端渲染，与文章侧栏目录共用视觉语言（镜像到左侧）；已参数化（`(dict "pages ...)`），归档页与标签页共用，仅显示各自页面的文章
- `assets/css/extended/archive-tree.css`：固定左侧（≥1440px 显示），点击年份滚动到对应分组（`#2026` 锚点），随滚动高亮当前年份；<1440px 隐藏，页面保持原布局
- 引用处：`layouts/archives.html`（全站文章）、`layouts/_default/term.html`（当前标签文章）
- 参考：hugo-book 侧栏树 / Obsidian 树状归档 / Hexo NexT 侧栏分类
- 非文章页（首页/列表/归档/搜索/标签）不加载任何阅读器组件

---

## 新建文章流程（本地写，推荐）

### 1. 新建

```bash
hugo new posts/我的文章.md        # 文件名会成为文章路径，可中文
```

模板 `archetypes/default.md` 已默认：日期 ISO8601、`draft: false`（新建即发布）、`tags: []`。

### 2. 写正文

frontmatter 示例：

```yaml
---
title: "我的文章"
date: 2026-09-13T21:00:00+08:00
cover:
  image: /img/xxx.jpg          # 可选封面
tags: []                        # 想加密改为 ["private"]
---
正文 markdown
```

- 图片：文件放 `static/img/...`，正文用 `/img/...` 引用；**静态文件不自动入库**，`git add -A` 会一并带上
- 加密：tags 加 `private` 即可，密码统一在 `hugo.yaml` 的 `params.privateTags` 中管理（不要用旧 frontmatter `password` 字段）

### 3. 本地预览

```bash
hugo server --baseURL http://localhost:1313/   # 1313 常驻进程；直接开 http://localhost:1313/
```

加密文章预览：打开文章页输入密码 `hugoxc`。

### 4. 一键上传（发布）

两种方式任选：

```bash
git ship "add post xxx"     # 方案 A：git 全局别名（已装）；不带消息自动用 "update: 日期"
```

双击 `push.cmd`（方案 B，Windows，支持参数：`push.cmd "add post xxx"`）。

两者内部都是 `add -A + commit + pull --rebase + push`，随后 GitHub Actions 自动重部署，约 1 分钟上线。

### 5. 要点

- 每次 push 后远端可能有网页端提交（如「编辑本文」），`ship`/`push.cmd` 已内置 `pull --rebase`，无需手动拉取
- 纯网页端新建：仓库 `content/posts` → Add file；或按 `.` 进 github.dev
