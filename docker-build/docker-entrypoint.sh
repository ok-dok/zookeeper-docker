#!/bin/sh
set -e

. /etc/profile >/dev/null 2>&1

CONFIG="$ZOO_CONF_DIR/zoo.cfg"
sed -i "s%dataDir=.*%dataDir=${ZOO_DATA_DIR}%g" $CONFIG

for zoo in $ZOO_SERVERS; do
    echo "$zoo" >> $CONFIG
done

# Write myid only if it doesn't exist
if [ ! -f "$ZOO_DATA_DIR/myid" ]; then
    mkdir -p $ZOO_DATA_DIR
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
fi

if [ "$1" = "zkServer.sh" ]; then
    gosu zookeeper zkServer.sh "$@"
fi

exec "$@"