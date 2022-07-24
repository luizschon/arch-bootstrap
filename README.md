# arch-bootstrap

A collection of scripts to bootstrap my Arch Linux installation inside the arch live image.

## Prerequisites

Before using the script, you must be [connected to the internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet) - you may check your connection using the `ping` command - and have your [disks partitioned](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks) and [formated](https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions).

Make sure you are using the GPT layout. You can use the `gdisk` tool to generate the GPT partition table, otherwise the system won't boot in UEFI mode.

## How to use

To download the [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) version of the script, use the following command:

```
$ mkdir -p /scripts
$ curl -L https://github.com/luizschonarth/arch-bootstrap/archive/systemd-boot.tar.gz | tar -xz --strip-component=1 -C /scripts
```

If you plan on using [GRUB](https://wiki.archlinux.org/title/GRUB) as your boot manager, use the following:

```
$ mkdir -p /scripts
$ curl -L https://github.com/luizschonarth/arch-bootstrap/archive/grub.tar.gz | tar -xz --strip-component=1 -C /scripts
```

Modify the `partitions.conf` and `user.conf` files to your liking and run:

```
$ zsh setup.sh
```
