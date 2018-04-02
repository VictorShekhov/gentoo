# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 gnome2-utils

DESCRIPTION="A lightweight user-configuration application"
HOMEPAGE="https://launchpad.net/mugshot"
SRC_URI="https://launchpad.net/${PN}/0.3/${PV}/+download/${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome libreoffice pidgin webcam"

RDEPEND="dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pexpect[${PYTHON_USEDEP}]
	dev-python/pycairo[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	sys-apps/accountsservice
	x11-libs/gtk+:3
	gnome? ( gnome-base/gnome-control-center )
	libreoffice? ( || ( app-office/libreoffice-bin app-office/libreoffice ) )
	pidgin? ( net-im/pidgin[${PYTHON_USEDEP}] )
	webcam? ( media-libs/gstreamer:1.0
		media-libs/gst-plugins-good:1.0
		gnome? ( media-libs/clutter-gtk[introspection]
			media-video/cheese[introspection] ) )"

DEPEND="${RDEPEND}
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	dev-util/intltool"

PATCHES=( "${FILESDIR}/${P}-missing_default_face.patch"
	"${FILESDIR}/${P}-use_office_phone.patch"
	"${FILESDIR}/${P}-fix_env_spawn_args.patch" )

pkg_postinst() {
	# Update glib schemas on install
	gnome2_schemas_update

	# Update icon cache in install
	gnome2_icon_cache_update
}

pkg_postrm() {
	# # Update glib schemas on uninstall
	gnome2_schemas_update

	# Update icon cache on uninstall
	gnome2_icon_cache_update
}
