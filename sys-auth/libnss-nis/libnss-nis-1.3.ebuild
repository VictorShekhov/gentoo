# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools multilib-minimal

DESCRIPTION="NSS module to provide NIS support"
HOMEPAGE="https://github.com/thkukuk/libnss_nis"
SRC_URI="https://github.com/thkukuk/libnss_nis/archive/libnss_nis-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+ BSD ISC"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	net-libs/libnsl:=[${MULTILIB_USEDEP}]
	net-libs/libtirpc:0=[${MULTILIB_USEDEP}]
	!<sys-libs/glibc-2.26
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/libnss_nis-libnss_nis-${PV}

PATCHES=(
	"${FILESDIR}/map_v4v6_address.patch"
)

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	local myconf=(
		--enable-shared
		--disable-static
		--libdir="${EPREFIX}/$(get_libdir)"
	)
	ECONF_SOURCE=${S} econf "${myconf[@]}"
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
