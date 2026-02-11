
---

# Auto Build ImmortalWrt Docker

基于 **ImmortalWrt** 自动构建的 Docker 镜像，支持集成 **OpenClash** 的功能镜像与 **Standard** 纯净版镜像。

## 🚀 镜像版本说明

本项目通过 GitHub Actions 自动构建并发布至 GHCR，提供以下两个版本以适应不同场景：

| 镜像名称 | 标签 (Tag) | 包含插件 | 开放端口 | 说明 |
| --- | --- | --- | --- | --- |
| `immortalwrt-openclash` | `latest`, `openclash-yymmdd` | OpenClash, Meta 内核, Ruby 等 | 80, 443, 53, 7890-7895 | 预装 OpenClash 的全功能旁路由镜像 |
| `immortalwrt` | `latest`, `24.10.4` | 无（仅基础系统工具） | 80, 443 | 极简纯净版，适合作为基础容器或自建服务 |

## 🛠️ 包含组件 (通用)

两个版本均集成了以下基础能力，确保网络性能与易用性：

* **Web 界面**: LuCI (Argon 主题, 简体中文支持)
* **网络增强**: 全套 `kmod-nft-*` 模块, `iptables-nft`, TProxy 支持
* **常用工具**: `curl`, `wget-ssl`, `bash`, `vim`, `ca-bundle`

## 📦 使用方法

### 1. 拉取镜像

```bash
# 拉取集成版 (默认)
docker pull ghcr.io/vickai/immortalwrt-openclash:latest

# 拉取纯净版
docker pull ghcr.io/vickai/immortalwrt:latest

```

### 2. 部署建议 (旁路由模式)

由于镜像基于 `scratch` 构建并解压 rootfs，建议配合 `macvlan` 网络使用以获得最佳性能。

```bash
docker run -d \
  --name immortalwrt \
  --restart always \
  --network macvlan_net \
  --privileged \
  ghcr.io/vickai/immortalwrt-openclash:latest

# docker exec -it immortalwrt sh
# vi /etc/config/network
# 重启网络 /etc/init.d/network restart
```

## ⚙️ 自动构建流程

本项目利用 GitHub Actions 的 `workflow_dispatch` 实现手动触发构建：

1. **版本选择**: 在 GitHub Actions 界面选择 `standard` 或 `openclash`。
2. **内核预装**: 若选择集成版，构建脚本会自动从 `vernesong/OpenClash` 仓库获取最新的 Meta 内核并预置到 `/etc/openclash/core/`。
3. **OCI 适配**: 镜像包含符合 OCI 标准的标签（Labels），支持在管理工具中直接查看镜像描述与源码关联。

## ⚠️ 注意事项

* **防火墙**: 镜像已移除 `dnsmasq` 以避免与 `dnsmasq-full` 冲突，部署时请注意 DNS 端口占用情况。
* **清理机制**: 系统会自动保留每个镜像最新的 3 个版本，旧镜像将被自动清理。

---
