BUILD_DIR := ./build
OUT_DIR := ./out

IGNITION_FILES := $(shell find ignition-files/ -type f)
ENC_IGNITION_FILES := $(shell find ignition-files.enc/ -type f)

all: $(OUT_DIR)/ipxe.efi $(OUT_DIR)/coreos.initrd $(OUT_DIR)/coreos.kernel $(OUT_DIR)/coreos.rootfs

clean:
	rm -rf $(BUILD_DIR) $(OUT_DIR)

$(OUT_DIR)/coreos.kernel $(BUILD_DIR)/coreos.initrd $(OUT_DIR)/coreos.rootfs:
	mkdir -p $(BUILD_DIR) $(OUT_DIR)

	podman run --rm -v $(BUILD_DIR):/data -w /data quay.io/coreos/coreos-installer:release download -f pxe

	cp $(BUILD_DIR)/fedora-coreos-*-kernel-x86_64 $(OUT_DIR)/coreos.kernel
	cp $(BUILD_DIR)/fedora-coreos-*-rootfs.x86_64.img $(OUT_DIR)/coreos.rootfs

	cp $(BUILD_DIR)/fedora-coreos-*-initramfs.x86_64.img $(BUILD_DIR)/coreos.initrd

$(OUT_DIR)/coreos.initrd: $(BUILD_DIR)/coreos.initrd $(BUILD_DIR)/config.ign out
	rm -f $(OUT_DIR)/coreos.initrd
	podman run --rm -v $(BUILD_DIR):/build -v $(OUT_DIR):/out \
		quay.io/coreos/coreos-installer:release pxe customize --output /out/coreos.initrd --dest-ignition /build/config.ign --dest-device /dev/sda /build/coreos.initrd

$(BUILD_DIR)/config.ign: config.bu $(BUILD_DIR)/ignition-files build
	podman run --rm -i -v $(BUILD_DIR)/ignition-files:/files quay.io/coreos/butane:release \
		--pretty --strict -d /files < config.bu > $(BUILD_DIR)/config.ign

$(BUILD_DIR)/boot.ipxe: boot.ipxe ../boot-token
	@sed s/_TOKEN_/$(shell sops -d ../boot-token)/ < boot.ipxe > $@

$(OUT_DIR)/ipxe.efi: ipxe $(BUILD_DIR)/boot.ipxe out
	cd ipxe/src && $(MAKE) bin-x86_64-efi/ipxe.efi EMBED=$(realpath $(BUILD_DIR)/boot.ipxe)
	cp ipxe/src/bin-x86_64-efi/ipxe.efi $@

ipxe:
	git submodule update --init -- ipxe

$(BUILD_DIR)/ignition-files: $(IGNITION_FILES:%=$(BUILD_DIR)/%) $(ENC_IGNITION_FILES:%=$(BUILD_DIR)/%)
	cp -R $(BUILD_DIR)/ignition-files.enc/* $(BUILD_DIR)/ignition-files

$(BUILD_DIR)/ignition-files/%: ignition-files/%
	mkdir -p $(dir $@)
	cp $< $@

$(BUILD_DIR)/ignition-files.enc/%: ignition-files.enc/%
	mkdir -p $(dir $@)
	sops -d $< > $@
