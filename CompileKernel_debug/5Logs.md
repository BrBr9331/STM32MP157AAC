## 5 Appendix

为保证正文阅读流畅，完整操作日志、报错日志、启动日志等统一归档在此附录中，供需要复现问题的读者查阅。

| 文件名 | 对应场景 |
|--------|----------|
| `logs/InsufficientMemory.txt` | 批量拷贝内核模块触发内存耗尽告警 |
| `logs/CannotReboot.txt` | NFS挂载导致reboot阻塞、关机卡住 |
| `logs/PrefetchAbort.txt` | 自制内核启动触发prefetch abort、无限复位完整日志 |
| `logs/tftpboot.txt` | 原厂内核TFTP加载、成功启动完整日志 |

<details>
<summary><b>👉 点击展开/折叠：附录日志及分区图表 (点击查看)</b></summary>

<br>

### InsufficientMemory.bash

@import "logs/InsufficientMemory.bash"

### CannotReboot.txt

@import "logs/CannotReboot.txt"

### PrefetchAbort.txt

@import "logs/PrefetchAbort.txt"

### tftpboot.txt

@import "logs/tftpboot.txt"