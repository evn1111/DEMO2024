#!/bin/bash
apt install freeipa-client oddjob-mkhomedir -y
ipa-client-install --hostname=cli.hq.work --mkhomedir --server=hq-srv.hq.work --domain=hq.work --realm=HQ.WORK