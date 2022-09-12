
#!/bin/bash

# exit on any error
set -e

if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this script." >&2
    exit 3
fi

echo "Checking for apache2 already installed"
if dpkg -s apache2 > /dev/null 2>&1; then
     echo "Apache2 installed already - exiting"
     exit
else
     echo "Apache2 not installed - proceeding"
fi

# install needed bits in a loop because a lot of installs happen
# on VM init, so won't be able to grab the dpkg lock immediately
until apt-get -y update && apt-get -y install apache2
do
  echo "Trying again"
  sleep 5
done

# To enable the service to start up at boot
sudo systemctl enable apache2
exit 0

