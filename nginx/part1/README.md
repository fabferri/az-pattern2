<properties
pageTitle= 'How to setup NGINX server blocks'
description= "How to create a NGINX server block configuration to host multiple website on a single host"
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
   ms.date="14/10/2020"
   ms.author="fabferri" />



# <a name="AzureDeployment"></a> How to setup NGINX server blocks
<ins>Server Blocks</ins> is NGINX feature that allows to host multiple websites in one host. 

The article walks you through the steps to get NGINX server blocks running in Azure VM. 
For demonstration purposes we are going to set up two domains, test10.com and test11.com, with our NGINX server running in Azure Ubuntu VM.
Domains are isolated and independent, each having a separate directory.

Azure VM image:
* "publisher": "canonical",
* "offer": "0001-com-ubuntu-server-focal",
* "sku": "20_04-lts",
* "version": "latest"

"vmSize": "Standard_B1s"  (1 vCPU, 1 GiB memory)

## <a name="AzureDeployment"></a>1. Install NGINX in Ubuntu Azure VM
Update the local package index so that we have access to the most recent package listings and then install and start NGINX:

```bash
sudo apt update
sudo apt -y install nginx
sudo systemctl start nginx
```
We can check with the nginx service is running by typing:
```bash
systemctl status nginx
```
To enable the nginx service at system boot:
```bash
sudo systemctl enable nginx
```
List the application configurations that ufw knows:
```
sudo ufw app list
```
Check the status of the firewall:

```bash
 ufw status
```
if ufw is inactive does not require to allow HTTP ports.
if ufw is active, you need to add the HTTP custom ports:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5000/tcp
sudo ufw reload
```

## <a name="AzureDeployment"></a>2. NGINX Files and Directories

* **/var/www/html**: the actual web content
* **/etc/nginx**: the NGINX configuration directory
* **/etc/nginx/nginx.conf**: All NGINX configuration files are in the **/etc/nginx/** directory. The primary configuration file is **/etc/nginx/nginx.conf**
* **/etc/nginx/sites-available/**: The directory to store the per-site server blocks.
* **/var/log/nginx/access.log**: log file
* **/var/log/nginx/error.log**: any NGINX errors are written in this file

Configuration options in NGINX are called directives. Directives are organized into groups known as blocks or contexts.


## <a name="NGINX_Directory"></a>3. Create Directory Structure
"Virtual Host" is an Apache term. NGINX does not have Virtual hosts, it has **server blocks** to host multiple websites on one server 
**server blocks** use the server_name and listen directives to bind to TCP sockets.
By default, NGINX has one server block enabled by default. It is configured to serve documents out of a directory at **/var/www/html**
To serve multiple sites, we need additional directories.
We can consider the **/var/www/html** directory the default directory that will be served if the client request doesn’t match any of our other sites. 
For each of our sites, we will create an individual directory structure within **/var/www**
The actual web content will be placed in an **html** directory within these site-specific directories
Let's create these directories for each of our sites:

```bash
sudo mkdir -p /var/www/test10/html
sudo mkdir -p /var/www/test11/html
```
Grant reading permission to all the files inside the /var/www directory of your web roots:
```bash
sudo chmod -R 755 /var/www
```

we will reassign ownership of the web directories to NGINX user (www-data):
```bash
sudo chown -R www-data:www-data /var/www/test10/html
sudo chown -R www-data:www-data /var/www/test11/html
```

## <a name="NGINX_defaultpage"></a>4. Create a default page for Virtual Host
Let's create a default page for each of our sites so that we will have something to display.
Create an index.html file in your first site:
```bash
vi /var/www/test10/html/index.html
```
Inside the file index.html:
```html
<html>
    <head>
        <title>Welcome to test10!</title>
    </head>
    <body>
        <h1>Success!  The test10 server block is working!</h1>
    </body>
</html>
```
Repeat the process for the second web site:
```bash
vi /var/www/test11/html/index.html
```
inside this last index.html
```html
<html>
    <head>
        <title>Welcome to test11!</title>
    </head>
    <body>
        <h1>Success!  The test11 server block is working!</h1>
    </body>
