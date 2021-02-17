# carnode

A simple docker builder for cardano-cli and cardano-node for running a Cardano staking pool (or at lease check it out).

from cardano.org

>A stake pool is a reliable server node that focuses on maintenance and holds the combined stake of various stakeholders in a single entity. Stake pools are responsible for processing transactions and producing new blocks and are at the core of Ouroboros, the Cardano proof-of-stake protocol.
>
>To be secure, Ouroboros requires a good number of ada holders to be online and maintain sufficiently good network connectivity at any given time. This is why Ouroboros relies on stake pools, entities committed to run the protocol 24/7, on behalf of the contributing ada holders.

This docker image builder will help you get started with creating the environments and files that you will need to start a stake pool. The more people gets invlove the more decentralize and secure the network become. This will add value to ADAs and we all get the benifits.  SO LETS GET STARTED!!!

I'm going to assume that you have docker installed and configured. if not click [here](https://www.google.com).

1. clone this reposutory and change to the repo directory
```
git clone https://github.com/bag0bits/carnode.git
cd carnode
```

2. build your docker container (this will take 45min or so). 
```
docker build -t carnode .
```

3. at this poing you should have a docker image with a build version of cardano-node and cardano-cli version 1.25.1. Now lets go to IOG and download the configuration files
```
cd conf
./download_config_files.sh
```
This will download 4 files from IOG fro the configuration of the node.
mainnet-config.json
mainnet-byron-genesis.json
mainnet-shelley-genesis.json
mainnet-topology.json

4. at this point you should have a simple relay node and can be start by running the script
```
relay-node-run-example.sh
```
This will start a node and detach to background it.

5. reading the activity by following the docker log for that container
```
docker logs --follow cardano-relay01
```