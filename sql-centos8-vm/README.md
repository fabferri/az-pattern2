<properties
pageTitle= 'How to install SQL server on Azure CentOS 8 VM'
description= "Installing SQL server on Azure CentOS 8 VM"
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



## <a name="AzureDeployment"></a> Installing SQL server on CentOS 8 VM
This post walks you through the steps to install server installed in CentOS 8.2 Azure VM.

image reference:
* "publisher": "OpenLogic",
* "offer": "CentOS",
* "sku": "8_2",
* "version": "latest"

"vmSize": "Standard_DS1_v2"  (1 vcpus, 3.5 GiB memory)

### <a name="AzureDeployment"></a>1. Configure repositories for installing SQL Server on Linux

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
### <a name="AzureDeployment"></a>2. installing SQL Server package
```bash
[root@h1 ~]# dnf install mssql-server
```
The installation preinstall python2, which is required by SQL Server.

### <a name="AzureDeployment"></a>3. run SQL Server installation
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


### <a name="AzureDeployment"></a>4. install SQL Server command-line tools: sqlcmd and bcp

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

<!--Link References-->

