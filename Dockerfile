###################################################
###
### Dockerfile for ubuntu/cardano-node operation
### Version 1.34.0
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
# v1.33.0 cardano-node version 1.33.0, ghc -> 8.10.7, cncli -> 4.0.4 
# v1.34.0 cardano-node version 1.34.0, cabal -> 3.6.2.0

## lock Ubuntu to 20.04
########################
FROM ubuntu:20.04

## Make apt-get non-interactive
################################
ENV DEBIAN_FRONTEND="noninteractive"

## Update the repo and install all the needed packages
#######################################################
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf libnuma-dev pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5 

## Add the cardano user and set user as the installer
######################################################
RUN useradd -ms /bin/bash cardano
USER cardano
WORKDIR /home/cardano
RUN mkdir -p /home/cardano/src

## Install libsodium and set checkout tag to 66f017f1
######################################################
WORKDIR /home/cardano/src
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /home/cardano/src/libsodium
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
USER root
RUN make install
USER cardano

## Install Cabal and ghc
#########################
WORKDIR /home/cardano/src
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org > ghc.sh
RUN chmod +x /home/cardano/src/ghc.sh
RUN /home/cardano/src/ghc.sh
ENV PATH=/home/cardano/.ghcup/bin:${PATH}
WORKDIR /home/cardano
RUN ghcup upgrade
RUN ghcup install cabal 3.6.2.0
RUN ghcup set cabal 3.6.2.0
RUN ghcup install ghc 8.10.7
RUN ghcup set ghc 8.10.7

## Now to Cardano node and cli (tag 1.34.0)
############################################
RUN echo 'export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"' >> /home/cardano/.bashrc
RUN echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"' >> /home/cardano/.bashrc
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
WORKDIR /home/cardano/src
RUN git clone https://github.com/input-output-hk/cardano-node.git
RUN chown -R cardano.cardano cardano-node
WORKDIR /home/cardano/src/cardano-node
RUN git fetch --all --recurse-submodules --tags
RUN git checkout tags/1.34.0
RUN cabal configure -O0 -w ghc-8.10.7
RUN echo "package cardano-crypto-praos" >> cabal.project.local
RUN echo "  flags: -external-libsodium-vrf" >> cabal.project.local
RUN sed -i /home/cardano/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
RUN cabal build cardano-cli cardano-node
RUN mkdir -p /home/cardano/.local/bin
RUN cp ./dist-newstyle/build/x86_64-linux/ghc-8.10.7/cardano-node-1.34.0/x/cardano-node/noopt/build/cardano-node/cardano-node /home/cardano/.local/bin/
RUN cp ./dist-newstyle/build/x86_64-linux/ghc-8.10.7/cardano-cli-1.34.0/x/cardano-cli/noopt/build/cardano-cli/cardano-cli /home/cardano/.local/bin/
RUN echo 'export PATH="/home/cardano/.local/bin:${PATH}"' >> /home/cardano/.bashrc
RUN echo 'export CARDANO_NODE_SOCKET_PATH="/home/cardano/node/socket"' >> /home/cardano/.bashrc


## install gLiveView
#####################
WORKDIR /home/cardano
USER root
RUN apt-get install -y tcptraceroute lsof
USER cardano
RUN wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
RUN wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
RUN chmod 755 gLiveView.sh

RUN sed -i env -e 's@#CONFIG="${CNODE_HOME}/files/config.json"@CONFIG="/home/cardano/node/mainnet-config.json"@g'
RUN sed -i env -e 's@#SOCKET="${CNODE_HOME}/sockets/node0.socket"@SOCKET="/home/cardano/node/socket"@g'


## installing cncli
###################
WORKDIR /home/cardano/.local/bin/
USER cardano
RUN wget https://github.com/AndrewWestberg/cncli/releases/download/v4.0.4/cncli-4.0.4-x86_64-unknown-linux-gnu.tar.gz
RUN tar zxvf cncli-4.0.4-x86_64-unknown-linux-gnu.tar.gz
RUN rm cncli-4.0.4-x86_64-unknown-linux-gnu.tar.gz

RUN mkdir /home/cardano/node
WORKDIR /home/cardano/node

ENTRYPOINT ["/home/cardano/.local/bin/cardano-cli"]
CMD ["query tip --mainnet"]
