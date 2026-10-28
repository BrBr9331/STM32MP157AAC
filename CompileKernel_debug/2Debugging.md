## 2. Debugging

### 2.1 初步排除：内核模块不影响启动阶段
**思路：** 先划定故障发生的阶段，缩小排查范围。
`/lib/modules` 目录下的驱动模块，仅在内核启动完成、挂载根文件系统之后才会被加载。而故障发生在 `Starting kernel ...` 瞬间，此时内核刚解压、尚未挂载根文件系统，完全不会读取模块文件。
**结论：** 本次启动崩溃与拷贝内核模块无关，问题集中在 uImage 内核镜像、dtb 设备树、启动地址、硬件固件兼容性四个方向。

### 2.2 校验boot分区：排除文件损坏
**思路：** 异常断电容易导致FAT格式的boot分区文件损坏，先验证文件完整性。进入U-Boot交互界面（上电倒计时按空格），执行如下命令

 @import "logs/Fatloadmmc1_2.bash"

**结论：** boot 分区未损坏，内核文件本身可读、校验和正常，排除文件截断、闪存坏块问题。

#### 2.2.1 易错点澄清：U-Boot 与 Linux 的 MMC 编号不一致

**思路：** 排查过程中一度混淆 mmc 设备编号，这是 STM32MP 平台高频踩坑点，专门验证确认。执行 `printenv` 与 `mmc dev` 测试：

```
mmc dev 2    # 返回 MMC Device 2 not found
mmc dev 1    # 切换成功
mmc part     # 列出ssbl/rootfs1/rootfs2三个分区
```


| 视角 | eMMC 设备名 | boot 分区 | rootfs 分区 |
| --- | --- | --- | --- |
| U-Boot | mmc1 | mmc 1:2 (rootfs1) | mmc 1:3 (rootfs2) |
| Linux 内核 | mmcblk2 | /dev/mmcblk2p2 | /dev/mmcblk2p3 |

**结论：**

- U-Boot 与 Linux 内核的 MMC 控制器枚举顺序不同，编号没有一一对应关系；
- bootargs 中根分区必须写 `/dev/mmcblk2p3`，写错会导致找不到根文件系统；
- 本次 prefetch abort 不是分区号错误导致的（分区错误表现为卡 Waiting for root device，不会直接复位）。

#### 2.2.2 加载地址试探：安全保留内存限制

**思路：** 怀疑内核加载地址不对，尝试直接加载到 uImage 头部声明的入口地址。

```bash
fatload mmc 1:2 0xc200040 uImage
** Reading file would overwrite reserved memory **
```

**结论：**`0xc200040` 属于 TF-A/SP_MIN 安全固件的保留内存区域，U-Boot 做了保护，禁止直接写入。正确做法是将 uImage 加载到普通空闲内存（如 `0xc4200000`），`bootm` 命令会自动解析 uImage 头部，将内核搬运到它声明的 Load Address 处，无需手动加载到入口地址。更换到空闲地址加载后，依然启动崩溃，说明不是 U-Boot 加载地址的问题。

### 2.3 eMMC本地启动

内核 / 设备树复制到 eMMC 的 boot 分区文件大概率损坏、没刷对，因此让U-Boot 从 eMMC 加载 uImage + dtb，挂载 eMMC 上的 ext4 根文件系统 `/dev/mmcblk2p3`

@import "logs/Printenv.bash"

板子默认扫描mmc1，即板载eMMC,则mmc0一般是 SD 卡插槽。这个U-Boot是STM32MP的distro自动启动模式（extlinux 方式），不是简单手动 fatload 直接 bootm 的老式写法，它不是直接读 uImage，而是去 bootfs 分区找 `extlinux/stm32mp157c-100ask-512d-v1_extlinux.conf`这个配置文件，由这个配置文件指定内核、dtb、bootargs。

