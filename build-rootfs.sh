#!/bin/bash
set -e

WORKDIR=$(pwd)
SRC_DIR="$WORKDIR/immortalwrt-src"

# 锁定到 v24.10.4 标签
if [ ! -d "$SRC_DIR" ]; then
    echo "Cloning ImmortalWrt v24.10.4..."
    git clone --branch v24.10.4 --depth 1 https://github.com/immortalwrt/immortalwrt.git "$SRC_DIR"
else
    cd "$SRC_DIR"
    echo "Updating existing source..."
    git fetch --all
    # 强制切换到 v24.10.4
    git checkout v24.10.4
fi

cd "$SRC_DIR"

# 更新 feeds
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages

# 先生成默认配置
make defconfig

# 覆盖外部传入的 .config
if [ -f "$WORKDIR/.config" ]; then
    cp "$WORKDIR/.config" .config
fi

# 重新整理配置
make oldconfig

# 编译 rootfs
make -j$(nproc) V=s

# 查找 rootfs
ROOTFS=$(find "$SRC_DIR/bin/targets" -name "*rootfs.tar.gz" | head -n 1)
OUTPUT="$WORKDIR/openwrt-rootfs.tar.gz"

if [ -f "$ROOTFS" ]; then
    cp "$ROOTFS" "$OUTPUT"
    echo "Rootfs 已生成: $OUTPUT"
else
    echo "❌ 未找到 rootfs 文件，请检查编译日志"
    exit 1
fi
