#!/bin/bash
apt install iptables
iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
apt install iptables-persistent
iptables-save >> /etc/iptables/rules.v4
