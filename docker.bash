#!/bin/bash
docker run --name freeipa-server-almalinux9 -ti \
    -h ipa.hwdomain.lan --read-only --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /var/lib/freeipa-data:/data:Z freeipa-almalinux9
