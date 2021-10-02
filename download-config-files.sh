#!/bin/bash

NODE_BUILD_NUM=$(curl -s https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')

wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-topology.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-alonzo-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-config.json

sed -i mainnet-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
