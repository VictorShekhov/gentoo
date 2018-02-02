# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
CMAKE_MAKEFILE_GENERATOR="emake"

inherit cmake-utils

MY_P="${P}-Source"

DESCRIPTION="Chinese Chewing engine for IBus"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
SRC_URI="https://github.com/definite/${PN}/releases/download/${PV}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="app-i18n/ibus
	app-i18n/libchewing
	dev-libs/glib:2
	dev-util/gob:2
	gnome-base/gconf
	x11-libs/gtk+:2
	x11-libs/libX11
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"
S="${WORKDIR}/${MY_P}"

DOCS=( AUTHORS ChangeLog README RELEASE-NOTES.txt USER-GUIDE )

src_configure() {
	local mycmakeargs=(
		-DPRJ_DOC_DIR="${EPREFIX}"/usr/share/doc/${PF}
	)
	use nls || mycmakeargs+=( -DMANAGE_GETTEXT_SUPPORT=0 )
	cmake-utils_src_configure
}
