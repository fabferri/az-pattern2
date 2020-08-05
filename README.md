<properties
pageTitle= 'How to configure Remote Desktop to connect to a CentOS 8 VM in Azure'
description= "How to configure Remote Desktop to connect to a CentOS 8 VM in Azure"
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
   ms.date="05/08/2020"
   ms.author="fabferri" />

## How to configure Remote Desktop to connect to a CentOS 8 Azure VM 
When a CentOS-based is created from Azure marketplace, the VM image bootstraps with minimal installation and does not have a desktop environment installed. Azure Linux VMs are commonly managed using SSH connections rather than a desktop environment. The post walks you through the steps to activate the remote desktop to the CentOS Azure VM.

There are few Remote Desktop Protocol (RDP) servers to connect to with remote desktop to linux host/VM.
* xrdp is a free and open-source RDP server which allows you to establish remote desktop sessions to Linux server from Windows or Linux host.
* [freeRDP](https://www.freerdp.com/) 

In this post we use xrdp server installed in CentOS 8.2 Azure VM:

image reference:
* "publisher": "OpenLogic",
* "offer": "CentOS",
* "sku": "8_2",
* "version": "latest"

"vmSize": "Standard_DS1_v2"  (1 vcpus, 3.5 GiB memory)


## <a name="AzureDeployment"></a>1. Installation of desktop environment in CentOS 8 Azure VM
Check the availability of the package groups:

```bash
[root@h1 ~]# dnf group list
```
[![1]][1]

There are two groups of packages to enable the desktop environments: "Workstation", "Server with GUI"

```console
[root@h1 ~]# dnf group info workstation
Environment Group: Workstation
 Description: Workstation is a user-friendly desktop system for laptops and PCs.
 Mandatory Groups:
   Common NetworkManager submodules
   Core
   Fonts
   GNOME
   Guest Desktop Agents
   Hardware Support
   Internet Browser
   Multimedia
   Printing Client
   Standard
   Workstation product core
   base-x
 Optional Groups:
   Backup Client
   GNOME Applications
   Headless Management
   Internet Applications
   Office Suite and Productivity
   Remote Desktop Clients
   Smart Card Support
```

```console
[root@h1 ~]# dnf group info "Server with GUI"
Environment Group: Server with GUI
 Description: An integrated, easy-to-manage server with a graphical interface.
no group 'dns-server' from environment 'graphical-server-environment'
 Mandatory Groups:
   Common NetworkManager submodules
   Container Management
   Core
   Fonts
   GNOME
   Guest Desktop Agents
   Hardware Monitoring Utilities
   Hardware Support
   Headless Management
   Internet Browser
   Multimedia
   Printing Client
   Server product core
   Standard
   base-x
 Optional Groups:
   Basic Web Server
   Debugging Tools
   FTP Server
   File and Storage Server
   Guest Agents
   Infiniband Support
   Mail Server
   Network File System Client
   Network Servers
   Performance Tools
   Remote Desktop Clients
   Remote Management for Linux
   Virtualization Client
   Virtualization Hypervisor
   Virtualization Tools
   Windows File Server
```

Let's install the group "Server with GUI"
```bash
[root@h1 ~]# dnf -y groupinstall "Server with GUI"
```

## <a name="AzureDeployment"></a>2. Install xrdp package in CentOS 8
xrdp package is available on EPEL repository. To enable the EPEL repository:
```bash
[root@h1 ~]# dnf -y install epel-release
```

Install xrdp:
```bash
[root@h1 ~]# dnf -y install xrdp
```

To start automatically the xrdp server service at system startup:
```bash
[root@h1 ~]# systemctl enable xrdp
```

Start the xrdp server service:
```bash
[root@h1 ~]# systemctl start xrdp
```
Check the status of xrdp:

```bash 
[root@h1 ~]# systemctl --no-pager status xrdp
● xrdp.service - xrdp daemon
   Loaded: loaded (/usr/lib/systemd/system/xrdp.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-08-05 09:33:58 UTC; 12s ago
     Docs: man:xrdp(8)
           man:xrdp.ini(5)
 Main PID: 43474 (xrdp)
    Tasks: 1 (limit: 21612)
   Memory: 1.3M
   CGroup: /system.slice/xrdp.service
           └─43474 /usr/sbin/xrdp --nodaemon

Aug 05 09:33:58 h1 systemd[1]: Started xrdp daemon.
Aug 05 09:33:58 h1 xrdp[43474]: (43474)(140001602598336)[INFO ] starting xrdp with pid 43474
Aug 05 09:33:58 h1 xrdp[43474]: (43474)(140001602598336)[INFO ] address [0.0.0.0] port [3389] mode 1
Aug 05 09:33:58 h1 xrdp[43474]: (43474)(140001602598336)[INFO ] listening to port 3389 on 0.0.0.0
Aug 05 09:33:58 h1 xrdp[43474]: (43474)(140001602598336)[INFO ] xrdp_listen_pp done

```
Check that xrdp listen on the RDP port 3389:
```bash 
[root@h1 ~]# netstat -plnt | grep rdp
tcp        0      0 127.0.0.1:3350          0.0.0.0:*               LISTEN      43473/xrdp-sesman
tcp        0      0 0.0.0.0:3389            0.0.0.0:*               LISTEN      43474/xrdp
```

The xrdp configuration files are located in the **/etc/xrdp** directory.  Xrdp uses the default X Window desktop, which in this case, is Gnome. Open up configuration file **/etc/xrdp/xrdp.ini** and add the following line at the end of the file:
```console
exec gnome-session
```
Restart the daemon:
```bash
[root@h1 ~]# systemctl restart xrdp
```

The CentOS Azure VM does not have by default the firewall active; you can verify it by command:
```bash
[root@h1 ~]# systemctl status firewalld
```

if you have enabled the firewall, you have to create the rule to accept incoming connection on TCP port 3389:
```bash
firewall-cmd --add-port=3389/tcp --permanent
firewall-cmd –reload
```

### NOTE **xrdp cannot accept SSH keys for authentication**
* If you created the Azure CentOS VM to login with  username and password, you _do not need_ to create a new username to the access to the VM.
* If you created the Azure CentOS VM only use SSH key authentication and do not have a local account password you need to create a new account with username and password to connect in RDP.
```bash
[root@h1 ~]# useradd user1xrdp
[root@h1 ~]# passwd user1xrdp
```

## <a name="AzureDeployment"></a>3. Add a rule to the NSG to allow inbound connection on RDP port
When you deploy an Azure VM through Azure management portal, a Network Security Group (NSG) is applied to the NIC of the VM, with only inbound SSH connections are allowed. To get remote access to the CentOS VM via RDP, you need to add to the NSG an inbound security rule to allow connection on port 3389.

[![2]][2]

## <a name="AzureDeployment"></a>4. Connect to the VM via RDP
Connect to the VM via RDP
[![3]][3]

Inside the RDP session, the xrdp server asks for username and password to access to the CentOS VM:
[![4]][4]

the Gnome desktop is available inside the RDP session:
[![5]][5]

## <a name="AzureDeployment"></a>5. Install Visual Studio code in Azure CentOS VM
### <a name="AzureDeployment"></a>5.1 Import Microsoft GPG key
```bash
[root@h1 ~]# rpm --import https://packages.microsoft.com/keys/microsoft.asc
```
### <a name="AzureDeployment"></a>5.2 Add Visual Studio code repository
Add to the file: **/etc/yum.repos.d/vscode.repo** the following line:
```console
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
```
it can be achieved by command:
```bash
[root@h1 ~]# tee /etc/yum.repos.d/vscode.repo <<ENDOFCONTENT
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
ENDOFCONTENT
```
### <a name="AzureDeployment"></a>5.3 Install Visual Studio Code on Azure CentOS 8 
```bash
[root@h1 ~]# dnf install code
```

verify the information regarding installed package:
```bash
[root@h1 ~]# rpm -qi code
Name        : code
Version     : 1.47.3
Release     : 1595520197.el7
Architecture: x86_64
Install Date: Wed 05 Aug 2020 11:29:33 AM UTC
Group       : Development/Tools
Size        : 268608838
License     : Multiple, see https://code.visualstudio.com/license
Signature   : RSA/SHA256, Thu 23 Jul 2020 04:04:42 PM UTC, Key ID eb3e94adbe1229cf
Source RPM  : code-1.47.3-1595520197.el7.src.rpm
Build Date  : Thu 23 Jul 2020 04:03:37 PM UTC
Build Host  : bc051b588560
Relocations : (not relocatable)
Packager    : Visual Studio Code Team <vscode-linux@microsoft.com>
Vendor      : Microsoft Corporation
URL         : https://code.visualstudio.com/
Summary     : Code editing. Redefined.
Description :
Visual Studio Code is a new choice of tool that combines the simplicity of a code editor with what developers need for the core edit-build-debug cycle. See https://code.visualstudio.com/docs/setup/linux for installation instructions and FAQ.
```
### <a name="AzureDeployment"></a>5.4 Launch Visual Studio Code
In Gnome search function find the VS code and click-on it:
[![6]][6]


[![7]][7]

## <a name="AzureDeployment"></a>6. Create a .NET Core console application
### <a name="AzureDeployment"></a>6.1 install the C# extension
[![8]][8]

### <a name="AzureDeployment"></a>6.2 install the .NET Core SDK on CentOS 8
.NET Core 3.1 SDK is available in the default package repositories for CentOS 8.
```bash
[root@h1 ~]# dnf install dotnet-sdk-3.1
```
If you've already installed the SDK, you do not need to install the runtime
to check the installation:
```bash
[root@h1 ~]# dotnet --list-sdks
3.1.105 [/usr/lib64/dotnet/sdk]

[root@h1 ~]# dotnet --list-runtimes
Microsoft.AspNetCore.App 3.1.5 [/usr/lib64/dotnet/shared/Microsoft.AspNetCore.App]
Microsoft.NETCore.App 3.1.5 [/usr/lib64/dotnet/shared/Microsoft.NETCore.App]
``` 
### <a name="AzureDeployment"></a>6.3 Create adn run a simple C# console application
In the Visual Studio terminal:
```bash
dotnet new console
dotnet restore
dotnet run
```

[![9]][9]

## <a name="AzureDeployment"></a>7. Installing SQL server on CentOS 8 VM
### <a name="AzureDeployment"></a>7.1 Configure repositories for installing SQL Server on Linux

```bash
[root@h1 ~]# curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/8/mssql-server-2019.repo
```
Check the downloaded file:
```bash
[root@h1 ~]# cat /etc/yum.repos.d/mssql-server.repo
[packages-microsoft-com-mssql-server-2019]
name=packages-microsoft-com-mssql-server-2019
baseurl=https://packages.microsoft.com/rhel/8/mssql-server-2019/
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
```
### <a name="AzureDeployment"></a>7.2 installing SQL Server package
```bash
[root@h1 ~]# dnf install mssql-server
```
The installation preinstall python2, which is required by SQL Server.

### <a name="AzureDeployment"></a>7.3 run SQL Server installation
After the package installation finishes, run mssql-conf setup:
```bash
[root@h1 ~]# /opt/mssql/bin/mssql-conf setup
```
the installation asks for the SQL edition, SQL Server system administrator password.

Verify that the service is running:
```bash
[root@h1 ~]# systemctl status mssql-server
● mssql-server.service - Microsoft SQL Server Database Engine
   Loaded: loaded (/usr/lib/systemd/system/mssql-server.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-08-05 19:44:17 UTC; 7min ago
     Docs: https://docs.microsoft.com/en-us/sql/linux
 Main PID: 61352 (sqlservr)
    Tasks: 133
   Memory: 821.1M
   CGroup: /system.slice/mssql-server.service
           ├─61352 /opt/mssql/bin/sqlservr
           └─61389 /opt/mssql/bin/sqlservr

Aug 05 19:44:33 h1 sqlservr[61352]: [145B blob data]
Aug 05 19:44:33 h1 sqlservr[61352]: [158B blob data]
Aug 05 19:44:34 h1 sqlservr[61352]: [155B blob data]
Aug 05 19:44:34 h1 sqlservr[61352]: [61B blob data]
Aug 05 19:44:35 h1 sqlservr[61352]: [96B blob data]
Aug 05 19:44:35 h1 sqlservr[61352]: [66B blob data]
Aug 05 19:44:35 h1 sqlservr[61352]: [96B blob data]
Aug 05 19:44:35 h1 sqlservr[61352]: [100B blob data]
Aug 05 19:44:35 h1 sqlservr[61352]: [71B blob data]
Aug 05 19:44:35 h1 sqlservr[61352]: [124B blob data]
```

if firewall is active, to allow remote connections, open the SQL Server port:
```bash
[root@h1 ~]# firewall-cmd --zone=public --add-port=1433/tcp --permanent
[root@h1 ~]# firewall-cmd --reload
```
SQL Server 2019 is running on CentOS 8 VM and is ready to use.


### <a name="AzureDeployment"></a>7.4 install SQL Server command-line tools: sqlcmd and bcp

Download the Microsoft Red Hat repository configuration file:
```bash
[root@h1 ~]# curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/8/prod.repo

[root@h1 ~]# cat /etc/yum.repos.d/msprod.repo
[packages-microsoft-com-prod]
name=packages-microsoft-com-prod
baseurl=https://packages.microsoft.com/rhel/8/prod/
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
```
Install the unixODBC packages:
```bash
[root@h1 ~]# dnf install -y mssql-tools unixODBC-devel
```

Add **/opt/mssql-tools/bin/** to your **PATH** environment variable. Run the following commands to modify the PATH for both login sessions and interactive/non-login sessions: 
```bash
[root@h1 ~]# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
[root@h1 ~]# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
[root@h1 ~]# source ~/.bashrc
```
use sqlcmd to locally connect to your new SQL Server instance"
```bash
[root@h1 ~]# sqlcmd -S localhost -U SA -P '<YourPassword>'
```
If successful, you should get to a sqlcmd command prompt: 1>

Create a DB, create a table and insert a record:
```console
1> CREATE DATABASE TestDB
2> SELECT Name from sys.Databases
3> GO
Name
--------------------------------------------------------------------------------------------------------------------------------
master
tempdb
model
msdb
TestDB

(5 rows affected)
1>
1> USE TestDB
2> CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT)
3> INSERT INTO Inventory VALUES (1, 'banana', 150); INSERT INTO Inventory VALUES (2, 'orange', 154);
4> GO
Changed database context to 'TestDB'.

(1 rows affected)

(1 rows affected)

1> SELECT * FROM Inventory WHERE quantity > 152;
2> GO
id          name                                               quantity
----------- -------------------------------------------------- -----------
          2 orange                                                     154

(1 rows affected)
```
<!--Image References-->
[1]: ./media/group.png  "group of packages"
[2]: ./media/nsg.png  "network security group to connect via RDP"
[3]: ./media/login1.png "login to CentOS via RDP"
[4]: ./media/login2.png "login to CentOS via RDP"
[5]: ./media/login3.png "login to CentOS via RDP"
[6]: ./media/vs-code1.png "Visual Studio Code"
[7]: ./media/vs-code2.png "Visual Studio Code"
[8]: ./media/vs-code3.png "install the C# extension in Visual Studio Code"
[9]: ./media/vs-code4.png "run C# app"
<!--Link References-->

