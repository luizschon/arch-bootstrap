# arch-bootstrap

A collection of scripts to bootstrap my Arch Linux installation inside the arch live image

## Prerequisites

Before using the script, you must be [connected to the internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet) - you might check your connection using the `ping` command - and have your disks partitioned. Make sure you are using the GPT layout.

## How to use

After, meeting the above prerequisites, download [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) version of the script using the following command :

```
$ curl -L https://github.com/luizschonarth/arch-bootstrap/archive/systemd-boot.tar.gz | tar -xz --strip-component=1
```

or

```
$ curl -L https://github.com/luizschonarth/arch-bootstrap/archive/grub.tar.gz | tar -xz --strip-component=1
```

If you plan on using [GRUB](https://wiki.archlinux.org/title/GRUB) as your boot manager.

Modify the `partitions.conf` and `user.conf` files to your liking and run:

```
$ zsh setup.sh
```
