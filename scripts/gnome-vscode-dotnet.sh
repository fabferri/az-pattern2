#!/bin/bash

# print commands and arguments as they are executed
set -x

# If the return code of one command is not 0 and the caller does not check it, the shell script will exit.
#set -e

if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this script." >&2
    exit 3
fi

# eliminate debconf warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update Ubuntu and install all necessary binaries
time sudo apt-get -y update

sudo apt-get  -y upgrade

sleep 5
time sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ubuntu-desktop-minimal 
time sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xrdp

sudo systemctl enable xrdp.service

# changed the allowed_users
sed -i "s/allowed_users=console/allowed_users=anybody/" /etc/X11/Xwrapper.config
/etc/init.d/xrdp restart


# Ubuntu uses a software component called Polkit, which is an application authorization framework that captures actions performed 
# by a user to check if the user is authorized to perform certain actions.
# When you connect to Ubuntu remotely using RDP / Windows Remote Desktop, you will see the above errors because the Polkit Policy file 
# cannot be accessed without superuser authentication.
# Configure the policy xrdp session
cat <<EOF > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# install VSCode
# logger add log files to /var/log/syslog — from the command line and  scripts. the command "logger --tag" : mark every line with tag
logger --tag devvm "Installing VSCode: $?"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y code
logger --tag devvm "VSCode Installed: $?"
logger --tag devvm "Success"


# Update Ubuntu and install all necessary binaries
#time sudo apt-get -y update

# scripted install dotnet SDK
# The script defaults to installing the latest SDK long term support (LTS) version
wget -P /tmp https://dot.net/v1/dotnet-install.sh  
sudo chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --install-dir /usr/share/dotnet/sdk
touch /etc/profile.d/dotnet.sh
echo 'export DOTNET_ROOT=/usr/share/dotnet/sdk' >> /etc/profile.d/dotnet.sh
echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' >> /etc/profile.d/dotnet.sh
rm -f /tmp/dotnet-install.sh

# Setup Chrome
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
time sudo dpkg -i google-chrome-stable_current_amd64.deb
# enable the "Universe" repository
#sudo add-apt-repository universe
#sudo apt-get install libgconf2-4 libnss3-1d libxss1

# google-chrome-stable depends on fonts-liberation; "sudo apt-get install -f" will install missing dependencies 
time sudo apt-get -y install -f
time rm /tmp/google-chrome-stable_current_amd64.deb

date
sudo reboot
exit 0