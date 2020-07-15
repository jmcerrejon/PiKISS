#!/bin/bash
#
# Description : Vulkan driver (EXPERIMENTAL)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (15/Jul/20)
# Compatible  : Raspberry Pi 4
#
# Info		  : Thks to PI Labs
# Help		  : https://ninja-build.org/manual.html#ref_pool
# 			  : https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=276412&start=25#p1678723
# 			  : https://blogs.igalia.com/apinheiro/2020/06/v3dv-quick-guide-to-build-and-run-some-demos/
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

SOURCE_CODE_URL="https://gitlab.freedesktop.org/apinheiro/mesa.git"
CORES=$(nproc --all)

install() {
	echo -e "\nInstalling,...\n"
	cd "$HOME"/mesa_vulkan
	sudo ninja -C build install
	echo
	glxinfo -B
	echo "Done."
}

binary_only() {
	echo -e "\nInstalling deps...\n"
	sudo apt install -y ninja-build
	install
}

install_meson() {
	sudo apt-get remove -y meson
	echo -e "\nChecking if meson is installed...\n"
	if ! pip3 list | grep -F meson &>/dev/null; then
		sudo pip3 install meson --force-reinstall
	fi
}

install_full_deps() {
	echo -e "\nInstalling deps...\n"
	sudo apt-get install -y libxcb-randr0-dev libxrandr-dev \
		libxcb-xinerama0-dev libxinerama-dev libxcursor-dev \
		libxcb-cursor-dev libxkbcommon-dev xutils-dev \
		xutils-dev libpthread-stubs0-dev libpciaccess-dev \
		libffi-dev x11proto-xext-dev libxcb1-dev libxcb-*dev \
		bison flex libssl-dev libgnutls28-dev x11proto-dri2-dev \
		x11proto-dri3-dev libx11-dev libxcb-glx0-dev \
		libx11-xcb-dev libxext-dev libxdamage-dev libxfixes-dev \
		libva-dev x11proto-randr-dev x11proto-present-dev \
		libclc-dev libelf-dev git build-essential mesa-utils \
		libvulkan-dev ninja-build libvulkan1 python-mako \
		libdrm-dev libxshmfence-dev libxxf86vm-dev libwayland-dev \
		python3-mako wayland-protocols libwayland-egl-backend-dev \
		cmake libassimp-dev
	install_meson
}

clone_repo() {
	echo -e "\nCloning mesa repo...\n"
	cd "$HOME"
	git clone --single-branch --branch wip/igalia/v3dv "$SOURCE_CODE_URL" mesa_vulkan && cd "$_"
}

update_repo() {
	cd "$HOME"/mesa_vulkan
	git fetch --all
	git reset --hard origin/wip/igalia/v3dv
}

compile() {
	if [[ -d "$HOME"/mesa_vulkan ]]; then
		echo
		read -p "Directory exists. Do you want to update the repo & compile it again (y/N)? " response
		if [[ $response =~ [Yy] ]]; then
			echo -e "\nDownloading the latest changes...\n"
			update_repo
		else
			exitMessage
			return 1
		fi
	else
		install_full_deps
		clone_repo
	fi

	if [[ -d "$HOME"/mesa_vulkan/build ]]; then
		rm -rf "$HOME"/mesa_vulkan/build
	fi

	meson --prefix /usr -Dplatforms=x11,drm,surfaceless,wayland -Dvulkan-drivers=broadcom -Ddri-drivers= -Dgallium-drivers=v3d,kmsro,vc4,zink -Dbuildtype=release build
	echo -e "\nCompiling... Estimated time on Raspberry Pi 4 over USB/SSD drive (Not overclocked): ~12 min. \n"
	ninja -C build -j"${CORES}"
	install
}

upgrade_dist
compile
exitMessage
