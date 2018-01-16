#!/bin/bash
set -e

# "452" is the build number from pmmp.io to install, e.g.
# on Nov 25, 2017 the latest version produced was 452:
# https://jenkins.pmmp.io/job/PocketMine-MP/452
POCKETMINE_BUILD_NUMBER=${POCKETMINE_BUILD_NUMBER:-452}
cd /data
#/installer.sh -r -v $POCKETMINE_BUILD_NUMBER
/installer.sh -r
./start.sh
