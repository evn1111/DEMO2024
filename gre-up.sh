#!/bin/bash
ip tunnel add gre1 mode gre remote 2.2.2.2 local 1.1.1.2 ttl 255
ip link set gre1 up
ip addr add 10.10.10.1/30 dev gre1
iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
sysctl -p
systemctl restart frr

