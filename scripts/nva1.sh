#!/bin/bash
#
sleep 1m
sudo apt-get -y update
# sudo apt upgrade
### install and start nginx
sudo apt-get -y install nginx 
sudo systemctl enable nginx 
sudo systemctl start nginx
### change the homepage of nginx
echo '<style> h1 { color: blue; } </style> <h1>' > /var/www/html/index.nginx-debian.html
cat /etc/hostname >> /var/www/html/index.nginx-debian.html
echo ' </h1>' >> /var/www/html/index.nginx-debian.html
sed -i '/^#/! s/listen 80/listen 8080/g'  /etc/nginx/sites-enabled/default
sed -i '/^#/! s/listen \[::]:80/listen \[::]:8080/g' /etc/nginx/sites-enabled/default
systemctl restart nginx
#
### enable IP forwarding
sudo sed -i -e '$a\net.ipv4.ip_forward = 1' /etc/sysctl.conf
#
#
tunnel_internal_port=$1
tunnel_internal_vni=$2
tunnel_external_port=$3
tunnel_external_vni=$4
nva_lb_ip=$5
#
# create a file to setup the VXLAN tunnels
cat > /usr/local/bin/nvavnisetup.sh <<EOF
tunnel_internal_port=$tunnel_internal_port
tunnel_internal_vni=$tunnel_internal_vni
tunnel_external_port=$tunnel_external_port
tunnel_external_vni=$tunnel_external_vni
nva_lb_ip=$nva_lb_ip

#internal tunnel
ip link add name vxlan\${tunnel_internal_vni} type vxlan id \${tunnel_internal_vni} remote \${nva_lb_ip} dstport \${tunnel_internal_port}
ip link set vxlan\${tunnel_internal_vni} up

#external tunnel
ip link add name vxlan\${tunnel_external_vni} type vxlan id \${tunnel_external_vni} remote \${nva_lb_ip} dstport \${tunnel_external_port}
ip link set vxlan\${tunnel_external_vni} up

# bridge both VXLAN interfaces together (works arounding routing between them)
ip link add br-tunnel type bridge
ip link set vxlan\${tunnel_internal_vni} master br-tunnel
ip link set vxlan\${tunnel_external_vni} master br-tunnel
ip link set br-tunnel up
EOF

# create a file to start the VXLAN tunnels as service
cat > /etc/systemd/system/nvavxlan.service <<EOF
[Unit]
Description=vni service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /usr/local/bin/nvavnisetup.sh

[Install]
WantedBy=multi-user.target
EOF
sudo chmod 744 /usr/local/bin/nvavnisetup.sh
sudo chmod 664 /etc/systemd/system/nvavxlan.service
sudo systemctl start nvavxlan.service
sudo systemctl enable nvavxlan.service
exit 0


