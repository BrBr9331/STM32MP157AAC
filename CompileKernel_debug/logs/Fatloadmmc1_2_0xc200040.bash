STM32MP> fatload mmc 1:2 0xc200040 uImage
** Reading file would overwrite reserved memory **
STM32MP> fatload mmc 1:2 0xc4000000 stm32mp157c-100ask-512d-v1.dtb
73271 bytes read in 41 ms (1.7 MiB/s)
STM32MP> setenv bootargs 'root=/dev/mmcblk1p3 rootwait rw console=ttySTM0,115200'
STM32MP> bootm ${kernel_addr_r} - ${fdt_addr_r}
Wrong Image Format for bootm command
ERROR: can't get kernel image!