</html>
```
## <a name="NGINX_serverblockes"></a>5. Set Up Environment for Server Block Files
After installation of the NGINX package from the Ubuntu repositories, you will have two directories:
* **sites-available** directory to store the server blocks in. The sites-available folder is for storing all your vhost configurations, whether or not they're currently enabled. In other words, as the name says the content of this folder give you the list of all available sites. 
* **sites-enabled** directory that will tell NGINX which links to publish, and which blocks share content with visitors. The sites-enabled folder contains symlinks to files in the sites-available folder. This allows you to <ins>selectively *disable* vhosts by removing the symlink</ins>. As the name says, the folder gives you the list of all enabled sites.

NGINX server blocks configuration files are stored in **/etc/nginx/sites-available** directory, which are enabled through symbolic links to the **/etc/nginx/sites-enabled/** directory.
You should edit files only in **sites-available** directory.

> **NOTE**: 
>
> Do never edit files inside the **sites-enabled** directory, otherwise you might have problems if your editor runs out of memory or, for any reason, it receives a SIGHUP or SIGTERM. Let discuss why you might have an issue. If you are using nano to edit the file **sites-enabled/default** and it runs out of memory or, for any reason, it receives a SIGHUP or SIGTERM, then nano will create an emergency file called default.save, inside the sites-enabled directory. So, there will be an extra file inside the sites-enabled directory. That will prevent NGINX to start. If your site was working, it will not be any more till you remove the default.save file.


In the main NGINX configuration file, **/etc/nginx/nginx.conf**, you have the following lines:
```console
...
    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
...
```
The line **include /etc/nginx/sites-enabled/*.conf;** (inside **/etc/nginx/nginx.conf**)  instructs NGINX to check the **sites-enabled** directory.

To increase the memory reserved for multiple vhosts, add to the NGINX configuration file **/etc/nginx/nginx.conf** the following line:

```console
server_names_hash_bucket_size 64;
```

By default, NGINX contains one server block called **default**.
we need to look at the listen directives. Only one of our server blocks on the server can have the **default_server** option enabled. This specifies which block should serve a request if the server_name requested does not match any of the available server blocks.



Create the server blocks for the site test10, by copying over the default server block:
```bash
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/test10.conf
```
Open the new file you created in your text editor with sudo privileges:
```bash
sudo vi /etc/nginx/sites-available/test10.conf
```

```console
server {
        listen 80;
        listen [::]:80;
        server_name  test10.com

        root /var/www/test10/html;
        index index.html index.htm;
        location / {
                try_files $uri $uri/ =404;
        }
        access_log /var/log/nginx/test10/access.log;
	    error_log /var/log/nginx/test10/error.log;
}
```
Server configuration files contain a server block.

The **listen** directive tells NGINX the hostname/IP and the TCP port where it should listen for HTTP connection.

The **server_name** directive allows multiple domains to be served from a single IP address. The server decides which domain to serve based on the request header it receives. NGINX allows you to specify server names that are not valid domain names. NGINX uses the name from the HTTP header to answer requests, regardless of whether the domain name is valid or not.

The **root** directive specifies the root directory that will be used to search for a file. To obtain the path of a requested file, NGINX appends the request URI to the path specified by the root directive. in the specific case above, NGINX searches for a URI that starts with / in the **/var/www/test10/html** directory in the file system.

The **location** setting is another variable that has its own block.
Once NGINX has determined which location directive best matches a given request, the response to this request is determined by the contents of the associated location directive block.
In the example above, the document **root** is in the **/var/www/test10/html** directory. Under the default installation prefix for NGINX, the full path to this location is **/etc/nginx/html/**

The **index** variable tells NGINX which file to serve if none is specified.
If multiple files are specified for the **index** directive, NGINX will process the list in order and fulfil the request with the first file that exists. If index.html doesn't exist in the relevant directory, then index.htm will be used. If neither exists, a 404 message will be sent.

Create the second server block:
```bash
sudo cp /etc/nginx/sites-available/test10.conf /etc/nginx/sites-available/test11.conf
sudo vi /etc/nginx/sites-available/test11.conf
```

```console
server {
        listen 80;
        listen [::]:80;
        server_name  test11.com

        root /var/www/test11/html;
        index index.html index.htm;
        location / {
                try_files $uri $uri/ =404;
        }
        access_log /var/log/nginx/test11/access.log;
	    error_log /var/log/nginx/test11/error.log;
}
```
We need to enable the new server block files, by creating symbolic links from these files to the sites-enabled directory, which Nginx reads from during startup.
```bash
sudo ln -s /etc/nginx/sites-available/test10.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/test11.conf /etc/nginx/sites-enabled/
```

Create the folders for the logs:
```bash
sudo mkdir -p /var/log/nginx/test10/
sudo mkdir -p /var/log/nginx/test11/
sudo chown -R www-data:adm /var/log/nginx/test10/
sudo chown -R www-data:adm /var/log/nginx/test11/
```
Group **adm** is used for system monitoring tasks. Members of this group can read many log files in /var/log

To make sure that there are no syntax errors in any of your NGINX files:
```bash
sudo nginx -t
```

If no problems were found, restart Nginx to enable your changes:
```bash
sudo systemctl restart nginx
```

 If you have multiple virtual hosts listening on multiple ports, execute:
 ```bash
 apt install net-tools
 netstat -tulpn | grep nginx 
 ```
 to get a list of ports that NGINX is already using on the server. 


If you have not been using domain names that you own and instead have been using dummy values, you can modify your local computer’s configuration to let you to temporarily test your NGINX server block configuration:
```bash
sudo vi /etc/hosts
```
Assuming the Azure VM has private IP address 203.0.113.5:
```
10.0.1.10 test10.com
10.0.1.10 test11.com
```
These entries will translate any requests for test10.com and test11.com

```console
root@vm1:~# curl test10.com
<html>
    <head>
        <title>Welcome to test10!</title>
    </head>
    <body>
        <h1>Success!  The test10 server block is working!</h1>
    </body>
