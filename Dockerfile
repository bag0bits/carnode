###################################################
###
### Dockerfile for minimal cardano-node operation
### Version 0.1
### by: bag0bits
### Date: 2021-02-13
###
###################################################

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
run apt-get -y install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf bc tcptraceroute


## Add the cardano user and set user as the installer
######################################################
run useradd -ms /bin/bash cardano
user cardano
workdir /home/cardano


## Install Cabal 3.2.0 from haskell.org
################################################
run wget -4 -q https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
run tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
run rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
run mkdir -p /home/cardano/.local/bin
run mv cabal /home/cardano/.local/bin/
env PATH="/home/cardano/.local/bin:${PATH}"
run cabal update


## Install ghc 8.10.2
######################
run mkdir -p /home/cardano/src
workdir /home/cardano/src
run wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz
run tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz
run rm ghc-8.10.2-x86_64-deb9-linux.tar.xz
workdir /home/cardano/src/ghc-8.10.2
run ./configure
user root
run make install


## Install libsodium and set checkout tag to 66f017f1
######################################################
user cardano
workdir /home/cardano/src
run git clone https://github.com/input-output-hk/libsodium
workdir /home/cardano/src/libsodium
run git checkout 66f017f1
run ./autogen.sh
run ./configure
run make
user root
run make install


## Now to Cardano node and cli (tag 1.25.1)
############################################
user cardano
run echo 'export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"' >> /home/cardano/.bashrc
run echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"' >> /home/cardano/.bashrc
env LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
env PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
workdir /home/cardano/src
run git clone https://github.com/input-output-hk/cardano-node.git
workdir /home/cardano/src/cardano-node
run git fetch --all --recurse-submodules --tags
run git checkout tags/1.25.1
run cabal configure --with-compiler=ghc-8.10.2
run echo "package cardano-crypto-praos" >> cabal.project.local
run echo "  flags: -external-libsodium-vrf" >> cabal.project.local
run cabal build all

run cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.2/cardano-cli-1.25.1/x/cardano-cli/build/cardano-cli/cardano-cli /home/cardano/.local/bin/
run cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.2/cardano-node-1.25.1/x/cardano-node/build/cardano-node/cardano-node /home/cardano/.local/bin/


## install gLiveView
#####################
# workdir /home/cardano
# run wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
# run wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
# run chmod 755 gLiveView.sh

# run sed -i env -e 's@#CONFIG="${CNODE_HOME}/files/config.json"@CONFIG="/home/cardano/conf/mainnet-config.json"@g'
# run sed -i env -e 's@#SOCKET="${CNODE_HOME}/sockets/node0.socket"@SOCKET="/home/cardano/db/socket"@g'

run mkdir /home/cardano/node
workdir /home/cardano/node
