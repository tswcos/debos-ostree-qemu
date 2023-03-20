PTTYPE?=msdos
PTUUID?=
BIOS_PARTUUID?=
BIOS_FSUUID?=
ROOTFS_PARTUUID?=
ROOTFS_FSUUID?=
ROOTFS_FILESYSTEM?=ext4
DUMMY_VFAT_PARTUUID?=
DUMMY_VFAT_FSUUID?=
DEBOS_IMAGE?=go/debos-ostree

.build_qemu_img:
	docker run --rm --interactive --tty --device /dev/kvm \
		--user $(shell id -u) --workdir /recipes \
		--mount "type=bind,source=$(shell pwd),destination=/recipes" \
		--security-opt label=disable $(DEBOS_IMAGE) \
		--print-recipe --debug-shell \
		-t partitiontype:$(PTTYPE) \
		-t ptuuid:$(PTUUID) \
		-t bios_partuuid:$(BIOS_PARTUUID) \
		-t bios_fsuuid:$(BIOS_FSUUID) \
		-t rootfs_partuuid:$(ROOTFS_PARTUUID) \
		-t rootfs_fsuuid:$(ROOTFS_FSUUID) \
		-t rootfs_filesystem:$(ROOTFS_FILESYSTEM) \
		uuids.yaml
	@echo "PTTYPE used: $(PTTYPE)"
	@echo "PTUUID used: $(PTUUID)"
	@if [ $(PTTYPE) = "gpt" ]; then \
		echo "BIOS_PARTUUID used: $(BIOS_PARTUUID)"; \
		echo "ROOTFS_PARTUUID used: $(ROOTFS_PARTUUID)"; \
	fi
	@echo "BIOS_FSUUID used: $(BIOS_FSUUID)"
	@echo "ROOTFS_FSUUID used: $(ROOTFS_FSUUID)"

build_qemu_img_ext2:
	make .build_qemu_img ROOTFS_FILESYSTEM=ext2

build_qemu_img_ext3:
	make .build_qemu_img ROOTFS_FILESYSTEM=ext3

build_qemu_img_ext4:
	make .build_qemu_img ROOTFS_FILESYSTEM=ext4

build_qemu_img_btrfs:
	make .build_qemu_img ROOTFS_FILESYSTEM=btrfs

build_qemu_img_xfs:
	make .build_qemu_img ROOTFS_FILESYSTEM=xfs

.run_qemu_img:
	qemu-system-x86_64 \
		-m 1G \
		-device virtio-scsi-pci \
		-device scsi-hd,drive=hd0 \
		-blockdev driver=file,node-name=hd0,filename=qemu-$(ROOTFS_FILESYSTEM).img \
		-device e1000,netdev=net0 \
		-netdev user,hostfwd=tcp:127.0.0.1:5555-:22,id=net0,hostfwd=tcp:127.0.0.1:2159-:2159 \
		-nographic -serial mon:stdio

run_qemu_img_ext2:
	make .run_qemu_img ROOTFS_FILESYSTEM=ext2

run_qemu_img_ext3:
	make .run_qemu_img ROOTFS_FILESYSTEM=ext3

run_qemu_img_ext4:
	make .run_qemu_img ROOTFS_FILESYSTEM=ext4

run_qemu_img_btrfs:
	make .run_qemu_img ROOTFS_FILESYSTEM=btrfs

run_qemu_img_xfs:
	make .run_qemu_img ROOTFS_FILESYSTEM=xfs

