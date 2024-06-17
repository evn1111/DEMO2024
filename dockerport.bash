#!/bin/bash
docker run --name freeipa-server-almalinux9 -ti \
    -h ipa.hwdomain.lan -p 53:53/udp -p 53:53 -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp \
    --read-only --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /var/lib/freeipa-data:/data:Z freeipa-almalinux9
