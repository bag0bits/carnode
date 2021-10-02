CNODE=/home/cardano/.local/bin/cardano-node
NODE_HOME=/home/cardano/node
TOPOLOGY=${NODE_HOME}/mainnet-topology.json
CONFIG=${NODE_HOME}/mainnet-config.json
DB_PATH=${NODE_HOME}/db
SOCKET_PATH=${NODE_HOME}/socket
HOSTADDR=0.0.0.0
PORT=3001

docker run -ti --rm --name producer --entrypoint ${CNODE} -p ${PORT}:3001 -v $(pwd):${NODE_HOME} carnode run \
	 --topology ${TOPOLOGY} \
	 --database-path ${DB_PATH} \
	 --socket-path ${SOCKET_PATH} \
	 --host-addr ${HOSTADDR} \
	 --port 3001 \
	 --config ${CONFIG} \
	 +RTS -N -RTS
