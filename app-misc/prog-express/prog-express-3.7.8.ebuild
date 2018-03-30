# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop udev unpacker

DESCRIPTION="A modern and intuitive control software for the Batronix USB programming devices"
HOMEPAGE="https://www.batronix.com"
SRC_URI="amd64? ( https://www.batronix.com/exe/Batronix/Prog-Express/deb/${P}-1.amd64.deb )
	x86? ( https://www.batronix.com/exe/Batronix/Prog-Express/deb/${P}-1.i386.deb )"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="prog-express"
SLOT="0"

RDEPEND="dev-db/sqlite
	dev-dotnet/gtk-sharp
	dev-dotnet/libgdiplus
	dev-lang/mono
	dev-lang/mono-basic
	virtual/libusb:1
	virtual/udev"

RESTRICT="strip"

S="${WORKDIR}"

QA_PREBUILT="usr/bin/bxusb
	usr/bin/bxusb-gui
	usr/bin/prog-express
	usr/sbin/bxfxload"

src_unpack() {
	# Unpack Debian package
	unpack_deb ${A}
}

src_prepare() {
	# Fix lib path
	for file in bxusb bxusb-gui prog-express; do
		sed -i -e "s/lib/$(get_libdir)/g" usr/bin/${file} || die
	done

	# Apply user patches
	eapply_user
}

src_install() {
	# Install bin files
	dobin usr/bin/bxusb usr/bin/bxusb-gui usr/bin/prog-express

	# Install sbin files
	dosbin usr/sbin/bxfxload

	# Install lib files
	insinto /usr/$(get_libdir)
	doins -r usr/lib/bxusb usr/lib/prog-express

	# Install usb config
	insinto /usr/$(get_libdir)/prog-express
	doins "${FILESDIR}"/pe.exe.config

	# Install udev rule
	udev_dorules lib/udev/rules.d/85-batronix-devices.rules

	# Install menu entry
	domenu usr/share/applications/prog-express.desktop

	# Install icon
	doicon usr/share/pixmaps/prog-express.png

	# Install docs
	local DOCS=( "usr/share/doc/prog-express/changelog.gz" )
	dodoc -r usr/share/doc/prog-express/manuals
	einstalldocs

	# Install man pages
	gunzip usr/share/man/man1/*.gz || die
	doman usr/share/man/man1/bxfxload.1 usr/share/man/man1/bxusb.1 usr/share/man/man1/bxusb-gui.1 usr/share/man/man1/prog-express.1
}

pkg_postinst() {
	# Reload UDEV rules after install
	udev_reload
}

pkg_postrm() {
	# Reload UDEV rules after uninstall
	udev_reload
}
