# ih8SecureLock (scrcpy) — Zygisk 关闭 FLAG_SECURE

面向 **小米 MI 9 / HyperOS / Android 16** 等设备，在 **不安装 LSPosed** 的前提下，用 Magisk Zygisk 去掉窗口的 `FLAG_SECURE`，让 **scrcpy 投屏** 与截图能显示原本加密/安全层内容。

效果接近 LSPosed 模块「Enable Screenshot / DisableFlagSecure」仅勾选 **System Framework** 的用法，但：

- **不依赖 LSPosed / Xposed**
- **不注入 system_server**（减少对无线 ADB 等系统服务的干扰；你曾在 Enable Screenshot v5.0.1 上遇到过无线 ADB 异常）
- 在 **应用进程** 里 hook `libbinder` 的 `IPCThreadState::transact`，剥离发往 `IWindowSession` 的 `FLAG_SECURE`

## 致谢 / 来源（Apache-2.0）

本模块基于以下开源项目改编，请遵守其许可证：

- [j-hc/ih8SecureLock](https://github.com/j-hc/ih8SecureLock) — Zygisk 主实现（relayout / 截图监听绕过）
- [ziachi/ih8SecureLock](https://github.com/ziachi/ih8SecureLock) — `addToDisplay` / `addToDisplayAsUser` 增强，修复 scrcpy / 虚拟屏黑屏

本仓库合并：j-hc v10（含 Android 17 `relayout2`、DenyList 检测、parcel 边界检查）+ ziachi 的初始建窗 hook。

## 适用环境

| 项目 | 要求 |
|------|------|
| Root | Magisk（推荐）或带 Zygisk 的 KernelSU |
| Zygisk | **必须开启** |
| Android | 10 – 17（已在源码侧兼容；目标机：HyperOS Android 16） |
| LSPosed | **不需要**，请勿与旧版 Enable Screenshot 同时启用同一作用 |

## 安装步骤（中文）

1. 打开 **Magisk** → **设置** → 确认 **Zygisk 已开启**。若刚打开，先重启一次。
2. Magisk → **模块** → **从本地安装** → 选择本仓库 Release 中的  
   `ih8SecureLock-scrcpy-v10.1-scrcpy.zip`。
3. 安装成功后 **重启手机**。
4. **不要**把需要截图/投屏的 App（以及你的 scrcpy-android 客户端相关进程若在手机上）放入 Magisk **排除列表 / DenyList**；若使用 Shamiko 等，对该 App **关闭 Unmount modules**。
5. 用 **scrcpy-android**（或电脑端 scrcpy）连接 MI 9，打开原先黑屏的加密/安全界面，确认镜像可见内容。
6. 可选自检日志：
   ```bash
   adb shell su -c "logcat -d -s ih8SecureLock"
   ```
   正常可见类似：
   ```
   ih8SecureLock: ... SDK: 36
   ih8SecureLock: ... Hook relayout: code=...
   ih8SecureLock: ... Hook addToDisplayAsUser: code=...
   ih8SecureLock: ... Loaded
   ih8SecureLock: ... Bypassed secure lock (addToDisplayAsUser)
   ```

## 与无线 ADB

- 本模块 **不 hook system_server**，也 **不 patch services.jar**。
- 若曾安装 Enable Screenshot（LSPosed）导致无线 ADB 异常：请在 LSPosed 中 **禁用/卸载** 该模块并重启后，再装本 Zygisk 模块。
- 若仍异常：Magisk 中暂时禁用本模块并重启，对比无线配对是否恢复，以便排查。

## 卸载

1. Magisk → 模块 → 本模块 → **删除 / Remove**
2. 重启  
卸载后行为立即恢复系统默认（不再剥离 FLAG_SECURE）。

## 构建（开发者）

```bash
export ANDROID_NDK_HOME=/path/to/ndk
./scripts/build.sh
./scripts/package.sh
```

## 免责声明

仅供学习与个人设备调试（如 scrcpy 投屏）。绕过应用截屏保护可能违反部分应用服务条款；请勿用于未授权内容获取。作者与贡献者不对使用后果负责。
