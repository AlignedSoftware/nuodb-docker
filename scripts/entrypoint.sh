#!/usr/bin/env bash

#handle environment types
if [ "${ENV_TYPE}" == "OPENSHIFT" ]; then
    /bin/bash /scripts/openshift.sh

elif [ "${ENV_TYPE}" == "AWSECS" ]; then
    /bin/bash /scripts/awsEcs.sh

elif [ "${ENV_TYPE}" == "AWSEC2" ]; then
    echo "placeholder for AWSEC2"
elif [ "${ENV_TYPE}" == "AZURE" ]; then
    echo "placehodler for AZURE"
elif [ "${ENV_TYPE}" == "GOOGLE" ]; then
    echo "placeholder for GOOGLE"
fi

#run startNuodb.sh for starting nuodb broker, sm, and te containers
/bin/bash /scripts/startNuodb.sh

