#!/usr/bin/env bash


python /opt/nuoca/src/nuoca.py \
        --config-file /opt/nuoca/tests/dev/configs/mpRestClientOutputPlugin.yml \
        --plugin-dir tests/dev/plugins --collection-interval=1 --self-test