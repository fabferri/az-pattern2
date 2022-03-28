<properties
pageTitle= 'Azure VM Scale Set in a Flexible Orchestation mode'
description= "Azure VM Scale Set in a Flexible Orchestation mode"
documentationcenter: na
services="Azure Virtual Machine Scale Set"
documentationCenter="na"
authors="fabferri"
manager=""
editor=""/>

<tags
   ms.service="configuration-Example-Azure"
   ms.devlang="na"
   ms.topic="article"
   ms.tgt_pltfrm="azure"
   ms.workload="na"
   ms.date="09/03/2022"
   ms.author="fabferri" />

# Azure VM Scale Set in a Flexible Orchestation mode
VMSS (Virtual Machine Scale Set) is available in two modes:
- Virtual Machine Scale Sets **Uniform Orchestration mode**. In **Uniform Orchestration mode** VMs created with Uniform orchestration mode are exposed and managed via the virtual machine scale set VM API commands
- Virtual Machine Scale Sets **Flexible Orchestration mode**. In **Flexible Orchestration mode** each VM instance can be managed by standard Azure IaaS VM APIs


Flexible orchestration mode is a features in Virtual Machine Scale Set (VMSS) with following charateristic:
- each instance can be managed by  standard Azure IaaS VM APIs 
- use the standard VM commands to start, stop, restart, delete instances
- full control over the VM, NICs, disks using the standard Azure IaaS VM APIs
- Linux and Windows can reside in the same Flexible scale set



<!--Image References-->

[1]: ./media/network-diagram1.png "network diagram"


<!--Link References-->

