## 1. ‌Fault Background and Symptom

### 1.1 Operation Objective

自行编译 Linux 内核与设备树，替换板载 eMMC 中的原厂内核镜像，验证内核编译结果，为后续驱动开发做准备。

### 1.2 Experimental Environment

| 层级 | 设备/系统 | IP地址 | 说明 |
|------|-----------|--------|------|
| 宿主机 | Windows 10 22H2 | 192.168.145.127 | 运行VMware与串口工具 |
| 虚拟机 | Ubuntu 22.04.5 | 192.168.145.128 | 交叉编译、NFS服务、TFTP服务 |
| 开发板 | Buildroot + Linux 5.4 | 192.168.145.129 | eMMC本地启动，串口调试 |

### 1.3 Reproduction Steps

1. 检查挂载文件夹权限 
   
   ```sh
   cat /etc/exports 
   ```

    ![alt text](images/image.png)
    `/nfsroot *(rw,sync,no_subtree_check,no_root_squash)` 
    \* 允许任意IP，rw读写权限，sync同步写入，no_root_squash保留root用户权限。同时设置目录权限 `sudo chmod 777 /nfsroot` 并执行 `sudo exportfs -arv` 生效。

2. 在开发板将Ubuntu的/nfsroot挂载到/mnt
   
    ```sh
    mount -t nfs -o nolock,vers=3 192.168.145.128:/nfsroot /mnt
    ``` 

3. 编译内核配置文件、设备树
   
    ```sh 
    cd 100ask_stm32mp157_pro-sdk/Linux-5.4 #（内核源码目录）
    make 100ask_stm32mp157_pro_defconfig
    make uImage LOADADDR=0xC200040 -j4 
    # 加载地址(Load Address)这里正确地址应该为0xC2000040，地址错误是出现故障的根本原因，而编译程序不会在此报错！
    make dtbs 
    # 编译完成后，在arch/arm/boot生成uImage文件；在arch/arm/boot/dts生成设备树二进制文件stm32mp157c-100ask-512d-v1.dtb
    ```

4. 复制编译产物uImage和stm32mp157c-100ask-512d-v1.dtb到/nfsroot
5. 进入内核源码目录，编译内核模块
   
    ```sh
    make ARCH=arm CROSS_COMPILE=arm-buildroot-linux-gnueabihf- modules -j4
    ```

6. 在开发板将磁盘分区挂载到/boot
   
    ```sh
    mount /dev/mmcblk2p2 /boot
    ```

7. 替换板载内核与模块
   
    ```sh
    cp /mnt/uImage /boot
    cp /mnt/stm32mp157c-100ask-512d-v1.dtb /boot
    cp /mnt/lib/modules -rf /lib
    ```

8.  同步并重启
    
    ```sh
    sync
    reboot
    ```

### 1.4 Fault Phenomenon

1. 执行`cp /mnt/lib/modules -rf /lib`时内存耗尽，NFS一边持续收大包、一边往SD卡写，512M内存太小，NFS接收skb分配失败，只要走NFS读取大量小文件，就容易触发这个报错。
    >- 作为初学者，NFS根文件系统启动是值得进一步学习的，SD卡拷贝是固化方式。此处采用手动分批量复制子目录的方式。
    >- 韦东山在后续采用了安卓调试桥(Android Debug Bridge,ADB)完成复制；写驱动优先NFS rootfs，写上层应用、测试小demo用adb push
2.  `reboot`卡住，尝试卸载/mnt并重启时发生故障
    > Starting kernel ...
    > prefetch abort
    > pc : [<0c20003c>]
    > ...
    > Resetting CPU ...
    >resetting ...

    崩溃发生在 `Starting kernel ...` 之后瞬间，系统反复复位，无法进入根文件系统，这是本次故障的核心问题。
