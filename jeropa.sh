#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
  
.___________. _______ .___________.    ___           _______.
|           ||   ____||           |   /   \         /       |
`---|  |----`|  |__   `---|  |----`  /  ^  \       |   (----`
    |  |     |   __|      |  |      /  /_\  \       \   \    
    |  |     |  |____     |  |     /  _____  \  .----)   |   
    |__|     |_______|    |__|    /__/     \__\ |_______/    
                                                             
EOF
}
header_info
echo -e "Loading..."
APP="Suwasca"
var_disk="10"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="yes"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="yes"
  VERB="no"
  echo_default
}

function update_script() {
header_info

# Update package list and upgrade installed packages
apt update
apt upgrade -y
# Download the Suwayomi Server package
wget 'https://github.com/Suwayomi/Suwayomi-Server/releases/download/v1.1.1/Suwayomi-Server-v1.1.1-r1535-debian-all.deb'
# Install the Suwayomi Server package
dpkg -i Suwayomi-Server-v1.1.1-r1535-debian-all.deb
# Fix any broken dependencies
apt --fix-broken install -y
# Create a systemd service for Suwayomi Server
cat << EOF > /etc/systemd/system/suwayomi-server.service
[Unit]
Description=Suwayomi Server
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/bin/suwayomi-server
WorkingDirectory=/usr/bin
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF


msg_ok "Updated ${APP} to latest Git"
# Reload systemd to apply the new service
systemctl daemon-reload
# Enable and start the Suwayomi Server service
systemctl enable suwayomi-server
systemctl start suwayomi-server
echo "Suwayomi Server installation and setup complete."

msg_info "Starting ${APP} Service"

msg_ok "Started ${APP} Service"
msg_ok "Updated Successfully!\n"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL. SI a la paja segura
         ${BL}http://${IP}:4567${CL} \n"
