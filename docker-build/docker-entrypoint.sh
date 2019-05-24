#!/bin/sh
set -e

. /etc/profile >/dev/null 2>&1

CONFIG="$ZK_CONF_DIR/zoo.cfg"
sed -i "s%dataDir=.*%dataDir=${ZK_DATA_DIR}%g" $CONFIG
sed -i '/server.*/d' $CONFIG
for zk in $ZK_SERVERS; do
    echo "$zk" >> $CONFIG
done

# Write myid only if $ZOO_MY_ID exist
if [ -n "${ZK_MY_ID}" ]; then
    mkdir -p $ZK_DATA_DIR
    echo "${ZK_MY_ID:-1}" > "$ZK_DATA_DIR/myid"
fi

if [ "$1" = "zkServer.sh" ]; then
    gosu zookeeper zkServer.sh "$@"
fi

exec "$@"