FROM scratch

# 定义构建参数
ARG IMAGE_TITLE="ImmortalWrt OpenClash Docker"
ARG IMAGE_DESC="基于immortalwrt自动构建集成openclash的docker镜像"
ARG EXPOSE_PORTS="80 443 53/udp 53/tcp 7890 7891 7892 7893 7894 7895"

# 使用变量设置 OCI 标签
LABEL org.opencontainers.image.source="https://github.com/vickai/immortalwrt-openclash"
LABEL org.opencontainers.image.description=$IMAGE_DESC
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.title=$IMAGE_TITLE
LABEL org.opencontainers.image.authors="vickai"

# 添加根文件系统
ADD rootfs.tar.gz /

# 设置环境变量
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# 动态暴露端口
EXPOSE $EXPOSE_PORTS

# 启动命令
CMD ["/sbin/init"]