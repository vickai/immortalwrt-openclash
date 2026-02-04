# ImmortalWrt Docker (OpenClash Edition)

这是一个专为 Docker 环境定制的 **ImmortalWrt** 镜像，核心集成了 **OpenClash**，并内置了自动旁路由（Gateway/Bypass）配置脚本。

旨在提供一个**开箱即用、零配置防火墙**的透明代理网关解决方案，特别适合家庭服务器（NAS）或 All-in-One 主机使用。

## ✨ 主要特性

* **轻量精简**：基于 ImmortalWrt v24.10 源码构建，仅包含核心系统和 OpenClash，无冗余插件。
* **自动旁路由**：内置 `bypass-autogen` 脚本，容器启动时自动检测网段、网关，并设置 iptables/nftables 透明代理规则（无需手动折腾防火墙）。
* **OpenClash 专用**：预装 OpenClash 及所有依赖（内核、TUN、Meta、NFTables 支持），解决 Docker 内运行 Clash 的各种痛点。
* **Macvlan 优化**：专为 Docker Macvlan 网络设计，拥有独立 IP，像物理旁路由一样工作。
* **多架构支持**：默认构建 x86_64 架构。

## 🚀 如何构建 (GitHub Actions)

本项目支持直接在 GitHub 上构建 Docker 镜像，无需本地环境。

1.  **Fork** 本仓库到你的 GitHub 账号。
2.  进入 **Actions** 页面。
3.  选择左侧的 **"Build OpenClash Docker"** 工作流。
4.  点击 **Run workflow** 按钮。
    * `Clash Core Version`: 选择你要预装的 Clash 内核版本（推荐 `v1-smart` 或 `v3-smart`）。
5.  等待构建完成，镜像将自动推送到你的 GitHub Packages (GHCR)。

镜像地址格式：`ghcr.io/你的用户名/immortalwrt-openclash:latest`

## 🐳 部署指南 (Docker Compose)

推荐使用 Macvlan 模式，让容器在局域网中拥有独立 IP。

### 1. 创建 Macvlan 网络 (如果尚未创建)

假设你的主路由网关是 `192.168.1.1`，所在的物理网卡是 `eth0`：

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan
```

### 2. 启动容器 (docker-compose.yml)

```yaml
# ------------------------------------------------------------------------------
# openwrt-openclash
# ------------------------------------------------------------------------------
#
# /data/docker/openwrt-openclash
#  ├── docker-compose.yml         # 本配置文件
#  └── ./config.yaml
# 必须开启特权模式以管理网络
#    privileged: true
#
# 验证配置是否正确 docker compose config
# 运行 docker compose up -d
# 查看日志 docker logs openwrt-openclash --tail 50
#
# 初始化配置，修改地址容器内部默认地址可能是 192.168.1.1
# docker exec -it openwrt-openclash sh
# vi /etc/config/network
#
# ------------------------------------------------------------------------------

services:
  openwrt-openclash:
    image: ghcr.io/vickai/immortalwrt-openclash:latest
    container_name: openwrt-openclash

    hostname: openclash

    networks:
      macvlan:
        ipv4_address: 192.168.1.2

    environment:
      - TZ=Asia/Shanghai

    privileged: true

    sysctls:
      - net.ipv6.conf.all.disable_ipv6=1
      - net.ipv6.conf.default.disable_ipv6=1
    restart: always

networks:
  macvlan:
    external: true
```

###  3. 初始化配置

```bash
# 初始化配置，修改地址容器内部默认地址可能是 192.168.1.1
docker exec -it openwrt-openclash sh
vi /etc/config/network
```

**登录后台**：
- 地址：`192.168.1.2` (你设置的 IP)
- 默认用户：`root`
- 默认密码：无（空）

**配置 OpenClash**：
- 进入 `服务` -> `OpenClash`。
- **配置订阅**：添加你的机场订阅地址并更新配置。
- **插件设置**：
  - 模式选择：`Fake-IP (TUN-混合)` 。
  - **防火墙设置**：建议保持默认，内置的 `bypass-autogen` 会自动处理 Docker 环境下的流量转发。
- 启动 OpenClash。

## 🛠️ 技术细节

### 自动防火墙原理 (`bypass-autogen`)

Docker 容器通常缺乏完整的防火墙环境。本项目通过 `bypass-autogen` 脚本：

1. 自动识别容器的 `eth0` IP 和 LAN 网段。
2. 创建自定义防火墙链 `CLASH_REDIRECT` 和 `CLASH_TPROXY`。
3. 自动设置 `TProxy` (UDP) 和 `Redirect` (TCP) 规则，将流量牵引至 Clash 端口。
4. **防回环机制**：自动检测并放行容器自身的流量，防止死循环。

### 目录结构

- `.config.base`: ImmortalWrt 编译配置文件。
- `build-rootfs.sh`: ImageBuilder 构建脚本。
- `files/`: 注入到镜像中的文件（包含启动脚本和防火墙脚本）。

## ⚠️ 注意事项

1. **宿主机通信**：在 Macvlan 模式下，宿主机默认无法直接 ping 通容器 IP。如果需要宿主机也能走代理，需要配置宿主机的 macvlan bridge（搜索 "Docker Macvlan 宿主机通讯"）。
2. **性能**：推荐使用 `Meta` 内核以获得最佳性能。

## 🤝 致谢

- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [OpenClash](https://github.com/vernesong/OpenClash)