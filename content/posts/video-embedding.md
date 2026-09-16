---
title: "视频嵌入示例"
date: 2026-09-13T22:00:00+08:00
draft: false
tags: ["示例"]
---

这是一篇演示文章：同一段视频，几种不同的部署/嵌入方式该怎么写。

## 方式一：文件放本站仓库（托管在 GitHub Pages）

把 mp4 放到 `static/video/`，然后：

```markdown
<video controls preload="metadata" poster="/video/cover.jpg" src="/video/demo.mp4"></video>
```

<video controls preload="metadata" src="https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4"></video>

（上例为了演示用的是公共测试视频外链；本地仓库版把 `src` 换成 `/video/你文件.mp4` 即可，封面用 `poster` 属性。）

> 建议：mp4 用 H.264+AAC，压缩到 20MB 以内；GitHub 单文件上限 100MB。

## 方式二：外网直链（OSS / OneDrive / 任意支持 Range 的视频地址）

只要有能直接播放的直链，原样放进 `src` 就行：

```markdown
<video controls src="https://你的桶.oss-cn-shanghai.aliyuncs.com/视频.mp4"></video>
```

OSS 需要在控制台开"公开读"（或生成带签名的临时 URL）；OneDrive 用"共享 → 获取链接 → **直达链接**"后把 `redir` 换成 `download` 参数的形式。

## 方式三：网盘（百度 / 阿里 / 夸克）

网盘分享页**不能**当作 `<video src>` 内嵌播放（要登录 + 防盗链）。正确定位是"下载/查看入口"，直接放链接，点开在网盘里看：

[📦 百度网盘查看/下载示例](https://pan.baidu.com/s/示例链接)

```markdown
[📦 百度网盘查看/下载示例](https://pan.baidu.com/s/示例链接)
```

## 方式四：自建视频服务器（家里的板子 + Tailscale Funnel）

大视频塞 GitHub 会撞 100MB 单文件上限、仓库也会膨胀。更合适的做法：把视频放在家里的板子（1T NVMe）上，用 Tailscale Funnel 暴露成 HTTPS 直链，网页直接播：

> ⚠️ **注意**：Tailscale 的 `*.ts.net` 域名解析到境外入口，**国内直连不通、需要代理才能访问**。所以下面这个示例适合自己看或挂代理的访客；要让普通读者直接播放，需换成 Cloudflare 隧道 + 自有域名（思路相同，只换一层入口）。

<video controls preload="metadata" src="https://lubanmao-video.tailb1cb86.ts.net/test.mp4"></video>

```markdown
{{</* video src="https://lubanmao-video.tailb1cb86.ts.net/你的视频.mp4" */>}}
```

- 视频文件放到板子 `/srv/video/` 即可（支持拖动进度、跨域播放）；
- 域名固定、重启不变，也不用买域名/备案；板子需保持在线；
- 带宽不保证（Tailscale 免费档属于公平使用），适合个人规模、不追求速度的场景；
- 文件名建议用英文/数字，中文名虽然能播但链接会被百分号编码得很难看。

## 速查表

| 方式 | 页面内直接播放 | 需要什么 | 适合 |
|---|---|---|---|
| 本站仓库 mp4 | ✅ | 压到 ≤20MB | 短片、封面演示 |
| 自建板子（Tailscale Funnel） | ✅（国内需代理） | 板子在线 | 私人/自用大文件 |
| OSS / OneDrive 直链 | ✅ | 公开读或签名 URL | 中长片、追求速度 |
| 网盘分享 | ❌ 只能点链接 | 登录账号 | 大文件下载 |
| B 站 | iframe 可嵌 | 视频页嵌入代码 | 长视频、带弹幕 |

> 提示：本仓库已开启 `markup.goldmark.renderer.unsafe: true`，所以 `video` 标签可以直接写在 markdown 里；不想写原生标签也可以用 `{{</* video src="..." */>}}` 短代码（见下方示例）。