###################################################
###
### Dockerfile for ubuntu/cardano-node operation
### Version 1.33.0
### by: bag0bits
### Date: 2022-01-08
###
###################################################

#Release note

# v1.25.1 cardano-node version 1.25.1 
# v1.29.0 cardano-node version 1.29.0
# v1.30.1 cardano-node version 1.30.1
# v1.31.0 cardano-node version 1.31.0 and add cncli
# v1.32.1 cardano-node version 1.32.1
# v1.33.0 cardano-node version 1.33.0 

## lock Ubuntu to 20.04
########################
from ubuntu:20.04

## Make apt-get non-interactive
################################
env DEBIAN_FRONTEND="noninteractive"

## Update the repo and install all the needed packages
#######################################################
run apt-get update
run apt-get -y upgrade
run apt-get -y install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf libnuma-dev pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5 

## Add the cardano user and set user as the installer
######################################################
run useradd -ms /bin/bash cardano
user cardano
workdir /home/cardano
run mkdir -p /home/cardano/src

## Install libsodium and set checkout tag to 66f017f1
######################################################
workdir /home/cardano/src
run git clone https://github.com/input-output-hk/libsodium
workdir /home/cardano/src/libsodium
run git checkout 66f017f1
run ./autogen.sh
run ./configure
run make
user root
run make install
user cardano

## Install Cabal and ghc
#########################
workdir /home/cardano/src
env BOOTSTRAP_HASKELL_NONINTERACTIVE=1
run curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org > ghc.sh
run chmod +x /home/cardano/src/ghc.sh
run /home/cardano/src/ghc.sh
env PATH=/home/cardano/.ghcup/bin:${PATH}
workdir /home/cardano
run ghcup upgrade
run ghcup install cabal 3.4.0.0
run ghcup set cabal 3.4.0.0
run ghcup install ghc 8.10.4
run ghcup set ghc 8.10.4

## Now to Cardano node and cli (tag 1.33.0)
############################################
run echo "go 1.33.0"
run echo 'export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"' >> /home/cardano/.bashrc
run echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"' >> /home/cardano/.bashrc
env LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
env PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
workdir /home/cardano/src
run git clone https://github.com/input-output-hk/cardano-node.git
run chown -R cardano.cardano cardano-node
workdir /home/cardano/src/cardano-node
run git fetch --all --recurse-submodules --tags
run git checkout tags/1.33.0
run cabal configure -O0 -w ghc-8.10.4
run echo "package cardano-crypto-praos" >> cabal.project.local
run echo "  flags: -external-libsodium-vrf" >> cabal.project.local
run sed -i /home/cardano/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
run cabal build cardano-cli cardano-node
run mkdir -p /home/cardano/.local/bin
run cp ./dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-node-1.33.0/x/cardano-node/noopt/build/cardano-node/cardano-node /home/cardano/.local/bin/
run cp ./dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-cli-1.33.0/x/cardano-cli/noopt/build/cardano-cli/cardano-cli /home/cardano/.local/bin/
run echo 'export PATH="/home/cardano/.local/bin:${PATH}"' >> /home/cardano/.bashrc
run echo 'export CARDANO_NODE_SOCKET_PATH="/home/cardano/node/socket"' >> /home/cardano/.bashrc


## install gLiveView
#####################
workdir /home/cardano
user root
run apt-get install -y tcptraceroute lsof
user cardano
run wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
run wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
run chmod 755 gLiveView.sh

run sed -i env -e 's@#CONFIG="${CNODE_HOME}/files/config.json"@CONFIG="/home/cardano/node/mainnet-config.json"@g'
run sed -i env -e 's@#SOCKET="${CNODE_HOME}/sockets/node0.socket"@SOCKET="/home/cardano/node/socket"@g'


## installing cncli
###################
workdir /home/cardano/.local/bin/
user cardano
run wget https://github.com/AndrewWestberg/cncli/releases/download/v4.0.2/cncli-4.0.2-x86_64-unknown-linux-gnu.tar.gz
run tar zxvf cncli-4.0.2-x86_64-unknown-linux-gnu.tar.gz
run rm cncli-4.0.2-x86_64-unknown-linux-gnu.tar.gz

run mkdir /home/cardano/node
workdir /home/cardano/node

ENTRYPOINT ["/home/cardano/.local/bin/cardano-cli"]
CMD ["query tip --mainnet"]
