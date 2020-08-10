<properties
pageTitle= 'How to configure Remote Desktop to connect to a ubuntu 20.04 VM in Azure'
description= "How to configure Remote Desktop to connect to a ubuntu 20.04 VM in Azure"
documentationcenter: na
services=""
documentationCenter="na"
authors="fabferri"
manager=""
editor=""/>

<tags
   ms.service="configuration-Example-Azure"
   ms.devlang="na"
   ms.topic="article"
   ms.tgt_pltfrm="na"
   ms.workload="na"
   ms.date="09/08/2020"
   ms.author="fabferri" />

# How to configure Remote Desktop to connect to a Ubuntu 20.04 Azure VM 
Ubuntu offers several desktop flavors:
* **GNOME 3.36** is a default Ubuntu 20.04 desktop environment. It includes a variety of desktop applications
* **MATE** Desktop Environment is based on GNOME 2
* **Xfce** Desktop Environment
* **Kubuntu** Desktop Enviroment based on KDE 
* **Xubuntu** Desktop Enviroment based on Xfce

xrdp is a free and open-source RDP server which allows you to establish remote desktop sessions to Linux server from Windows or Linux host.
In this post we use **xrdp server installed in Ubuntu server 20.04 LTS Azure VM**.

image reference:
* "publisher": "canonical",
* "offer": "0001-com-ubuntu-server-focal",
* "sku": "20_04-lts",
* "version": "latest"

"vmSize": "Standard_DS1_v2"  (1 vcpus, 3.5 GiB memory)

For information about Ubuntu packages: https://packages.ubuntu.com/

## <a name="AzureDeployment"></a>1. GNOME Desktop Environment
### <a name="AzureDeployment"></a>1.1 vanilla GNOME Desktop Environment
The vanilla GNOME desktop is a pure GNOME shell with minimal installed packages and functionality. 

It is ideal for servers with minimal GUI applications requirement.

To install Vanilla GNOME shell desktop:
```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install gnome-session gnome-terminal 

apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```

[![1]][1]

### <a name="AzureDeployment"></a>1.2 Gnome Minimal Desktop Environment
it is not light as the minimal gnome-shell installation, however, contains slightly less software packages then a regular full Ubuntu desktop.
```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install tasksel 
tasksel install ubuntu-desktop-minimal

apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```

[![2]][2]

### Note
Available tasks:
```bash
root@h1:~# tasksel --list-task
u kubuntu-live  Kubuntu live CD
u lubuntu-live  Lubuntu live CD
u ubuntu-budgie-live    Ubuntu Budgie live CD
u ubuntu-live   Ubuntu live CD
u ubuntu-mate-live      Ubuntu MATE Live CD
u ubuntustudio-dvd-live Ubuntu Studio live DVD
u xubuntu-live  Xubuntu live CD
i cloud-image   Ubuntu Cloud Image (instance)
u dns-server    DNS server
u kubuntu-desktop       Kubuntu desktop
u lamp-server   LAMP server
u lubuntu-desktop       Lubuntu Desktop
u mail-server   Mail server
u postgresql-server     PostgreSQL database
i print-server  Print server
u samba-server  Samba file server
u ubuntu-budgie-desktop Ubuntu Budgie desktop
u ubuntu-desktop        Ubuntu desktop
u ubuntu-desktop-default-languages      Ubuntu desktop default languages
i ubuntu-desktop-minimal        Ubuntu minimal desktop
u ubuntu-desktop-minimal-default-languages      Ubuntu minimal desktop default languages
u ubuntu-mate-core      Ubuntu MATE minimal
u ubuntu-mate-desktop   Ubuntu MATE desktop
u ubuntustudio-audio    Audio recording and editing suite
u ubuntustudio-desktop  Ubuntu Studio desktop
u ubuntustudio-desktop-core     Ubuntu Studio minimal DE installation
u ubuntustudio-fonts    Large selection of font packages
u ubuntustudio-graphics 2D/3D creation and editing suite
u ubuntustudio-photography      Photograph touchup and editing suite
u ubuntustudio-publishing       Publishing applications
u ubuntustudio-video    Video creation and editing suite
u xubuntu-core  Xubuntu minimal installation
u xubuntu-desktop       Xubuntu desktop
i openssh-server        OpenSSH server
i server        Basic Ubuntu server
```

### <a name="AzureDeployment"></a>1.3 Full Gnome Desktop Environment

```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install tasksel 
tasksel install ubuntu-desktop
apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```

[![3]][3]

## <a name="AzureDeployment"></a>2. MATE Desktop Environment
The MATE Desktop Environment is based on GNOME 2
```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install ubuntu-mate-desktop

apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```
[![4]][4]

## <a name="AzureDeployment"></a>3. Xubuntu Desktop Environment
The below commands install the Ubuntu version of the Xfce desktop environment. 
```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install tasksel

tasksel install xubuntu-desktop
OR
tasksel install xubuntu-core

apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```
[![5]][5]

## <a name="AzureDeployment"></a>4. Kubuntu Desktop Environment
There are different versions of KDE available:
* KDE Plasma Desktop: minimal package of KDE with the Plasma desktop. To install it: **apt install plasma-desktop**
* Full KDE Desktop environment: includes Plasma desktop with standard set of KDE apps. To install it: **apt install kubuntu-desktop**
* KDE Full: It comes with the complete package and core KDE plasma desktop. To install it: **apt install kubuntu-full**

### <a name="AzureDeployment"></a>4.1 KDE Plasma Desktop Environment
If you want to install only Plasma Desktop, not the apps come along with it:

```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install plasma-desktop
apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```

List installed packages matching plasma:
```bash
dpkg --list *plasma*
```

[![6]][6]

### <a name="AzureDeployment"></a>4.2 KDE standard Desktop Environment
To install the full KDE Desktop enviroment along with KDE:
```bash
apt update
apt --assume-yes upgrade
apt --assume-yes install kubuntu-desktop
apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```

[![7]][7]

### <a name="AzureDeployment"></a>4.3 KDE full Desktop Environment
To install the full KDE Desktop enviroment along with KDE:
```bash
apt-get update
apt --assume-yes install kubuntu-full
apt --assume-yes install xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
```

[![8]][8]

<!--Image References-->
[1]: ./media/vanilla-gnome.png "vanilla gnome desktop environment"
[2]: ./media/gnome-minimal.png "gnome minimal desktop environment"
[4]: ./media/mate.png "mate desktop environment"
[5]: ./media/xubuntu.png "xubuntu desktop environment"

<!--Link References-->

