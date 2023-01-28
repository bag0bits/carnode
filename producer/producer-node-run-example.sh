CNODE=/home/cardano/.local/bin/cardano-node
NODE_HOME=/home/cardano/node
TOPOLOGY=${NODE_HOME}/mainnet-topology.json
CONFIG=${NODE_HOME}/mainnet-config.json
DB_PATH=${NODE_HOME}/db
SOCKET_PATH=${NODE_HOME}/socket
KES=${NODE_HOME}/kes.skey
VRF=${NODE_HOME}/vrf.skey
CERT=${NODE_HOME}/node.cert
HOSTADDR=0.0.0.0
PORT=3001
EKG_PORT=4001
PROMETHEUS_PORT=5001
CARVER=1.35.5
THREADS=8

docker run -tid --rm --name producer \
	--log-opt max-size=512m \
	--entrypoint ${CNODE} \
	-p ${PORT}:3001 \
	-p ${PROMETHEUS_PORT}:12798 \
	-v $(pwd):${NODE_HOME} \
	carnode:${CARVER} run \
		--topology ${TOPOLOGY} \
		--database-path ${DB_PATH} \
		--socket-path ${SOCKET_PATH} \
		--host-addr ${HOSTADDR} \
		--port ${PORT} \
		--config ${CONFIG} \
		--shelley-kes-key ${KES} \
		--shelley-vrf-key ${VRF} \
		+RTS -N${THREADS} -RTS \
		--shelley-operational-certificate ${CERT} 

docker logs -f producer > producer.log &
