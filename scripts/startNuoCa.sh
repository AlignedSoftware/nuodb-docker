#!/usr/bin/env bash

export NUODB_HOME=/opt/nuodb/

#start nuomonitor
python /opt/nuomonitor/nuomonitor.py -b ${PEER_ADDRESS} -u domain -p ${DOMAIN_PASSWORD} -l 8082 &

#update yaml file
python prepNuoCa.py \
        --peer-addr=${PEER_ADDRESS} \
        --app-host=${ARG_apphost} \
        --elastic-host=${ELASTIC_HOST} \
        --elastic-port=${ELASTIC_PORT} \
        --elastic-index=${ELASTIC_INDEX}

python /opt/nuoca/src/nuoca.py \
        --config-file /opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml \
        --plugin-dir /opt/nuoca/tests/dev/plugins \
        --collection-interval=10  &