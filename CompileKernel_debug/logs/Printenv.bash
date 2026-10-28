STM32MP> printenv           #打印环境
altbootcmd=run bootcmd
arch=arm
autoload=no
boot_targets=mmc1
bootcmd=run bootcmd_stm32mp
bootcmd_android=env set mmc_boot run android_mmc_boot;run bootcmd_stm32mp
bootcmd_mmc0=devnum=0; run mmc_boot
bootcmd_mmc1=devnum=1; run mmc_boot
bootcmd_mmc2=devnum=2; run mmc_boot
ver=U-Boot 2020.01-stm32mp-r1 (Aug 16 2026 - 09:15:35 +0800)
Environment size: 6067/8187 bytes
STM32MP> mmc dev 2          # 进入mmc，读取eMMC里的uImage和dtb
MMC Device 2 not found      # 然而，在U-Boot视角里没有 mmc2
no mmc device at slot 2
STM32MP> mmc part
Card did not respond to voltage select!