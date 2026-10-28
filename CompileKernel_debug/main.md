# STM32MP157: Compile the kernel and device tree, and debug 'prefetch abort'.

> **Date :** 2026-10-21 UTC+8 22:59
> **Development Board :** STM32MP157AAC based on DongShan Wei`192.168.145.129`
> **System Environment :** Windows10 22H2 Host , VMware Workstation17 , Linux-5.4
> **Current State :** Solved

**The core of the malfunction lies in the incorrect writing of the uImage loading address. The article does not discuss this fundamental error. Instead aims to troubleshoot the 'prefetch abort' issue encountered in the kernel, providing a beginner's perspective on understanding and learning embedded Linux. This will enable readers to quickly analyze and locate faults, and expand their knowledge to avoid falling into pitfalls again. All commands for the development board are executed through the serial port.**

1. [1. Symptom](#1-symptom)
   1. [1.1 操作目的](#11-操作目的)
   2. [1.2 实验环境](#12-实验环境)
   3. [1.3 复现步骤](#13-复现步骤)
   4. [1.4 核心故障现象](#14-核心故障现象)
2. [2. Debugging](#2-debugging)
   1. [2.1 初步排除：内核模块不影响启动阶段](#21-初步排除内核模块不影响启动阶段)
   2. [2.2 校验 boot 分区：排除文件损坏](#22-校验-boot-分区排除文件损坏)
      1. [2.2.1 易错点澄清：U-Boot 与 Linux 的 MMC 编号不一致](#221-易错点澄清u-boot-与-linux-的-mmc-编号不一致)
      2. [2.2.2 加载地址试探：安全保留内存限制](#222-加载地址试探安全保留内存限制)
   3. [2.3 eMMC 本地启动](#23-emmc-本地启动)
   4. [2.4 隔离验证：原厂镜像启动](#24-隔离验证原厂镜像启动)
   5. [2.5 根因锁定：LOADADDR 参数错误](#25-根因锁定loadaddr-参数错误)
3. [3. Improvement](#3-improvement)
   1. [3.1 固化 U-Boot，使能上电 eMMC 启动](#31-固化-u-boot使能上电-emmc-启动)
   2. [3.2 附带问题：NFS 挂载导致重启阻塞](#32-附带问题nfs-挂载导致重启阻塞)
4. [4. Summary](#4-summary)
   1. [4.1 故障原因总结](#41-故障原因总结)
   2. [4.2 排查方法总结](#42-排查方法总结)
   3. [4.3 知识点总结](#43-知识点总结)
5. [5. Appendix](#5-appendix)

@import "1Symptom.md"

@import "2Debugging.md"

@import "3Improvement.md"

@import "4Summary.md"

@import "5Appendix.md"