CNODE=/home/cardano/.local/bin/cardano-node
NODE_HOME=/home/cardano/node
TOPOLOGY=${NODE_HOME}/mainnet-topology.json
CONFIG=${NODE_HOME}/mainnet-config.json
DB_PATH=${NODE_HOME}/db
SOCKET_PATH=${NODE_HOME}/socket
HOSTADDR=0.0.0.0
PORT=3002
EKG_PORT=4002
PROMETHEUS_PORT=5002
CARVER=1.35.3
THREADS=8

docker run -tid --rm --name relay1 \
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
		+RTS -N${THREADS} -RTS

docker logs -f relay1 > relay1.log &
