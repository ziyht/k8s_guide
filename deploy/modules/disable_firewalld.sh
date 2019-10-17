#!/bin/sh

systemctl disable --now firewalld

# master
#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --reload

# node
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --permanent --add-port=30000-32767/tcp
#firewall-cmd --permanent --add-port=6783/tcp
#firewall-cmd --reload