> @import "logs/mmcdev1.bash"
>
>> 再次验证mmc dev 1 是eMMC，其中
> Part 1：ssbl       `TF-A / FIP 安全固件分区`
> Part 2：rootfs1    `FAT分区，存放 uImage、dtb、boot.scr.uimg、mmc1_extlinux`
> Part 3：rootfs2    `Linux ext4 根文件系统分区`
> 至此，当前磁盘分区示意如下图所示（不同固件的设备树编号略有差异，以实际挂载、启动日志为准）
>@import "logs\DiskPartitionDiagram.txt"
>
> @import "logs/Fatloadmmc1_2_0xc200040.bash"
> 
>> `0xc200040` 这个地址属于 TF-A/SP_MIN 的保留安全内存区域，U-Boot 保护起来了，不允许在这里直接加载文件！这是 STM32MP 信任固件（TF-A）的硬性限制，不能直接往 Entry 地址加载 uImage，于是更换到更高的地址，依旧无效

问题发生时没有检查地址，所以依旧不能定位问题，因此先用原厂自带的内核启动，排除硬件、固件故障

### 2.4 隔离验证：原厂镜像启动

**思路：**之前把 eMMC mmc1:2 分区里面原厂 uImage 覆盖成了你自己编译的版本，现在分区里已经没有原厂内核了，所以自动启动也在跑你这个新内核，一起崩溃。现在从 Ubuntu TFTP 下载一份 SDK 原厂配套 uImage、dtb，放回 mmc1:2，验证启动。

> ```bash
> br@ubuntu:~$ mkimage -l ~/Desktop/Buildroot_2020/uImage #校验内核信息
> Image Name:   Linux-5.4.31
> Created:      Thu Oct 27 19:09:36 2022
> Image Type:   ARM Linux Kernel Image (uncompressed)
> Data Size:    8187608 Bytes = 7995.71 KiB = 7.81 MiB
> Load Address: c2000040
> Entry Point:  c2000040
>```

```bash
setenv ipaddr 192.168.145.129
setenv serverip 192.168.145.128
saveenv # 把 bootargs、bootcmd 写到 eMMC 的 U‑Boot 环境分区
# 保证Ubuntu的/tftpboot有uImage、dtb，然后继续进行。
# 经尝试，开发板当前不支持`fatwrite`命令，因此直接采用TFTP加载内核、dtb启动方式
tftp 0xc4200000 uImage
# fatwrite mmc 1:2 0xc4200000 uImage ${filesize} 
tftp 0xc4000000 stm32mp157c-100ask-512d-v1.dtb
# fatwrite mmc 1:2 0xc4000000 stm32mp157c-100ask-512d-v1.dtb ${filesize}
mmc dev 1
tftp 0xc4200000 uImage 
# Replace 'fatload mmc 1:2 0xc4200000 uImage'
tftp 0xc4000000 stm32mp157c-100ask-512d-v1.dtb 
# Replace 'fatload mmc 1:2 0xc4000000' stm32mp157c-100ask-512d-v1.dtb'
setenv bootargs 'root=/dev/mmcblk2p3 rootwait rw console=ttySTM0,115200'
# 不要写错设备号(mmcblk1p3等)，否则找不到根文件系统
bootm 0xc4200000 - 0xc4000000
```
成功启动，但是大量 `Unknown symbol __stack_chk_guard`，这个是栈保护符号不匹配根文件系统里的 ko 模块（wifi、cec、galcore、led_drv 等）是用开启`STACK_PROTECTOR`的编译器编译的；但是当前这个原版内核镜像编译时没有开启栈保护，内核和模块编译选项不一致会使模块加载失败。

### 2.5 根因锁定：LOADADDR 参数错误

对比原厂与自制内核的头部信息：

```bash
# 原厂内核
mkimage -l buildroot_2020/uImage
Load Address: c2000040
Entry Point:  c2000040

# 自制内核
mkimage -l sdk/uImage
Load Address: 0c200040
Entry Point:  0c200040
```

**差异：** 自制内核的 LOADADDR 少写了一个 `0`，地址从 `0xC2000040` 变成了 `0x0C200040`，完全偏移到了非法内存区域。
**原理说明：**`LOADADDR` 是内核的链接基地址，编译阶段内核的所有函数地址、跳转指令、符号表全部基于该地址计算。地址错误时，U-Boot 跳转入内核入口后，CPU 取指地址落在 TF-A 安全保留区域或未映射空间，直接触发 ARM 架构的预取指异常（prefetch abort），导致系统复位。