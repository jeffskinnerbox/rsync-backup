<!--
Maintainer:   jeffskinnerbox@yahoo.com / www.jeffskinnerbox.me
Version:      1.5.0
-->


<div align="center">
<img src="http://www.foxbyrd.com/wp-content/uploads/2018/02/file-4.jpg" title="These materials require additional work and are not ready for general use." align="center">
</div>


-----


Two candidate rsnapshot containders:
* [linuxserver/rsnapshot](https://hub.docker.com/r/linuxserver/rsnapshot)
    * [linuxserver/rsnapshot](https://github.com/linuxserver/docker-rsnapshot)
* [helmuthb/rsnapshot](https://hub.docker.com/r/helmuthb/rsnapshot)
    * [helmuthb/rsnapshot](https://github.com/helmuthb/rsnapshot-docker)

[Rsnapshot][01] is a filesystem snapshot utility based on rsync.
rsnapshot makes it easy to make periodic backups of a local machines to a remote machines over ssh.
The rsnapshot makes extensive use of hard links to greatly reduce the disk space required.

Unfortanatly, the rsnapshot package has been [removed from the latest Debian release][02],
therefore, from Raspberry Pi OS too.
While this might be temprary, I needed a work around now.
I found that work around via a [Docker containerized version of rsnapshot][03]
offered by [linuxserver.io][04].

docker-compose version:

```yaml
version: "2.1"
services:
  rsnapshot:
    image: lscr.io/linuxserver/rsnapshot:latest
    container_name: rsnapshot
    environment:
      - PUID=400                             # user id of backup_user
      - PGID=400                             # group id of backup_user
      - TZ=America/New_York                  # specify a timezone to use
    volumes:
      - </path/to/appdata/config>:/config    # contains all relevant configuration files
      - </path/to/snapshots>:/.snapshots     # optional - storage location for all snapshots
      - </path/to/data>:/data                # optional - storage location for data to be backed up
    restart: unless-stopped
```



[01]:https://rsnapshot.org/
[02]:https://github.com/rsnapshot/rsnapshot/issues/279
[03]:https://hub.docker.com/r/linuxserver/rsnapshot
[04]:https://www.linuxserver.io/
[05]:
[06]:
[07]:
[08]:
[09]:
[10]:
