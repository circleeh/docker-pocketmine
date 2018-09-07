[circleehurl]: https://circle.enterprises/
[appurl]: https://pmmp.io/
[hub]: https://hub.docker.com/r/circleeh/

[![](https://images.microbadger.com/badges/version/circleeh/pocketmine.svg)](https://microbadger.com/images/circleeh/pocketmine "Get your own version badge on microbadger.com")

The Circle Eh! team is happy to bring you a high quality PocketMine-MP Docker image.

## circleeh/pocketmine

Server software for Minecraft Pocket Edition written in PHP

[![PocketMine-MP](/img/PocketMine-MP-h.png)][appurl]

# Usage

## CLI
```
docker create --name=pocketmine \
  -v <path to data>:/config \
  -e PGID=<gid> -e PUID=<uid> \
  -e TZ=<timezone> \
  -p 19132:19132 \
  -p 19132/udp:19132/udp \
  -p 25575:25575 \
  circleeh/pocketmine
```

## docker-compose.yml
```yaml
version: "2"
services:
  pocketcraft:
    image: circleeh/pocketmine
    container_name: pocketmine
    environment:
      - TZ=America/Montreal
      - PUID=1000
      - PGID=1000
      - PLUGINS=https://poggit.pmmp.io/r/20052/PureEntitiesX_dev-192.phar
                https://poggit.pmmp.io/r/20015/Worlds_dev-16.phar
                https://poggit.pmmp.io/r/17958/XBL_PlayerList.phar
    volumes:
      - ~/docker/mc:/config
    ports:
      - "19132:19132"
      - "19132/udp:19132/udp"
      - "25575:25575"
```


Note that port mapping is dependent on the values in your server configuration, so adjust accordingly.

# Tags

You can choose, using a docker tag, which release of PocketMine-MP you would
like. We label the docker images with the same version number of the release
of PocketMine-MP that we include, as well as generic labels for the most recent
development, alpha, beta, and stable releases.  The `latest` tag will pull the 
most recent *stable* release.

Example:
```
circleeh/pocketmine:dev
```

# Parameters
The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container. So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080 http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.

* `-p 19132` - This is the default PocketMine-MP server port.
* `-p 25575` - This is the default RCON port.
* `-v /config` - The local path for all the PocketMine-MP config files.
* `-e PLUGINS` - A space separated list of the URLs to the phars you wish to install as plugins.
* `-e PGID` - Group ID - See below
* `-e PUID` - User ID - See below
* `-e TZ` - for setting timezone information, etc America/Montreal

# User/Group Identifiers

Sometimes when using data volumes (-v flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user PUID and group PGID. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work".

In this instance PUID=1001 and PGID=1001. To find yours use id user as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

# Info

* Shell access whilst the container is running: `docker exec -it pocketmine /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f pocketmine`
* To check the container version number: `docker inspect -f '{{ index .Config.Labels "build_version" }}' pocketmine`
* Too check the image version number: `docker inspect -f '{{ index .Config.Labels "build_version" }}' circleeh/pocketmine`

