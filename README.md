# Overview

This small example is aimed at testing the ability to set
the FSUUID of image-partition action in Debos

# Quickstart

Build an image for one of the file systems that allow
specifying the fsuuid in Debos. The UUID is generated
randomly using uuidgen
```
$ make build_qemu_img_[ext2|ext3|ext4|btrfs|xfs] FSUUID=$(uuidgen)
  [...]
  ==== Recipe done ====
  FSUUID used: 5e470a2e-5e5b-4cdd-83d0-1908f4283542
```

Run the image with QEMU (tested on Ubuntu 20) and
confirm what the same FSUUID is being used.
```
$ make run_qemu_img_[ext2|ext3|ext4|btrfs|xfs]
[Note] login with "root" (no password)
qemu# cat /etc/fstab
qemu# blkid /dev/sda1
```

# Providing a malformed FSUUID

You can test the verification function using malformed
FSUUID values.
```
$ make build_qemu_img_[ext2|ext3|ext4|btrfs|xfs] FSUUID=5e470a2e-5e5b-4cdd-83d0-1908f428354?
  Action `image-partition` failed at stage Verify, error: Incorrect UUID 5e470a2e-5e5b-4cdd-83d0-1908f428354?
```

