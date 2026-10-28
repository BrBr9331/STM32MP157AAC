>Press SPACE to abort autoboot in 1 seconds
STM32MP> mmc dev 1
switch to partitions #0, OK
mmc1(part 0) is current device
STM32MP> fatls mmc 1:2
73271   stm32mp157c-100ask-512d-v1.dtb
2854   boot.scr.uimg
74438   stm32mp157c-100ask-512d-lcd-v1.dtb
108418   stm32mp157c-100ask-512d-hdmi-v1.dtb
8171336   uImage
mmc1_extlinux/
mmc0_extlinux/
3632283   uInitrd
46180   splash.bmp
7 file(s), 2 dir(s)
# 正常列出所有文件，包括 uImage、dtb、boot.scr.uimg、uInitrd 等，说明分区表与文件结构完好。
# 继续加载内核到内存，验证可读性
STM32MP> fatload mmc 1:2 0xc2000000 uImage
8171336 bytes read in 316 ms (24.7 MiB/s)
# 文件完整读取，U-Boot 校验和通过。