# carnode
Simple docker builder for cardano-cli and cardano-node for running a Cardano staking pool.

Ever want to try your and at running a stake pool? Well you came to the right place. With this docker container you can get a relay or a producer node up in no time so you can check out the functionality of the project. Running a pool will help the decentralization of the network so the more people that gets involve will help the network be more secure and add values to the rest of the community.

With that being said getting a node up can be a pain if you just want to poke around and check it out. Here's where I can help.

1. clone this reposutory and change to the repo directory

 git clone https://github.com/bag0bits/carnode.git
 cd carnode

2. build your docker container. you can build with the script or just use the docker build command (takes about an hour). This will user the Dockerfile pull from the repository and create an image with cabal, GHC, Libsodium, cardano-node, and cardano-cli. (NOTICE: This will take some time so be pation)

 ./build.sh
-or-
 docker build -t carnode .

At this poing you should have a docker image with build version of cardano-node and cardano-cli version 1.25.1. 

3. at this poing you should have a docker image with build version of cardano-node and cardano-cli version 1.25.1. now lets get the configs from IOG.

 cd conf
 ./download_config_files.sh

this will download 4 files from IOG fro the configuration of the node

 mainnet-config.json
 mainnet-byron-genesis.json
 mainnet-shelley-genesis.json
 mainnet-topology.json

4. at this point you should have a simple relay node and can be start by running the script

 relay-node-run-example.sh

This will start a node and detach to background it.

5. reading the activity by following the docker log for that container

 docker logs --follow cardano-relay01
