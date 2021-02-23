#Using the official cardano-node docker to create an ADA staking pool

This is to document how to create a Cardano ADA staking pool using the official docker image created by IOG. Assuming that you have docker configured and ready to go. I also use wget to download files so you may also need to install if it's not available.

First lets pull the official image created by IOG
```
# docker pull inputoutput/cardano-node
```
Use the download script to grab the configuration files from IOG [download_config_files.sh](https://github.com/bag0bits/carnode/blob/main/conf/download_config_files.sh)
```
# NODE_HOME=/opt/cardano >> $HOME/.bashrc
# source $HOME/.bashrc
# mkdir -p ${NODE_HOME}
# cd ${NODE_HOME}
# download_config_files.sh
```
Lets create a relay node start script (run-relay-example.sh)
```
#!/bin/bash
CARDANO_HOME=$(pwd)
PORT=3001
PROMETHEUS=12798
DB_DIR=db
TOPOLOGY=mainnet-topology.json
CONFIG=mainnet-config.json

docker run -d --rm -v ${CARDANO_HOME}:/configuration \
   --name relay-${PORT} \
   --workdir /configuration \
   -p ${PORT}:3001 \
   -p ${PROMETHEUS}:12798 \
   inputoutput/cardano-node run \
   --topology ${TOPOLOGY} \
   --database-path ${DB_DIR} \
   --socket-path socket \
   --host-addr 0.0.0.0 \
   --port 3001 \
   --config ${CONFIG}
```
### This start up script will

Use the current directory as the application working directory.
```
CARDANO_HOME=$(pwd)
```

Use this port for the node to be listening on
```
PORT=3001
```

Use this port to get metrics
```
PROMETHEUS=12798
```
### Start the relay node and let it sync
Lets run the script to start the relay node and start the block syncing
```
# cd ${NODE_HOME}
# run-relay-example.sh
```
Now follow the log to make sure we are running. In this case the listening port is 3001 so the relay node name is relay-3001. (Ctrl-C to exit the log follow)
```
# docker logs --follow relay-3001
```

### Create aliases to use the cli and get info

Using the path of the application working directory for the veriable CARDANO_HOME, create the alias for cli and node

```
CARDANO_HOME=${NODE_HOME}

alias cardano-cli="docker run -ti --rm \
   -v ${CARDANO_HOME}:/configuration \
   -e CARDANO_NODE_SOCKET_PATH=/configuration/socket \
   --workdir /configuration \
   --entrypoint /bin/cardano-cli \
   inputoutput/cardano-node"

alias cardano-node="docker run -ti --rm inputoutput/cardano-node"
```
Now test our alias to make sure we can access the binaries
```
# cardano-cli version
cardano-cli 1.25.1 - linux-x86_64 - ghc-8.10
git rev 9a7331cce5e8bc0ea9c6bfa1c28773f4c5a7000f

# cardano-node version
cardano-node 1.25.1 - linux-x86_64 - ghc-8.10
git rev 9a7331cce5e8bc0ea9c6bfa1c28773f4c5a7000f
```
### simpleLiveView

Older versions of the cardano-node included a LiveView which gives a dashboard on the status of the node. This feature was remove so in place we have simpleLiveView by [Crypto2099](https://github.com/Crypto2099/simpleLiveView)

```
cd ~
git clone https://github.com/crypto2099/simpleLiveView
cd simpleLiveView
sed -i 's/"$(command -v cardano-node)"/docker run --rm inputoutput\/cardano-node/' liveview.sh
./liveview.sh
```

### Create 2 more nodes for the producer and cold-offline

Follow the above on 2 additional servers for the producer and the cold-offline host to have the minimum nodes for operating a Cardano ADA stake pool.

Let the producer node sync the chain like the relay node. The cold node does not need the start up script or syncing.

### Time to create the keys and wallet to run a node producer

First we create our KES key pair on the **producer** node.
```
## DO THIS ON THE PRODUCER NODE
cd ${NODE_HOME}
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```
Now we create the node keys and counter on the **cold-offline** node
```
## DO THIS ON THE COLD-OFFLINE NODE
cd ${NODE_HOME}
cardano-cli node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter
```
Back on the **producer** node lets get some info about the current status of the Cardano network
```
## DO THIS ON THE PRODUCER NODE
cd ${NODE_HOME}
slotsPerKESPeriod=$(cat mainnet-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slotNo')
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo ${kesPeriod}
```
Copy kes.vkey to your **cold-offline**'s NODE_HOME and replace \<startKesPeriod\> with the value of kesPeriod from above to issue a node opt certificate.
```
## DO THIS ON THE COLD-OFFLINE NODE
cd ${NODE_HOME}
cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert
```
Copy node.cert to your **producer node**. And it's time to create the VRF keys and make it read-only.
```
## DO THIS ON THE PRODUCER NODE
cd ${NODE_HOME}
cardano-cli node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
chmod 400 vrf.skey
```
Now that we have all the files needed to start a producer node lets get the start up script for our producer node. (run-producer-example.sh)
```
#!/bin/bash
CARDANO_HOME=$(pwd)
PORT=3001
PROMETHEUS=12798
DB_DIR=db
TOPOLOGY=mainnet-topology.json
CONFIG=mainnet-config.json
KES=kes.skey
VRF=vrf.skey
CERT=node.cert

docker run -d --rm -v ${CARDANO_HOME}:/configuration \
   --name producer-${PORT} \
   --workdir /configuration \
   -p ${PORT}:3001 \
   -p ${PROMETHEUS}:12798 \
   inputoutput/cardano-node run \
   --topology ${TOPOLOGY} \
   --database-path ${DB_DIR} \
   --socket-path socket \
   --host-addr 0.0.0.0 \
   --port 3001 \
   --config ${CONFIG} \
   --shelley-kes-key ${KES} \
   --shelley-vrf-key ${VRF} \
   --shelley-operational-certificate ${CERT}
```
So lets run this script on the **producer node**.
```
# cd ${NODE_HOME}
# run-producer-example.sh
```
### (Optional) Setup cardano-rt-view node dashboard (DO IT!)
Come on .. you know you like dashboards.. Lets get one going..

Lets create a Dockerfile for this task.. something small
```
RT_HOME=<path to install RT>

mkdir -p ${RT_HOME}
cd ${RT_HOME}
mkdir -p ${RT_HOME}/conf
mkdir -p ${RT_HOME}/static

cat > ${RT_HOME}/Dockerfile << EOF
FROM alpine:latest
RUN mkdir -p /opt/rt-view
WORKDIR /opt/rt-view
RUN wget https://github.com/input-output-hk/cardano-rt-view/releases/download/0.3.0/cardano-rt-view-0.3.0-linux-x86_64.tar.gz
RUN tar zxvf cardano-rt-view-0.3.0-linux-x86_64.tar.gz
RUN rm -f cardano-rt-view-0.3.0-linux-x86_64.tar.gz
ENTRYPOINT /opt/rt-view/cardano-rt-view --static /data/static
EOF
```
Building the image
```
docker build -t cart-view .
```
Run
```
docker run -ti --rm \
  --name cart-view \
  -v $(pwd)/static:/static \
  -v $(pwd)/config:/root/.config \
  -p 4000:4000 \
  -p 4001:4001 \
  -p 4002:4002 \
  -p 8024:8024 \
  cart-view --static /data/static
```
OUTPUT
```
root@unbag:/mnt/user/misc/docker/rt# docker run -ti --rm   --name cart-view   -v $(pwd)/static:/static   -v $(pwd)/config:/root/.config   -p 4000:4000   -p 4001:4001   -p 4002:4002   -p 8024:8024   cart-view --static /static
RTView: real-time watching for Cardano nodes

Let's configure RTView...

Please note that this version of RTView works with the following versions of Cardano node: 1.24.1, 1.24.2
Press <Enter> to continue...

How many nodes will you connect (1 - 99, default is 3): 2
Ok, 2 nodes.

Input the names of the nodes (default are "node-1", "node-2"), one at a time: relay-3001
Ok, node 1 has name "relay-3001", input the next one: producer-3002
Ok, the last node has name "producer-3002".

Indicate the port for the web server (1024 - 65535, default is 8024):
Ok, the web-page will be available on http://0.0.0.0:8024, on the machine RTView will be launched on.

Indicate how your nodes should be connected with RTView: networking sockets <S> or named pipes <P>.
Default way is sockets, so if you are not sure - choose <S>:
Ok, sockets will be used. Indicate the base port to listen for connections (1024 - 65535, default is 3000): 4000
Ok, these ports will be used to accept nodes' metrics: 4000, 4001
Now, indicate a host of machine RTView will be launched on (default is 0.0.0.0):
Ok, default host will be used.

Indicate the directory with static content for the web server (default is "static"):
Ok, default directory will be used.
```

Profits
```
Usage: cardano-rt-view [--config FILEPATH] [--notifications FILEPATH]
                       [--static FILEPATH] [--port PORT]
                       [--active-node-life TIME] [-v|--version]
                       [--supported-nodes]

Available options:
  --config FILEPATH        Configuration file for RTView service. If not
                           provided, interactive dialog will be started.
  --notifications FILEPATH Configuration file for notifications
  --static FILEPATH        Directory with static content (default: "static")
  --port PORT              The port number (default: 8024)
  --active-node-life TIME  Active node lifetime, in seconds (default: 120)
  -h,--help                Show this help text
  -v,--version             Show version
  --supported-nodes        Show supported versions of Cardano node```
