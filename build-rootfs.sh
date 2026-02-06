#!/bin/bash
set -ex

WORKDIR=$(pwd)
SRC_DIR="$WORKDIR/immortalwrt-src"

# 1. 环境检查
echo "Checking disk space before build..."
df -h

# 2. 克隆源码
if [ ! -d "$SRC_DIR" ]; then
    echo "Cloning ImmortalWrt v24.10.4..."
    git clone --branch v24.10.4 --depth 1 https://github.com/immortalwrt/immortalwrt.git "$SRC_DIR"
else
    cd "$SRC_DIR"
    git fetch --all
    git checkout v24.10.4
fi

cd "$SRC_DIR"

# 3. 更新 Feeds
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

# --- 关键修复：解决 Rust CI 下载 404 错误 ---
find feeds/packages/lang/rust -name Makefile -exec sed -i 's/RUST_USE_CI_LLVM:=true/RUST_USE_CI_LLVM:=false/g' {} +

# 4. 配置处理
if [ -f "$WORKDIR/.config" ]; then
    cp "$WORKDIR/.config" .config
else
    make defconfig
fi

# 自动回答新配置问题，防止卡死
yes "" | make oldconfig

# 5. 执行编译
make download -j8
echo "Starting compilation..."
make -j$(nproc) || make -j1 V=s || {
    echo "❌ 编译失败，查看下方报错"
    df -h
    exit 2
}

# 6. 导出产物
ROOTFS=$(find "$SRC_DIR/bin/targets" -name "*rootfs.tar.gz" | head -n 1)
OUTPUT="$WORKDIR/openwrt-rootfs.tar.gz"

if [ -n "$ROOTFS" ] && [ -f "$ROOTFS" ]; then
    cp "$ROOTFS" "$OUTPUT"
    echo "✅ Rootfs 已成功生成: $OUTPUT"
else
    echo "❌ 未找到 rootfs 文件。"
    ls -R "$SRC_DIR/bin/targets" || true
    exit 1
fi