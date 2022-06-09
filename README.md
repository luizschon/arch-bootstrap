# arch-bootstrap

A collection of scripts to bootstrap my Arch Linux installation inside the arch live image

## Prerequisites

Before using the script, you must be [https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet](connected to the internet) - you might check your connection using the `ping` command - and have your disks partitioned.

## How to use

After, meeting the above prerequisites, download the repository using the following command:

```
$ curl -L https://github.com/luizschonarth/arch-bootstrap/archive/main.tar.gz | tar -xz --strip-component=1
```

Modify the `partitions.conf` and `user.conf` files to your liking and run:

```
$ zsh setup.sh
```
