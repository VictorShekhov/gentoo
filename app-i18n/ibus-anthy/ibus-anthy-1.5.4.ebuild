# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python2_7 )

inherit gnome2-utils ltprune python-single-r1

DESCRIPTION="Japanese Anthy engine for IBus"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
SRC_URI="https://github.com/ibus/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="deprecated nls"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	app-i18n/anthy
	app-i18n/ibus[python(+),${PYTHON_USEDEP}]
	deprecated? ( dev-python/pygtk )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	deprecated? ( dev-lang/swig )
	nls? ( sys-devel/gettext )"

src_configure() {
	econf \
		$(use_enable deprecated pygtk2-anthy) \
		$(use_enable nls) \
		--enable-private-png \
		--with-layout=default
}

src_install() {
	default
	prune_libtool_files --modules

	python_optimize
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update

	if ! has_version app-dicts/kasumi; then
		elog "app-dicts/kasumi is not required but probably useful for you."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
