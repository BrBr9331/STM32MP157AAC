# STM32MP157: Compile the kernel and device tree, and debug 'prefetch abort'.

> **Date :** 2026-10-21 UTC+8 22:59
> **Development Board :** STM32MP157AAC based on DongShan Wei`192.168.145.129`
> **System Environment :** Windows10 22H2 Host , VMware Workstation17 , Linux-5.4
> **Current State :** Solved

**The core of the malfunction lies in the incorrect writing of the uImage loading address. The article does not discuss this fundamental error. Instead aims to troubleshoot the 'prefetch abort' issue encountered in the kernel, providing a beginner's perspective on understanding and learning embedded Linux. This will enable readers to quickly analyze and locate faults, and expand their knowledge to avoid falling into pitfalls again. All commands for the development board are executed through the serial port.**

[toc]

@import "1Symptom.md"

@import "2Debugging.md"

@import "3Improvement.md"

@import "4Summary.md"

@import "5Logs.md"