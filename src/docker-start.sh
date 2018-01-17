#!/bin/bash
set -e

configfiles="banned-ips.txt
             banned-players.txt
             ops.txt
             white-list.txt
             white-list.txt"

for file in $configfiles; do
    if [ ! -e /config/${file} ]; then
        touch /config/${file}
        ln -s /config/${file} /pocketmine/${file}
    fi
done

# Handle the main configuration file separately since it exists in /pocketmine
if [ -e /pocketmine/server.properties ] && [ ! -L /pocketmine/server.properties ]; then
    mv /pocketmine/server.properties /config/server.properties
    ln -s /config/server.properties /pocketmine/server.properties
fi

cd /pocketmine && ./start.sh --no-wizard