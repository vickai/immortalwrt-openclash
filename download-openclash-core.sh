#!/bin/bash
set -e

CORE_DIR="./files/etc/openclash/core"
mkdir -p $CORE_DIR

VERSION=$1

download_core() {
    NAME=$1
    URL=$2

    echo "下载 $NAME ..."
    TMP="/tmp/clash_meta.tar.gz"

    wget -O "$TMP" "$URL" || {
        echo "❌ 下载 $NAME 失败"
        exit 1
    }

    tar xzf "$TMP" -C "$CORE_DIR" || {
        echo "❌ 解压 $NAME 失败"
        exit 1
    }

    # 如果解压出来的是 clash，则统一命名为 clash_meta
    if [ -f "$CORE_DIR/clash" ]; then
        mv "$CORE_DIR/clash" "$CORE_DIR/clash_meta"
    fi

    chmod +x "$CORE_DIR/clash_meta"

    echo "✔ $NAME 下载完成 → clash_meta"
}

case "$VERSION" in
  v1)        URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64-v1.tar.gz";;
  v2)        URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64-v2.tar.gz";;
  v3)        URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64-v3.tar.gz";;
  v1-smart)  URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/smart/clash-linux-amd64-v1.tar.gz";;
  v2-smart)  URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/smart/clash-linux-amd64-v2.tar.gz";;
  v3-smart)  URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/smart/clash-linux-amd64-v3.tar.gz";;
  ""|*)      URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz";;
esac

download_core "Clash Meta ($VERSION)" "$URL"

echo "OpenClash 内核下载完成。"
