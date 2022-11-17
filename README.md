# Docker image for cardano-node 1.35.4 on ubuntu 20.04. 

CHANGES
- v1.25.1 cardano-node version 1.25.1 
- v1.29.0 cardano-node version 1.29.0
- v1.30.1 cardano-node version 1.30.1
- v1.31.0 cardano-node version 1.31.0 and add cncli
- v1.32.1 cardano-node version 1.32.1
- v1.33.0 cardano-node version 1.33.0, ghc -> 8.10.7, cncli -> 4.0.4
- v1.34.0 cardano-node version 1.34.0, cabal -> 3.6.2.0
- v1.35.0 cardano-node version 1.35.0, add Secp256k1
- v1.35.3 cardano-node version 1.35.3 because wtf
- v1.35.4 cardano-node version 1.35.4

## How to use.. ish...

This process will download and build from source cardano-node and cardano-cli from IOG's repository, along with a couple of other IOG supporting software. It's working for me but I was the one building this so what you do with your time is all you.

1. Run build.sh to build the docker image (this will take about 2hrs)
2. Change dir to producer or relay1
3. Use the download-config-files.sh to get the config files
4. Use the example run scripts to start the node.

to run as relay node you just need the files provided by download-config-files.sh

to run as producer, along with configs like the relay node you will also need
- kes.skey (KES signing key)
- vrf.skey (VRF signing key)
- node.cert (The node's cert)

The example run scripts will look for these config/key/cert files from the current running directory. At minimum your running directory should look like this.

relay1:

    download-config-files.sh
    mainnet-alonzo-genesis.json
    mainnet-byron-genesis.json
    mainnet-config.json
    mainnet-shelley-genesis.json
    mainnet-topology.json
    relay-node-run-example.sh


producer:

    download-config-files.sh
    mainnet-alonzo-genesis.json
    mainnet-byron-genesis.json
    mainnet-config.json
    mainnet-shelley-genesis.json
    mainnet-topology.json
    producer-node-run-example.sh
    kes.skey
    vrf.skey
    node.cert

The example startup scripts will start the producer to listen on port 3001 and 3002 for the relay1 node.
