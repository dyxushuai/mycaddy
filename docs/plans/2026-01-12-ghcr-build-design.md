# GHCR 自动构建与推送设计

## 背景与目标
本仓库提供自定义 Caddy 的 Docker 构建，包含 caddy-l4 和 caddy-dns/cloudflare 插件。目标是使用 GitHub Actions 自动构建多架构镜像，并推送到 GHCR，采用清晰且可复现的标签策略，默认公开可拉取。

## 需求与约束
- 触发方式: push 到 main + workflow_dispatch
- 镜像地址: ghcr.io/<owner>/mycaddy
- 标签策略: latest + 短 sha
- 架构: linux/amd64 与 linux/arm64
- 权限最小化: contents read, packages write
- 使用现有 Dockerfile 构建

## 方案概述
使用 GitHub Actions 进行多阶段构建与推送。通过 buildx 实现多架构构建，metadata-action 生成标签与 labels。登录 GHCR 使用 GITHUB_TOKEN。构建与推送在同一作业完成，并输出构建结果与 digest 以便验证。

## 架构
- 工作流文件: .github/workflows/build.yml
- 作业: build
- 运行环境: ubuntu-latest
- 依赖动作: actions/checkout, docker/setup-qemu-action, docker/setup-buildx-action, docker/login-action, docker/metadata-action, docker/build-push-action

## 组件
- Dockerfile: 负责构建自定义 Caddy 二进制并生成运行镜像
- Buildx: 多架构构建
- GHCR: 镜像托管
- Metadata: 标签与 OCI labels 生成

## 数据流
源代码与 Dockerfile -> buildx 构建 -> 生成 latest 与短 sha 标签 -> 推送到 ghcr.io/<owner>/mycaddy -> 输出 digest

## 错误处理
- 登录失败: 检查 GITHUB_TOKEN 权限与 packages write
- 构建失败: 检查 Dockerfile 与插件版本
- 多架构失败: 确认 qemu 与 buildx 初始化成功
- 拉取失败: GHCR 包需设置为 Public

## 测试与验证
- 构建日志确认 caddy 版本与插件加载
- 可选验证: buildx imagetools inspect 镜像清单
- 可选验证: 运行 caddy list-modules 检查模块

## 安全与权限
- permissions 最小化: contents read, packages write
- 不使用长期凭据，仅用 GITHUB_TOKEN

## 非目标
- 不引入额外单元测试或 e2e 测试
- 不改变运行镜像内容或 Caddyfile 结构
