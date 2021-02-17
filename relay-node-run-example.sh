PORT=6000
NODENAME=cardano-relay01
docker run -ti --rm \
        --user 0 \
        --name ${NODENAME} \
	-v $(pwd)/conf:/home/cardano/node/conf \
	-v $(pwd)/db:/home/cardano/node/db \
	-p ${PORT}:6000 carnode \
	cardano-node run --topology conf/mainnet-topology.json \
                         --config conf/mainnet-config.json \
                         --database-path db \
                         --socket-path db/socket \
                         --host-addr 0.0.0.0 \
                         --port 6000
