#!/system/bin/sh

if [ -n "$KSU" ]; then
	ui_print "* 检测到 KernelSU，请确认已安装 Zygisk 模块"
fi

ui_print "* 请确保 Magisk 已开启 Zygisk"
ui_print "* 不要把需要截图/投屏的应用加入 DenyList"
ui_print "* 并为它们关闭「卸载模块 / Unmount modules」"
ui_print ""
ui_print "* Based on j-hc/ih8SecureLock + ziachi addToDisplay hooks"
ui_print "* Fork: Ghostpanter/ih8SecureLock-scrcpy"
