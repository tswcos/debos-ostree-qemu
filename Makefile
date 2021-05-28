FILESYSTEM?=ext4
FSUUID:=$(shell uuidgen)

build_qemu_img:
	docker run --rm --interactive --tty --device /dev/kvm \
		--user $(shell id -u) --workdir /recipes \
		--mount "type=bind,source=$(shell pwd),destination=/recipes" \
		--security-opt label=disable godebos/debos \
		--print-recipe \
		-t filesystem:$(FILESYSTEM) \
		-t fsuuid:$(FSUUID) \
		fsuuid.yaml
	@echo "FSUUID used: $(FSUUID)"

build_qemu_img_ext2:
	make build_qemu_img FILESYSTEM=ext2

build_qemu_img_ext3:
	make build_qemu_img FILESYSTEM=ext3

build_qemu_img_ext4:
	make build_qemu_img FILESYSTEM=ext4

build_qemu_img_btrfs:
	make build_qemu_img FILESYSTEM=btrfs

build_qemu_img_xfs:
	make build_qemu_img FILESYSTEM=xfs

run_qemu_img:
	qemu-system-x86_64 \
		-m 1G \
		-device virtio-scsi-pci \
		-device scsi-hd,drive=hd0 \
		-blockdev driver=file,node-name=hd0,filename=qemu-$(FILESYSTEM).img \
		-device e1000,netdev=net0 \
		-netdev user,hostfwd=tcp:127.0.0.1:5555-:22,id=net0,hostfwd=tcp:127.0.0.1:2159-:2159 \
		-nographic -serial mon:stdio

run_qemu_img_ext2:
	make run_qemu_img FILESYSTEM=ext2

run_qemu_img_ext3:
	make run_qemu_img FILESYSTEM=ext3

run_qemu_img_ext4:
	make run_qemu_img FILESYSTEM=ext4

run_qemu_img_btrfs:
	make run_qemu_img FILESYSTEM=btrfs

run_qemu_img_xfs:
	make run_qemu_img FILESYSTEM=xfs

