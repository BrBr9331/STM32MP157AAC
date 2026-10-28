root@100ask:/mnt/01_hello# cp /mnt/uImage /boot 
root@100ask:/mnt/01_hello# cp /mnt/*.dtb /boot 
root@100ask:/mnt/01_hello# cp /mnt/lib/modules /lib -rfd
>[16858.876761] Normal free:3088kB min:10396kB low:10944kB high:11492kB active_anon:14944kB inactive_anon:176kB active_file:33740kB inactive_file:341808kB unevictable:0kB writepending:37252kB present:458752kB managed:435976kB mlocked:0kB kernel_stack:816kB pagetables:428kB bounce:0kB free_pcp:424kB local_pcp:328kB free_cma:12kB
root@100ask:/mnt/01_hello# mount /dev/mmcblk2p3 on / type ext4 (rw,relatime)
# mmcblk2p3是板子本地根文件系统（现在板子跑的系统），从eMMC加载正常开机启动就有，和NFS rootfs无关！