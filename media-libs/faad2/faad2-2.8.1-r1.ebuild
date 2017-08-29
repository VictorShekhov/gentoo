# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools ltprune multilib-minimal

DESCRIPTION="AAC audio decoding library"
HOMEPAGE="http://www.audiocoding.com/faad2.html"
SRC_URI="mirror://sourceforge/faac/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="digitalradio static-libs"
DOCS=( AUTHORS ChangeLog NEWS README README.linux TODO )
RDEPEND=""
DEPEND=""

PATCHES=(
	"${FILESDIR}"/${PN}-2.8.1-libmp4ff-shared-lib.patch
	"${FILESDIR}"/${P}-dummy_version_macro.patch
)

src_prepare() {
	default

	sed -i -e 's:iquote :I:' libfaad/Makefile.am || die

	# bug 466986
	sed -i 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' configure.ac || die

	eautoreconf
}

multilib_src_configure() {
	local myconf=(
		--without-xmms
		$(use_with digitalradio drm)
		$(use_enable static-libs static)
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"

	# do not build the frontend for non default abis
	if [ "${ABI}" != "${DEFAULT_ABI}" ] ; then
		sed -i -e 's/frontend//' Makefile || die
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
	einstalldocs
}
