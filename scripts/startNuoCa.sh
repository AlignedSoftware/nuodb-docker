#!/usr/bin/env bash

export NUODB_HOME=/opt/nuodb/

#start nuomonitor
python /opt/nuomonitor/nuomonitor.py -b ${PEER_ADDRESS} -u domain -p ${DOMAIN_PASSWORD} -l 8082 &

#update yaml file
sed -i "/broker: 172.19.0.16/c\    broker: ${PEER_ADDRESS}" /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml
sed -i "/url/c\    url: ${ARG_apphost}" /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml

python /opt/nuoca/src/nuoca.py \
        --config-file /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml \
        --plugin-dir /opt/nuoca/tests/dev/plugins \
        --collection-interval=10 \
        --self-test &