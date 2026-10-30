## 3. Improvement and remaining issues

### 3.1 Solidify U-Boot to Enable Power-on eMMC Boot

```bash
@import "logs/DiskPartitionDiagram.txt"
```

把启动固件、内核、根文件系统分开，旨在安全升级、故障隔离：(1)内核刷坏了，U-Boot 还在，就能用 TFTP 救砖；(2)根文件系统坏了，内核和 U-Boot 正常，就能进急救模式。

```bash
mount /dev/mmcblk2p2 /boot
# 先备份原来的坏内核（可选，建议留底）
mv /boot/uImage /boot/uImage_bad
mv /boot/stm32mp157c-100ask-512d-v1.dtb /boot/stm32mp157c-100ask-512d-v1.dtb_bad
cp /mnt/uImage /boot/
cp /mnt/stm32mp157c-100ask-512d-v1.dtb /boot/
sync
umount /boot
reboot
[26317.848387] nfs: server 192.168.145.128 not responding, still trying # 重启时仍然卡在nfs，理论上已经卸载了/boot，不应该出现
poweroff # 执行关机，成功关机
```
因为已经固化成功，而且不存在地址写入错误，板子再次通电后成功启动。

### 3.2 Legacy Issue: System Hang Caused by NFS Mounting

**现象：** 手动挂载 `/mnt` NFS 目录后，直接执行 `reboot` 会卡在 NFS 等待，而执行 `poweroff` 可以正常下电。

```bash
nfs: server 192.168.145.128 not responding, still trying
```

**原因：** Buildroot 默认关机流程中，网络服务先于文件系统停止；手动挂载的 NFS 没有专属卸载脚本，网卡断开后 NFS 客户端会阻塞等待服务器响应，导致关机流程卡住。`poweroff` 直接触发 PSCI 硬件下电，不等待所有服务优雅退出，因此不会阻塞。
**方案（尚未验证）：** 修改 `/etc/init.d/S40network`，在 `stop` 分支最前端加入强制卸载

```bash
stop)
    umount -f /mnt 2>/dev/null
    printf "Stopping network: "
    ...
```
