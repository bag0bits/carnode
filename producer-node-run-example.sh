PORT=6001
NODENAME=cardano-producer01
docker run -d --rm \
        --user 0 \
        --name ${NODENAME} \
	-v $(pwd)/conf:/home/cardano/node/conf \
	-v $(pwd)/db:/home/cardano/node/db \
	-p ${PORT}:6000 carnode \
	cardano-node run --topology conf/mainnet-topology.json \
                         --config conf/mainnet-config.json \
                         --database-path db \
                         --socket-path socket \
                         --host-addr 0.0.0.0 \
                         --port 6000 \
                         --shelley-kes-key conf/kes.skey \
                         --shelley-vrf-key conf/vrf.skey \
                         --shelley-operational-certificate conf/node.cert
