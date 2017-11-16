# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python2_7 )
VALA_USE_DEPEND="vapigen"

inherit autotools bash-completion-r1 gnome2-utils ltprune python-single-r1 vala virtualx

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="deprecated gconf gtk +gtk3 +introspection nls +python test vala wayland +X"
RESTRICT="test"
REQUIRED_USE="|| ( gtk gtk3 X )
	deprecated? ( python )
	vala? ( introspection )
	python? (
		${PYTHON_REQUIRED_USE}
		|| ( deprecated ( gtk3 introspection ) ) )" #342903

CDEPEND="app-text/iso-codes
	dev-libs/glib:2
	gnome-base/dconf
	gnome-base/librsvg:2
	sys-apps/dbus[X?]
	x11-libs/libnotify
	gconf? ( gnome-base/gconf:2 )
	gtk? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	introspection? ( dev-libs/gobject-introspection )
	nls? ( virtual/libintl )
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	)
	wayland? (
		dev-libs/wayland
		x11-libs/libxkbcommon
	)
	X? (
		|| (
			x11-libs/gtk+:3
			x11-libs/gtk+:2
		)
		x11-libs/libX11
	)"
RDEPEND="${CDEPEND}
	python? (
		deprecated? (
			dev-python/dbus-python[${PYTHON_USEDEP}]
			dev-python/pygtk:2[${PYTHON_USEDEP}]
		)
		gtk3? (
			x11-libs/gtk+:3[introspection]
		)
	)"
DEPEND="${CDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	vala? ( $(vala_depend) )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	use vala && vala_src_prepare

	sed -i "/^bash_completion/d" tools/Makefile.am

	default
	eautoreconf
}

src_configure() {
	local python_conf=()
	if use python; then
		python_conf+=(
			$(use_enable deprecated python-library)
			$(use_enable gtk3 setup)
			--with-python=${EPYTHON}
		)
	else
		python_conf+=( --disable-setup )
	fi

	econf \
		$(use_enable gconf) \
		$(use_enable gtk gtk2) \
		$(use_enable gtk3 ui) \
		$(use_enable gtk3) \
		$(use_enable introspection) \
		$(use_enable nls) \
		$(use_enable test tests) \
		$(use_enable vala) \
		$(use_enable wayland) \
		$(use_enable X xim) \
		--disable-emoji-dict \
		"${python_conf[@]}"
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	virtx emake -j1 check
}

src_install() {
	default
	prune_libtool_files --modules

	keepdir /usr/share/ibus/engine

	newbashcomp tools/${PN}.bash ${PN}

	insinto /etc/X11/xinit/xinput.d
	newins xinput-${PN} ${PN}.conf
}

pkg_preinst() {
	use gconf && gnome2_gconf_savelist
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	use gconf && gnome2_gconf_install
	use gtk && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	use gtk && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
	gnome2_icon_cache_update
	gnome2_schemas_update
}
