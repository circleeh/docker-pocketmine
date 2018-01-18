[circleehurl]: https://circle.enterprises/
[appurl]: https://pmmp.io/
[hub]: https://hub.docker.com/r/circleeh/

The Circle Eh! team is happy to bring you this release.

## circleeh/pocketmine

Server software for Minecraft Pocket Edition written in PHP

[![PocketMine-MP](/img/PocketMine-MP-h.png)][appurl]

## Usage

```
docker create --name=pocketmine \
  -v <path to data>:/config \
  -p 19132:19132 \
  -p 25575:25575
```

Note that port mapping is dependent on the values in your server configuration, so adjust accordingly.