to run as relay node you just need the files provided by download-config-files.sh

to run as producer, along with configs like the relay node you will also need
- kes.skey (KES signing key)
- vrf.skey (VRF signing key)
- node.cert (The node's cert)


The example run scripts will look for these config/key/cert files from the current running directory. At minimum your running directory should look like this.

Relay:

build.sh
Dockerfile
download-config-files.sh
mainnet-alonzo-genesis.json
mainnet-byron-genesis.json
mainnet-config.json
mainnet-shelley-genesis.json
mainnet-topology.json
producer-node-run-example.sh
README.md
relay-node-run-example.sh


Producer:

build.sh
Dockerfile
download-config-files.sh
mainnet-alonzo-genesis.json
mainnet-byron-genesis.json
mainnet-config.json
mainnet-shelley-genesis.json
mainnet-topology.json
producer-node-run-example.sh
README.md
relay-node-run-example.sh
kes.skey
vrf.skey
node.cert

The example startup scripts will start the producer to listen on port 3001 and 3002 for the relay node.

To run gLiveView:

docker exec -ti relay1 /bin/bash -l -c "/home/cardano/node/gLiveView.sh"
docker exec -ti producer /bin/bash -l -c "/home/cardano/node/gLiveView.sh"

