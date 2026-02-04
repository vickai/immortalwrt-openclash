#!/bin/sh
# ============================
#   OpenClash 中文日志补丁（修复版）
# ============================

fix_log() {
    LOG_FILE="$1"

    [ ! -f "$LOG_FILE" ] && return

    tmp=$(mktemp)

    # 去除 UTF-8 BOM
    sed '1s/^\xEF\xBB\xBF//' "$LOG_FILE" > "$tmp"

    # 删除真正的不可见字符（保留 ANSI 控制序列）
    sed -i 's/[\x00-\x08\x0B\x0C\x0E-\x1F]//g' "$tmp"

    mv "$tmp" "$LOG_FILE"
}

# 修复两个日志文件
fix_log "/etc/openclash/clash.log"
fix_log "/etc/openclash/clash_last.log"

echo "[OpenClash] 中文日志补丁已应用。"
