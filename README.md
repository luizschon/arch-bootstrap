# Arch Bootstrap

A collection of scripts to bootstrap my Arch Linux installation inside the arch live image.

## Prerequisites

Before using the script, you must be [connected to the internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet) - you may check your connection using the `ping` command - and have your [disks partitioned](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks) and [formated](https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions).

Make sure you are using the GPT layout. You can use the `gdisk` tool to generate the GPT partition table, otherwise the system won't boot in UEFI mode.

## How to use

Download and extract the bootstrap scripts into the Arch Linux live image:

```
$ curl -L https://github.com/luizschonarth/arch-bootstrap/archive/current.tar.gz | tar -xz --strip-component=1
```

By default, the script uses [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) bootloader, but you can specify [GRUB](https://wiki.archlinux.org/title/GRUB) as your boot manager using the option `-g` of `--grub`. Run `zsh ./setup.sh --help` for information about all available options.

Modify the `partitions.conf`, `user.conf` and `system.conf` files to your liking (using your favorite text editor) and run:

```
$ zsh setup.sh [OPTIONS]
```
