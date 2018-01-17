#!/bin/bash
set -e

CONFIGFILES="banned-ips.txt
             banned-players.txt
             ops.txt
             white-list.txt"

for file in $CONFIGFILES; do
    if [ ! -e /config/${file} ]; then
        touch /config/${file}
    fi
    ln -s /config/${file} /pocketmine/${file}
done

# Handle the main configuration file separately since it exists in /pocketmine
if [ -e /pocketmine/server.properties ] && [ ! -L /pocketmine/server.properties ]; then
    mv /pocketmine/server.properties /config/server.properties
    ln -s /config/server.properties /pocketmine/server.properties
fi

PHP_INI=/usr/local/etc/php/php.ini
TIMEZONE=$(date +%Z)
if [ ! -e ${PHP_INI} ]; then
    echo "date.timezone=$TIMEZONE" > "${PHP_INI}"
    echo "short_open_tag=0" >> "${PHP_INI}"
    echo "asp_tags=0" >> "${PHP_INI}"
    echo "phar.readonly=0" >> "${PHP_INI}"
    echo "phar.require_hash=1" >> "${PHP_INI}"
    echo "igbinary.compact_strings=0" >> "${PHP_INI}"
    echo "zend.assertions=-1" >> "${PHP_INI}"
    echo "error_reporting=-1" >> "${PHP_INI}"
    echo "display_errors=1" >> "${PHP_INI}"
    echo "display_startup_errors=1" >> "${PHP_INI}"
    echo ";zend_extension=opcache.so" >> "${PHP_INI}"
    echo "opcache.enable=1" >> "${PHP_INI}"
    echo "opcache.enable_cli=1" >> "${PHP_INI}"
    echo "opcache.save_comments=1" >> "${PHP_INI}"
    echo "opcache.fast_shutdown=0" >> "${PHP_INI}"
    echo "opcache.max_accelerated_files=4096" >> "${PHP_INI}"
    echo "opcache.interned_strings_buffer=8" >> "${PHP_INI}"
    echo "opcache.memory_consumption=128" >> "${PHP_INI}"
    echo "opcache.optimization_level=0xffffffff" >> "${PHP_INI}"
fi

cd /pocketmine && ./start.sh --no-wizard