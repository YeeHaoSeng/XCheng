#!/usr/bin/env bash
# ============ 压缩视频 → 仓库版（画质让路、音频零损耗） ============
# 用法:  ./scripts/compress-video.sh 输入.mp4 [输出.mp4]
# 依赖:  ffmpeg / ffprobe（Windows: choco install ffmpeg；或直接放板子上跑）
# 行为:
#   - 视频: 缩到 720p、CRF28、限码率 —— 画面够看、体积小
#   - 音频: AAC 原轨直接 copy（一个比特不动）；非 AAC 自动转 AAC 320k（听感近无损）
#   - 无音轨: 输出静音流
set -euo pipefail

IN="${1:?用法: $0 输入.mp4 [输出.mp4]}"
OUT="${2:-${IN%.*}-web.mp4}"
[ -f "$IN" ] || { echo "找不到输入文件: $IN"; exit 1; }

echo "[1/2] 检查音频编码…"
ACODEC="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$IN" || true)"
if [ -z "$ACODEC" ]; then
    echo "  无音轨 → 输出静音"
    AOPTS="-an"
elif [ "$ACODEC" = "aac" ]; then
    echo "  音频是 AAC → 原轨照抄（无损）"
    AOPTS="-c:a copy"
else
    echo "  音频是 ${ACODEC} → 转 AAC 320k（浏览器兼容 + 听感近无损）"
    AOPTS="-c:a aac -b:a 320k"
fi

echo "[2/2] 压缩视频（720p / CRF28 / 码率上限 1.2M）…"
ffmpeg -y -hide_banner -i "$IN" -vf scale=-2:720 \
    -c:v libx264 -crf 28 -maxrate 1.2M -bufsize 2.4M -preset veryfast \
    $AOPTS -movflags +faststart "$OUT"

SIZE="$(du -h "$OUT" | cut -f1)"
echo "完成: $OUT（$SIZE）"
echo "  视频: 720p H.264 | 音频: ${ACODEC:-无音轨} → $([ "$ACODEC" = aac ] && echo '原样保留' || echo 'AAC 320k')"