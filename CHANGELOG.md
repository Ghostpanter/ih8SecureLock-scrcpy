## v10.2-scrcpy

- **修复 Zygisk 加载失败**：`dlopen` 报 `library "libc++_shared.so" not found`（HyperOS A16 / MI 9 等）
- 使用 NDK **c++_static**（`-static-libstdc++`）静态链接 C++ 运行时，`.so` 的 `NEEDED` 不再依赖 `libc++_shared.so`
- 重新 `readelf -d` 校验各 ABI

## v10.1-scrcpy

- 基于 j-hc/ih8SecureLock v10：relayout / relayoutAsync / relayout2、截图监听绕过、DenyList 检测、parcel 边界检查
- 合并 ziachi：`addToDisplay` / `addToDisplayAsUser`，改善 scrcpy / 虚拟显示黑屏
- **不** hook system_server，降低对无线 ADB 的干扰
- 中文 README；Magisk Zygisk 安装包
