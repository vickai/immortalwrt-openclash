#!/bin/sh

echo "[ENTRYPOINT] ImmortalWrt Docker (OpenClash) starting..."

# 1. 配置自动防火墙 (Bypass)
if [ -x /etc/init.d/bypass-autogen ]; then
    echo "[ENTRYPOINT] Running bypass-autogen..."
    /etc/init.d/bypass-autogen start || echo "[ENTRYPOINT] bypass-autogen failed (ignored)"
fi

# 2. 运行 OpenClash 预处理 (如日志补丁)
if [ -x /etc/init.d/openclash-start ]; then
    echo "[ENTRYPOINT] Running openclash-start (pre-flight checks)..."
    /etc/init.d/openclash-start start || true
fi

# 3. 启动 OpenClash 主服务
if [ -x /etc/init.d/openclash ]; then
    echo "[ENTRYPOINT] Starting OpenClash Service..."
    /etc/init.d/openclash start || echo "[ENTRYPOINT] OpenClash start failed!"
else
    echo "[ENTRYPOINT] ❌ Error: OpenClash init script not found!"
fi

# 4. 启动健康检查
if [ -x /usr/bin/openclash-healthcheck ]; then
    /usr/bin/openclash-healthcheck &
fi

# 5. 交给 init 进程
echo "[ENTRYPOINT] Initialization complete. Executing init..."
exec /sbin/init