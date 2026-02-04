FROM scratch

# 导入构建好的 rootfs
ADD openwrt-rootfs.tar.gz /

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8

# 复制内置配置和脚本
COPY files/ /

# 修正脚本权限
RUN chmod +x /usr/bin/download-fonts.sh \
    /usr/bin/openclash-entrypoint.sh \
    /usr/bin/openclash-healthcheck \
    /etc/init.d/bypass-autogen \
    /etc/init.d/openclash-start \
    /openclash/custom/openclash-log-patch.sh 2>/dev/null || true

# 下载中文字体
RUN /usr/bin/download-fonts.sh

# 设置入口点
ENTRYPOINT ["/usr/bin/openclash-entrypoint.sh"]

# 镜像元数据
ARG VERSION
LABEL org.opencontainers.image.title="ImmortalWrt OpenClash Docker"
LABEL org.opencontainers.image.description="ImmortalWrt 集成 OpenClash，自动旁路由。"
LABEL org.opencontainers.image.source="https://github.com/vickai/immortalwrt-openclash"
LABEL org.opencontainers.image.authors="VICKAI"
LABEL org.opencontainers.image.version=$VERSION