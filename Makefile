# =======================================================
# Constants
# =======================================================

# =======================================================
# Default Target
# =======================================================

usage:

# =======================================================
# External Target
# =======================================================

raspbian-lite: vagrant-up
	vagrant ssh -c "cd /data; make _raspbian-lite"

vagrant-up:
	if [ "$(vagrant status | grep running)" = "" ]; then vagrant up; fi

# =======================================================
# Internal Constants
# =======================================================

# =======================================================
# Internal Target
# =======================================================

_raspbian-lite: _raspbian-lite-build _raspbian-lite-image-build

_raspbian-lite-build: 
	sudo bash ./scripts/build/raspbian/rootfs.sh
	bash ./scripts/build/raspbian/stage0.sh
	bash ./scripts/build/raspbian/stage1.sh
	bash ./scripts/build/raspbian/stage2.sh

_raspbian-lite-image-build:
	sudo bash ./scripts/image-build/pre_build.sh raspbian:stage2
	sudo bash ./scripts/image-build/build.sh raspbian:stage2
	bash ./scripts/image-build/post_build.sh raspbian-lite.img