</html>

root@vm1:~# curl test11.com
<html>
    <head>
        <title>Welcome to test11!</title>
    </head>
    <body>
        <h1>Success!  The test11 server block is working!</h1>
    </body>
</html>
root@vm1:~#

```
## <a name="NGINX_changeport"></a>6. Change the ports for the server blockes
In  /etc/nginx/sites-available/test10.conf
```console
server {
        listen 8080;
        listen [::]:8080;
        server_name  test10.com

        root /var/www/test10/html;
        index index.html index.htm;
        location / {
                try_files $uri $uri/ =404;
        }
        access_log /var/log/nginx/test10/access.log;
	    error_log /var/log/nginx/test10/error.log;
}
```
In  /etc/nginx/sites-available/test11.conf
```console
server {
        listen 8081;
        listen [::]:8081;
        server_name  test11.com

        root /var/www/test11/html;
        index index.html index.htm;
        location / {
                try_files $uri $uri/ =404;
        }
        access_log /var/log/nginx/test11/access.log;
	    error_log /var/log/nginx/test11/error.log;
}
```

Restart NGINX:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

To trace the packets from internet:
```console
tcpdump host <IP-addres-remote-client> and port 80
tcpdump host <IP-addres-remote-client> and port 8080
tcpdump host <IP-addres-remote-client> and port 8081
````

