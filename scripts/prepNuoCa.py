#!/usr/bin/env python

import yaml
import argparse


ncaCfgFile = "/opt/nuoca/tests/dev/configs/nuomonitor_to_restclient.yml"


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--peer-addr')
    parser.add_argument('-a', '--app-host')
    parser.add_argument('-eh', '--elastic-host')
    parser.add_argument('-ep', '--elastic-port')
    parser.add_argument('-ei', '--elastic-index')
    args = parser.parse_args()
    have_elastic = False

    with open(ncaCfgFile, "r") as cfgFile:
        cfg = yaml.load(cfgFile)

    if 'INPUT_PLUGINS' in cfg:
        for plugin in cfg['INPUT_PLUGINS']:
            for pname in plugin:
                if 'broker' in plugin[pname]:
                    plugin[pname]['broker'] = args.peer_addr

    if 'OUTPUT_PLUGINS' in cfg:
        for plugin in cfg['OUTPUT_PLUGINS']:
            for pname in plugin:
                if 'url' in plugin[pname]:
                    plugin[pname]['url'] = args.app_host

                if pname == 'ElasticSearch':
                    have_elastic = True

    if not have_elastic:
        esTmp = {
            'ElasticSearch': {
                'HOST': args.elastic_host,
                'PORT': args.elastic_port,
                'INDEX': args.elastic_index
            }
        }
        cfg['OUTPUT_PLUGINS'].append(esTmp)

    with open(ncaCfgFile, "w") as cfgFile:
        cfgFile.write(yaml.dump(cfg))

    print "Finished preparing NuoCA configuration"