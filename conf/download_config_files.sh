#!/bin/bash

wget https://hydra.iohk.io/build/7416228/download/1/mainnet-config.json
wget https://hydra.iohk.io/build/7416228/download/1/mainnet-byron-genesis.json
wget https://hydra.iohk.io/build/7416228/download/1/mainnet-shelley-genesis.json
wget https://hydra.iohk.io/build/7416228/download/1/mainnet-alonzo-genesis.json
wget https://hydra.iohk.io/build/7416228/download/1/mainnet-topology.json
sed -i mainnet-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"

