#!/usr/bin/env bash

export NUODB_HOME=/opt/nuodb/

#start nuomonitor
nuomonitor -s ${PEER_ADDRESS} -P 8888 -u ${DB_USER} -p ${DB_PASSWORD} -m Commits -i 10

#update yaml file
sed -i "/broker: 172.19.0.16/c\    broker: ${PEER_ADDRESS}" /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml
sed -i "/url/c\    url: ${ARG_apphost}" /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml

python /opt/nuoca/src/nuoca.py \
        --config-file /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml \
        --plugin-dir /opt/nuoca/tests/dev/plugins \
        --collection-interval=10 \
        --self-test &