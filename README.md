# Overview

This small example is aimed at testing the ability to set
the file system UUID (FSUUID), partition table UUID (PTUUID)
and each partition's UUID (PARTUUID) using the image-partition
action in Debos.

# Quickstart

Build an image with default UUIDs. You can use any of the
supported file systems (ext2, ext3, ext4, btrfs, xfs).

```
$ make build_qemu_img_ext4
PTTYPE used: gpt
PTUUID used: 538d5afe-d9b8-46b3-b7d6-06fbaf53c305
BIOS_PARTUUID used: 8941d31f-7e36-482c-b974-79eac2d2594f
ROOTFS_PARTUUID used: 16fa1c5b-a617-4064-82a3-772e6b9323c0
DUMMY_VFAT_PARTUUID used: 88fb226d-ed8f-43a1-b432-664aa7758071
BIOS_FSUUID used: 5e5de9af
ROOTFS_FSUUID used: 10ee6979-52b6-4dab-a8e4-dfa2868645be
DUMMY_VFAT_FSUUID used: 5e5de9af
```

Next, boot the image in QEMU (tested on Ubuntu 20.04) and
confirm the image uses the default UUIDs.

```
$ make run_qemu_img_ext4
[Note] login with "root" (no password)

root@qemu:~# blkid /dev/sda*
/dev/sda: PTUUID="538d5afe-d9b8-46b3-b7d6-06fbaf53c305" PTTYPE="gpt"
/dev/sda1: PARTLABEL="BIOS" PARTUUID="8941d31f-7e36-482c-b974-79eac2d2594f"
/dev/sda2: LABEL="ROOTFS" UUID="10ee6979-52b6-4dab-a8e4-dfa2868645be" TYPE="ext4" PARTLABEL="ROOTFS" PARTUUID="16fa1c5b-a617-4064-82a3-772e6b9323c0"
/dev/sda3: LABEL_FATBOOT="FAT" LABEL="FAT" UUID="5E5D-E9AF" TYPE="vfat" PARTLABEL="FAT" PARTUUID="88fb226d-ed8f-43a1-b432-664aa7758071"
```

# Modifying the default settings

You can use a `msdos` partition table instead of `gpt`.

```
$ make build_qemu_img_ext4 PTTYPE=msdos PTUUID=1234ABCD
```

You can also change the default UUIDs as follows.

```
$ make build_qemu_img_ext4 \
    PTUUID=$(uuidgen) \
    BIOS_PARTUUID=$(uuidgen) \
    BIOS_FSUUID=9876FEDC \
    ROOTFS_PARTUUID=$(uuidgen) \
    ROOTFS_FSUUID=$(uuidgen)
```

# Providing a malformed FSUUID

You can test the verification function using malformed
FSUUID values.
```
$ make build_qemu_img_[ext2|ext3|ext4|btrfs|xfs] FSUUID=5e470a2e-5e5b-4cdd-83d0-1908f428354?
  Action `image-partition` failed at stage Verify, error: Incorrect UUID 5e470a2e-5e5b-4cdd-83d0-1908f428354?
```

# Support ostree
## Prepare debos image with ostree installed

```diff
diff --git a/docker/Dockerfile b/docker/Dockerfile
index 22adbaf..d07b29a 100644
--- a/docker/Dockerfile
+++ b/docker/Dockerfile
@@ -72,6 +72,7 @@ RUN apt-get update && \
         libslirp-helper \
         linux-image-amd64 \
         openssh-client \
+        ostree \
         parted \
         pkg-config \
         qemu-system-x86 \
--
2.30.2
```

## Build an image

```
$ make build_qemu_img_ext4
```
Boot image and check ostree support

```
$ make run_qemu_img_ext4

Debian GNU/Linux 11 qemu ttyS0

qemu login: root

# ostree log master
commit 8cd0637aa827c99e017119ca6f947b6e87c45b08bda08d65d3fa33db1fadbc77
ContentChecksum:  1959dc1dbe2d8f93f6992ad25f61d69e76a4edae260b2a2ce746bc7486c0ef0b
Date:  2023-03-20 04:12:38 +0000

    Commit rootfs
```
