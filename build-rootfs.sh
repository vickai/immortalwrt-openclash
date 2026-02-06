#!/bin/bash
# 启用 -e 遇到错误立即停止，启用 -x 打印执行过程
set -ex

WORKDIR=$(pwd)
SRC_DIR="$WORKDIR/immortalwrt-src"

# 1. 打印环境信息，确认磁盘空间
echo "Checking disk space before build..."
df -h

# 锁定到 v24.10.4 标签
if [ ! -d "$SRC_DIR" ]; then
    echo "Cloning ImmortalWrt v24.10.4..."
    git clone --branch v24.10.4 --depth 1 https://github.com/immortalwrt/immortalwrt.git "$SRC_DIR"
else
    cd "$SRC_DIR"
    echo "Updating existing source..."
    git fetch --all
    git checkout v24.10.4
fi

cd "$SRC_DIR"

# 2. 更新 feeds
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

# --- 关键修复：解决 Rust 编译 404 报错 ---
# 强制禁用 Rust 的 CI LLVM 下载，改用本地源码编译（解决上游 ci-artifacts 404 问题）
find feeds/packages/lang/rust -name Makefile -exec sed -i 's/RUST_USE_CI_LLVM:=true/RUST_USE_CI_LLVM:=false/g' {} +

# 3. 配置文件处理
if [ -f "$WORKDIR/.config" ]; then
    cp "$WORKDIR/.config" .config
else
    # 生成基础架构配置
    make defconfig
fi

# 确保配置格式正确，yes "" 用于自动回答所有新配置选项的提问，防止卡死
yes "" | make oldconfig

# 4. 提前下载所有包的源码，减少编译时的网络波动压力
make download -j8

# 5. 执行编译
# 如果并行编译失败，自动回退到单线程详细模式打印具体错误
echo "Starting compilation..."
make -j$(nproc) || make -j1 V=s || {
    echo "❌ 编译失败，查看下方磁盘空间或代码报错"
    df -h
    exit 2
}

# 6. 查找并导出 rootfs
echo "Searching for rootfs targets..."
# 精准匹配 rootfs 压缩包
ROOTFS=$(find "$SRC_DIR/bin/targets" -name "*rootfs.tar.gz" | head -n 1)
OUTPUT="$WORKDIR/openwrt-rootfs.tar.gz"

if [ -n "$ROOTFS" ] && [ -f "$ROOTFS" ]; then
    cp "$ROOTFS" "$OUTPUT"
    echo "✅ Rootfs 已成功生成: $OUTPUT"
else
    echo "❌ 未找到 rootfs 文件。当前 bin 目录内容如下："
    ls -R "$SRC_DIR/bin/targets" || true
    exit 1
fi