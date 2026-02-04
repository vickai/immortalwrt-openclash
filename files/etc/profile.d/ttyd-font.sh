#!/bin/sh
# ============================
#   ttyd 中文字体补丁（修复版）
# ============================

# 推荐字体顺序：中文优先
TTYD_FONT="Noto Sans Mono CJK SC, WenQuanYi Micro Hei Mono, DejaVu Sans Mono, monospace"

# 写入 /etc/profile（避免重复）
grep -q "TTYD_FONT" /etc/profile || echo "export TTYD_FONT=\"$TTYD_FONT\"" >> /etc/profile

echo "[ttyd-font] 中文字体补丁已应用：$TTYD_FONT"
