---

## 🧱 第一步：检查系统要求

### ✅ 你的系统必须：
- **Windows 11 家庭版**
- **64 位操作系统**
- **启用虚拟化（BIOS 里开启）**
  - 开机时按 `F12`(dell) 进入 BIOS，确保 `Virtualization Technology (VT-x)` 已启用

---

## 🐧 第二步：安装 WSL2（Docker 运行的依赖）

打开 PowerShell（以管理员身份），执行以下命令：

```powershell
wsl --install
```

安装后会自动设置 **Ubuntu** 作为默认 Linux 发行版。

如果提示 WSL2 可用，就继续，或者你可以手动指定：

```powershell
wsl --set-default-version 2
```

---

## 🐳 第三步：安装 Docker Desktop

1. 打开官网：[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
2. 点击 `Download for Windows (WSL2)`
3. 下载完成后双击安装包，注意：
   - 勾选 **"Use WSL 2 instead of Hyper-V"**
   - 安装完成后 **重启电脑**

---

## ✅ 第四步：验证 Docker 是否可用

打开 **Docker Desktop**，启动时它会自动连接 WSL2。如果成功，会显示绿色的 `Docker is running`。

然后在终端（PowerShell 或 CMD）输入：

```bash
docker version
```

看到类似以下输出，说明安装成功 ✅

```bash
Client: Docker Engine - Community
...
Server: Docker Engine - Community
...
```

---

## 🛠️ 如果遇到问题？

### ❓ 报错：WSL2 not installed？
手动安装 Linux 内核更新包：

- 下载链接：<https://aka.ms/wsl2kernel>
- 安装后重新执行 `wsl --set-default-version 2`

---

## 🧪 测试一个容器

```bash
docker run hello-world
```

如果一切正常，会输出欢迎信息，证明 Docker 可以正常拉取镜像并运行容器 ✅

---

## 🧼 推荐做法：添加 .wslconfig 优化性能（可选）

在 `C:\Users\<你的用户名>` 下创建 `.wslconfig` 文件：

```ini
[wsl2]
memory=4GB
processors=2
```

---

## ✅ 总结流程

1. ✅ 开启 BIOS 虚拟化
2. ✅ 安装 WSL2（`wsl --install`）
3. ✅ 安装 Docker Desktop（选择 WSL2）
4. ✅ 启动 Docker 并测试（`docker run hello-world`）

---

如果你愿意告诉我你的 Docker 用途（比如跑 OpenAI 项目、部署 SpringBoot 服务、玩 GPT 模型之类），我可以给你搭配一份定制开发环境 😉