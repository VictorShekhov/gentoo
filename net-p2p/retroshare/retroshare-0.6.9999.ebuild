# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/RetroShare/RetroShare.git"
inherit eutils git-r3 gnome2-utils qmake-utils versionator

DESCRIPTION="P2P private sharing application"
HOMEPAGE="http://retroshare.net"

# pegmarkdown can also be used with MIT
LICENSE="GPL-2 GPL-3 Apache-2.0 LGPL-2.1"
SLOT="0"
KEYWORDS=""

IUSE="cli control-socket gnome-keyring +gui settings-api +sqlcipher +webui"
REQUIRED_USE="
	|| ( cli gui )
	settings-api? ( || ( control-socket webui ) )"

RDEPEND="
	app-arch/bzip2
	dev-libs/openssl:0=
	net-libs/libupnp:0=
	sys-libs/zlib
	sqlcipher? ( dev-db/sqlcipher )
	!sqlcipher? ( dev-db/sqlite )
	control-socket? ( dev-qt/qtnetwork:5 )
	settings-api? ( dev-qt/qtcore:5 )
	webui? ( net-libs/libmicrohttpd )
	gnome-keyring? ( gnome-base/libgnome-keyring )
	gui? (
		dev-qt/qtcore:5
		dev-qt/qtmultimedia:5
		dev-qt/qtnetwork:5
		dev-qt/qtprintsupport:5
		dev-qt/qtscript:5
		dev-qt/qtxml:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
		x11-libs/libX11
		x11-libs/libXScrnSaver
	)"
DEPEND="${RDEPEND}
	gui? ( dev-qt/designer:5 )
	dev-qt/qtcore:5
	virtual/pkgconfig
"

src_configure() {
	local qFlags=""
	use cli && qFlags="${qFlags} CONFIG+=retroshare_nogui" || qFlags="${qFlags} CONFIG+=no_retroshare_nogui"
	use control-socket && qFlags="${qFlags} CONFIG+=libresapilocalserver"
	use gnome-keyring && qFlags="${qFlags} CONFIG+=rs_autologin"
	use gui && qFlags="${qFlags} CONFIG+=retroshare_gui" || qFlags="${qFlags} CONFIG+=no_retroshare_gui"
	use settings-api && qFlags="${qFlags} CONFIG+=libresapi_settings"
	use sqlcipher && qFlags="${qFlags} CONFIG+=sqlcipher" || qFlags="${qFlags} CONFIG+=no_sqlcipher"
	use webui && qFlags="${qFlags} CONFIG+=libresapihttpserver" || qFlags="${qFlags} CONFIG+=no_libresapihttpserver"

	eqmake5 ${qFlags}
}

src_install() {
	use cli && dobin retroshare-nogui/src/retroshare-nogui
	use gui && dobin retroshare-gui/src/retroshare

	insinto /usr/share/retroshare
	doins libbitdht/src/bitdht/bdboot.txt

	use webui && doins -r libresapi/src/webui

	dodoc README.md
	make_desktop_entry retroshare

	for i in 24 48 64 128 ; do
		doicon -s ${i} "data/${i}x${i}/apps/retroshare.png"
	done
}

pkg_preinst() {
	local ver
	for ver in ${REPLACING_VERSIONS}; do
		if ! version_is_at_least 0.5.9999 ${ver}; then
			ewarn "You are upgrading from Retroshare 0.5.* to ${PV}"
			ewarn "Version 0.6.* is backward-incompatible with 0.5 branch"
			ewarn "and clients with 0.6.* can not connect to clients that have 0.5.*"
			ewarn "It's recommended to drop all your configuration and either"
			ewarn "generate a new certificate or import existing from a backup"
			break
		fi
		if version_is_at_least 0.6.0 ${ver} && ! version_is_at_least 0.6.4 ${ver}; then
			elog "Main executable has been renamed upstream from RetroShare06 to retroshare"
			break
		fi
	done

	if ! use sqlcipher; then
		ewarn "You have disabled GXS database encryption, ${PN} will use SQLite"
		ewarn "instead of SQLCipher for GXS databases."
		ewarn "Builds using SQLite and builds using SQLCipher have incompatible"
		ewarn "database format, so you will need to manually delete GXS"
		ewarn "database (loosing all your GXS data and identities) when you"
		ewarn "toggle sqlcipher USE flag."
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
