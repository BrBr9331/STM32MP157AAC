STM32MP> mmc dev 1
switch to partitions #0, OK
mmc1(part 0) is current device
STM32MP> mmc part
Partition Map for MMC device 1  --   Partition Type: EFI
Part	Start LBA	End LBA		Name    
1	0x00000400	0x000013ff	"ssbl"  
2	0x00001400	0x000413ff	"rootfs1"
3	0x00041400	0x00747bff	"rootfs2"
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