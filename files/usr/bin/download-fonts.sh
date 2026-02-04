#!/bin/sh
# ============================
#   自动下载中文字体脚本
# ============================
set -e

FONT_DIR="/usr/share/fonts"
mkdir -p "$FONT_DIR"

echo "[字体] 开始下载中文字体..."

# ----------------------------
# 下载 Noto Sans CJK SC（官方 CDN）
# ----------------------------
if [ ! -f "$FONT_DIR/NotoSansCJKSC-Regular.otf" ]; then
    echo "[字体] 下载 Noto Sans CJK SC..."
    wget --no-check-certificate -O "$FONT_DIR/NotoSansCJKSC-Regular.otf" \
      https://fonts.gstatic.com/ea/notosanssc/v1/NotoSansSC-Regular.otf
fi

# ----------------------------
# 下载 WenQuanYi Micro Hei（官方仓库）
# ----------------------------
if [ ! -f "$FONT_DIR/wqy-microhei.ttc" ]; then
    echo "[字体] 下载 WenQuanYi Micro Hei..."
    wget --no-check-certificate -O "$FONT_DIR/wqy-microhei.ttc" \
      https://github.com/googlefonts/noto-cjk/raw/main/ThirdParty/WenQuanYi/wqy-microhei.ttc
fi

# ----------------------------
# 设置权限
# ----------------------------
chmod 644 "$FONT_DIR"/*.otf 2>/dev/null
chmod 644 "$FONT_DIR"/*.ttc 2>/dev/null

# ----------------------------
# 刷新字体缓存
# ----------------------------
if command -v fc-cache >/dev/null 2>&1; then
    echo "[字体] 刷新字体缓存..."
    fc-cache -f /usr/share/fonts
fi

echo "[字体] 中文字体安装完成。"
