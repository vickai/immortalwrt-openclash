FROM scratch

# 添加 OCI 标准标签，用于关联 GitHub 仓库和描述
LABEL org.opencontainers.image.source="https://github.com/vickai/AutoBuildImmortalWrtDocker"
LABEL org.opencontainers.image.description="基于immortalwrt自动构建集成openclash的docker镜像"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.title="ImmortalWrt OpenClash Docker"
LABEL org.opencontainers.image.authors="vickai"

# 添加构建好的 rootfs
ADD rootfs.tar.gz /

# 设置环境变量
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# 暴露 OpenClash 相关端口
# 80/443: 面板
# 7890: HTTP
# 7891: Socks5
# 7892-7895: 其他常用代理端口
# 53: DNS
EXPOSE 80 443 53/udp 53/tcp 7890 7891 7892 7893 7894 7895

# 启动命令
CMD ["/sbin/init"]