```
root@vm1:~# tcpdump -nq -tttt host X.Y.Z.218 and port 80
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
2020-10-14 15:15:26.719399 IP X.Y.Z.218.50454 > 10.0.1.10.80: tcp 0
2020-10-14 15:15:26.719445 IP 10.0.1.10.80 > X.Y.Z.218.50454: tcp 0
2020-10-14 15:15:26.719559 IP X.Y.Z.218.50453 > 10.0.1.10.80: tcp 0
2020-10-14 15:15:26.719567 IP 10.0.1.10.80 > X.Y.Z.218.50453: tcp 0
2020-10-14 15:15:26.722147 IP X.Y.Z.218.56655 > 10.0.1.10.80: tcp 0
2020-10-14 15:15:26.722171 IP 10.0.1.10.80 > X.Y.Z.218.56655: tcp 0
2020-10-14 15:15:26.723574 IP X.Y.Z.218.56656 > 10.0.1.10.80: tcp 0
2020-10-14 15:15:26.723594 IP 10.0.1.10.80 > X.Y.Z.218.56656: tcp 0
2020-10-14 15:15:26.804033 IP X.Y.Z.218.56655 > 10.0.1.10.80: tcp 0
2020-10-14 15:15:26.804616 IP X.Y.Z.218.56655 > 10.0.1.10.80: tcp 544
2020-10-14 15:15:26.804629 IP 10.0.1.10.80 > X.Y.Z.218.56655: tcp 0
2020-10-14 15:15:26.804716 IP 10.0.1.10.80 > X.Y.Z.218.56655: tcp 189
2020-10-14 15:15:26.805092 IP X.Y.Z.218.56656 > 10.0.1.10.80: tcp 0
2020-10-14 15:15:26.933287 IP X.Y.Z.218.56655 > 10.0.1.10.80: tcp 0

root@vm1:~# tcpdump -nq -tttt host X.Y.Z.218 and port 8080
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
2020-10-14 15:18:08.779147 IP X.Y.Z.218.56676 > 10.0.1.10.8080: tcp 0
2020-10-14 15:18:08.779197 IP 10.0.1.10.8080 > X.Y.Z.218.56676: tcp 0
2020-10-14 15:18:08.779907 IP X.Y.Z.218.56677 > 10.0.1.10.8080: tcp 0
2020-10-14 15:18:08.779927 IP 10.0.1.10.8080 > X.Y.Z.218.56677: tcp 0
2020-10-14 15:18:08.861524 IP X.Y.Z.218.56676 > 10.0.1.10.8080: tcp 0
2020-10-14 15:18:08.862834 IP X.Y.Z.218.56676 > 10.0.1.10.8080: tcp 522
2020-10-14 15:18:08.862848 IP 10.0.1.10.8080 > X.Y.Z.218.56676: tcp 0
2020-10-14 15:18:08.862926 IP 10.0.1.10.8080 > X.Y.Z.218.56676: tcp 188
2020-10-14 15:18:08.863165 IP X.Y.Z.218.56677 > 10.0.1.10.8080: tcp 0
2020-10-14 15:18:08.985324 IP X.Y.Z.218.56676 > 10.0.1.10.8080: tcp 0

root@vm1:~# tcpdump -nq -tttt host X.Y.Z.218 and port 8081
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
2020-10-14 15:18:39.698609 IP X.Y.Z.218.56682 > 10.0.1.10.8081: tcp 0
2020-10-14 15:18:39.698663 IP 10.0.1.10.8081 > X.Y.Z.218.56682: tcp 0
2020-10-14 15:18:39.698985 IP X.Y.Z.218.56681 > 10.0.1.10.8081: tcp 0
2020-10-14 15:18:39.699003 IP 10.0.1.10.8081 > X.Y.Z.218.56681: tcp 0
2020-10-14 15:18:39.780799 IP X.Y.Z.218.56682 > 10.0.1.10.8081: tcp 0
2020-10-14 15:18:39.780961 IP X.Y.Z.218.56681 > 10.0.1.10.8081: tcp 0
2020-10-14 15:18:39.781355 IP X.Y.Z.218.56682 > 10.0.1.10.8081: tcp 522
2020-10-14 15:18:39.781383 IP 10.0.1.10.8081 > X.Y.Z.218.56682: tcp 0
2020-10-14 15:18:39.781473 IP 10.0.1.10.8081 > X.Y.Z.218.56682: tcp 188
2020-10-14 15:18:39.912786 IP X.Y.Z.218.56682 > 10.0.1.10.8081: tcp 0


X.Y.Z.218: public IP of http client in internet
```


<!--Image References-->

<!--Link References-->

