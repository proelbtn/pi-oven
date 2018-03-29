# PiOven

A tool for Raspberry Pi images.

## Difference of [RPi-Distro/pi-gen](https://github.com/RPi-Distro/pi-gen)

[RPi-Distro/pi-gen](https://github.com/RPi-Distro/pi-gen) is a very good tool to create Raspberry Pi image. but, This tool is Shellscript-based. so, It is very hard to read for me :<

so, I make this tool. This tool uses Docker to make rootfs. so, you can add extra configuration more easily. and because it uses docker, second build is very fast.

## Requirement

- Vagrant

## How to build

```
$ make raspbian-lite
```

After a while, the build is complete and you can see ./build/raspbian-lite.img.