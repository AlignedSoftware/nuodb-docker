#!/usr/bin/env bash

#This script should run when a host is being terminated to clean itself from the domain state.
IPADDRESS="$(ifconfig eth0 | grep broadcast | awk '{print $2}')"

/opt/nuodb/bin/nuodbmgr --broker ${PEER_ADDRESS} --password ${DOMAIN_PASSWORD} \
    --command "remove host address $IPADDRESS database ${DB_NAME}"