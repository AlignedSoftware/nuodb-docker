#!/usr/bin/env bash

#This script should run when a host is being terminated to clean itself from the domain state.

/opt/nuodb/bin/nuodbmgr --broker ${PEER_ADDRESS} --password ${DOMAIN_PASSWORD} \
    --command "remove host address ${ALT_ADDRESS} database ${DB_NAME}"