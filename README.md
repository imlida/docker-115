# docker-115

115 网盘 Linux 桌面客户端的 RDesktop Docker 镜像。

镜像基于 `ghcr.io/linuxserver/baseimage-rdesktop:ubuntunoble`，安装 115 客户端 `36.0.0`，并在 RDP 会话启动后自动打开 `/usr/local/115Browser/115.sh`。

## 功能

- 通过 RDP 访问 115 桌面客户端，默认端口 `3389`。
- `/config` 持久化 115 登录态和应用配置。
- `/downloads` 单独挂载为下载目录。
- 内置中文字体和常见桌面客户端运行依赖。
- GitHub Actions 可发布镜像到 Docker Hub。

## 本地构建

```bash
docker build --platform linux/amd64 -t docker-115:36.0.0 .
```

## 使用 Docker Compose 运行

```bash
docker compose up -d
```

启动后使用 RDP 客户端连接：

```text
localhost:3389
```

首次登录 115 后，建议在 115 客户端设置里把下载目录改为：

```text
/downloads
```

这样下载文件会出现在宿主机的 `./downloads` 目录中。115 的登录态和配置会保存在宿主机的 `./config` 目录中。

## RDP 登录账号和密码

默认 RDP 登录信息为：

```text
用户名：abc
密码：abc
```

可以在 `docker-compose.yml` 中修改：

```yaml
environment:
  - RDP_USER=abc
  - RDP_PASSWORD=your-password
```

也可以在项目目录创建 `.env` 文件覆盖默认值：

```env
RDP_USER=user115
RDP_PASSWORD=change-me
```

修改后重建并重启容器：

```bash
docker compose up -d --build
```

## docker-compose.yml 说明

默认 compose 配置会：

- 构建并运行 `linux/amd64` 平台的 `docker-115:36.0.0`。
- 映射 `3389:3389`。
- 映射 `./config:/config`。
- 映射 `./downloads:/downloads`。
- 设置 `LC_ALL=zh_CN.UTF-8`。
- 设置 `RDP_USER` 和 `RDP_PASSWORD`，用于配置 RDP 登录账号和密码。
- 设置 `security_opt: seccomp:unconfined`，提高 Chromium/Electron 类桌面程序在容器内启动的兼容性。
- 设置 `shm_size: 1gb`，避免默认共享内存过小导致客户端异常。

如果宿主机的 `3389` 已被占用，可以修改 compose 中的端口映射，例如：

```yaml
ports:
  - "3390:3389"
```

然后连接 `localhost:3390`。

## Docker Hub 发布

仓库包含 GitHub Actions workflow：`.github/workflows/docker-publish.yml`。

发布触发条件：

- 推送到 `main` 分支。
- 在 GitHub Actions 页面手动运行 `Publish Docker image`。

发布目标：

```text
${DOCKERHUB_USERNAME}/docker-115
```

发布 tags：

- `latest`
- `36.0.0`

需要在 GitHub 仓库的 `Settings -> Secrets and variables -> Actions` 中配置：

| Secret | 说明 |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub 用户名或组织名 |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

## 升级 115 客户端版本

升级客户端时需要同步修改：

- `Dockerfile` 中的 `CLIENT_VERSION` 和 `CLIENT_URL`。
- `.github/workflows/docker-publish.yml` 中的 `CLIENT_VERSION`。
- `docker-compose.yml` 中的镜像 tag。
- 本 README 中出现的版本号和下载说明。

修改后建议先本地构建验证：

```bash
docker build --platform linux/amd64 -t docker-115:<new-version> .
docker compose up -d
```

确认 RDP 能打开客户端后，再合并到 `main` 触发 Docker Hub 发布。

## 常见问题

### RDP 连接后客户端没有启动

先查看容器日志：

```bash
docker logs docker-115
```

也可以在 RDP 桌面右键菜单中重新启动 `115`。

### 客户端窗口空白或启动后退出

确认 compose 中保留了：

```yaml
security_opt:
  - seccomp:unconfined
shm_size: "1gb"
```

部分图形环境还可能需要把主机渲染设备挂入容器：

```yaml
devices:
  - /dev/dri:/dev/dri
```

### 如何停止服务

```bash
docker compose down
```
