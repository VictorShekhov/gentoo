# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop udev unpacker xdg-utils

DESCRIPTION="KryoFlux Host Software"
HOMEPAGE="https://www.kryoflux.com"
SRC_URI="https://www.kryoflux.com/download/kryoflux_${PV}_linux.tar.bz2
	https://www.kryoflux.com/kryoflux-ui.jar"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="SPS"
SLOT="0"
IUSE="demos doc fast-firmware java static"

RDEPEND="dev-libs/spsdeclib
	virtual/libusb:1
	virtual/udev
	java? ( virtual/jre )"

RESTRICT="bindist mirror strip"

S="${WORKDIR}/kryoflux_${PV}_linux"

QA_PREBUILT="usr/bin/dtc
	usr/bin/dtc.static"

src_unpack() {
	# Unpack archive
	unpack kryoflux_${PV}_linux.tar.bz2

	# Updated *.jar for compatibility with >= Java 9
	if use java; then
		cp "${DISTDIR}"/kryoflux-ui.jar "${S}" || die
	fi

	# Extract kryoflux-ui.jar to get a logo for the meny entry
	unpack_zip kryoflux-ui.jar
}

src_install() {
	# Choose ARCH
	if use amd64; then
		local my_arch="x86_64"
	else
		local my_arch="i686"
	fi

	# Install binary
	if ! use static; then
		dobin dtc/${my_arch}/dynamic/dtc
	else
		dobin dtc/${my_arch}/static/dtc
	fi

	# Install udev rule
	echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="6124", GROUP="floppy", MODE="0660"' > "${T}"/80-kryoflux.rules || die
	udev_dorules "${T}"/80-kryoflux.rules

	# Install UI
	if use java; then
		# Install Java UI
		insinto /usr/share/kryoflux-ui
		doins kryoflux-ui.jar

		# Install icon
		newicon "${WORKDIR}"/images/disk.png kryoflux-ui.png

		# Install menu entry
		make_desktop_entry "/usr/bin/java -jar /usr/share/kryoflux-ui/kryoflux-ui.jar" "KryoFlux UI" /usr/share/pixmaps/kryoflux-ui.png Development

		# Install docs
		dodoc dtc/kryoflux-ui_README.txt
	fi

	# Install firmware
	if use fast-firmware; then
		# Install fast firmware
		insinto /lib/firmware
		doins dtc/firmware_fast/firmware_kf_usb_rosalie.bin

		# Install docs
		dodoc dtc/firmware_fast/firmware_fast_README.txt
	else
		# Install slow firmware
		insinto /lib/firmware
		doins dtc/firmware_kf_usb_rosalie.bin
	fi

	# Install demos
	if use demos; then
		dodoc -r g64_demo
		dodoc -r ipf_demo
	fi

	# Install addtional docs
	if use doc; then
		dodoc -r docs
		dodoc -r schematics

	fi

	# Install docs
	local DOCS=( "DONATIONS.txt" "RELEASE.txt" "README.linux" )
	einstalldocs
}

pkg_postinst() {
	elog "If you want to access your Kryoflux without root access,"
	elog "please add yourself to the floppy group."

	# Reload UDEV rules after install
	udev_reload

	# Warn about fast firmware
	if use fast-firmware; then
		elog ""
		elog "You have enabled the fast firmware. Please keep in mind,"
		elog "that this firmware can cause trouble with older floppy drives."
	fi

	# Update XDG on install
	if use java; then
		xdg_desktop_database_update
		xdg_mimeinfo_database_update
	fi
}

pkg_postrm() {
	# Reload UDEV rules after uninstall
	udev_reload

	# Update XDG on uninstall
	if use java; then
		xdg_desktop_database_update
		xdg_mimeinfo_database_update
	fi
}
