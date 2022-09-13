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

# Update Ubuntu and install all necessary binaries
time sudo apt-get -y update

sleep 5
time sudo DEBIAN_FRONTEND=noninteractive apt-get -y --allow install ubuntu-desktop-minimal 
time sudo apt-get install -y xrdp

sed -i "s/allowed_users=console/allowed_users=anybody/" /etc/X11/Xwrapper.config
/etc/init.d/xrdp restart


# Ubuntu uses a software component called Polkit, which is an application authorization framework that captures actions performed 
# by a user to check if the user is authorized to perform certain actions.
# When you connect to Ubuntu remotely using RDP / Windows Remote Desktop, you will see the above errors because the Polkit Policy file 
# cannot be accessed without superuser authentication.

cat <<EOF > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

#install VSCode
logger -t devvm "Installing VSCode: $?"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get update
sudo apt-get install -y code
logger -t devvm "VSCode Installed: $?"
logger -t devvm "Success"


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
time wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
time sudo dpkg -i google-chrome-stable_current_amd64.deb
time sudo apt-get -y --allow install install -f
time rm /tmp/google-chrome-stable_current_amd64.deb

date
reboot
exit 0