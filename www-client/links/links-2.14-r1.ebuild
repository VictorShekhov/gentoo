# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools desktop xdg

DEBIAN_REVISION=2.10-2

DESCRIPTION="A fast and lightweight web browser running in both graphics and text mode"
HOMEPAGE="http://links.twibright.com/"
SRC_URI="http://${PN}.twibright.com/download/${P}.tar.bz2
	mirror://debian/pool/main/${PN:0:1}/${PN}2/${PN}2_${DEBIAN_REVISION}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm ~arm64 ~hppa ia64 ~mips ppc ~ppc64 ~s390 ~sh sparc x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 fbcon gpm ipv6 jpeg libevent libressl livecd lzma ssl suid svga tiff unicode X zlib"

GRAPHICS_DEPEND="media-libs/libpng:0="

RDEPEND="
	bzip2? (
		app-arch/bzip2
	)
	fbcon? (
		${GRAPHICS_DEPEND}
	)
	gpm? (
		sys-libs/gpm
	)
	jpeg? (
		virtual/jpeg:0
	)
	libevent? (
		dev-libs/libevent:0=
	)
	livecd? (
		${GRAPHICS_DEPEND}
		sys-libs/gpm
		virtual/jpeg:0
	)
	lzma? (
		app-arch/xz-utils
	)
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	svga? (
		${GRAPHICS_DEPEND}
		media-libs/svgalib
	)
	tiff? (
		media-libs/tiff:0
	)
	X? (
		${GRAPHICS_DEPEND}
		x11-libs/libXext
	)
	zlib? (
		sys-libs/zlib
	)"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	fbcon? ( virtual/os-headers )
	livecd? ( virtual/os-headers )"

REQUIRED_USE="!livecd? ( fbcon? ( gpm ) )
	svga? ( suid )"

DOCS=( AUTHORS BRAILLE_HOWTO ChangeLog KEYS NEWS README SITES )

src_prepare() {
	xdg_src_prepare

	if use unicode; then
		pushd intl > /dev/null || die
		./gen-intl || die
		./synclang || die
		popd > /dev/null || die
	fi

	# error: conditional "am__fastdepCXX" was never defined (for eautoreconf)
	sed -i \
		-e '/AC_PROG_CXX/s:dnl ::' \
		-e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' \
		configure.in || die #467020

	# Upstream configure produced by broken autoconf-2.13. This also fixes
	# toolchain detection.
	mv configure.in configure.ac || die
	eautoreconf #131440 and #103483#c23
}

src_configure() {
	local myconf

	if use livecd; then
		export ac_cv_lib_gpm_Gpm_Open=yes
		myconf+=' --with-fb --with-libjpeg'
	else
		export ac_cv_lib_gpm_Gpm_Open=$(usex gpm)
	fi

	if use X || use fbcon || use svga || use livecd; then
		myconf+=' --enable-graphics'
	fi

	econf \
		--without-directfb \
		$(use_with ipv6) \
		$(use_with ssl) \
		$(use_with zlib) \
		$(use_with bzip2) \
		$(use_with lzma) \
		$(use_with svga svgalib) \
		$(use_with X x) \
		$(use_with fbcon fb) \
		$(use_with libevent) \
		$(use_with jpeg libjpeg) \
		$(use_with tiff libtiff) \
		${myconf}
}

src_install() {
	HTML_DOCS="doc/links_cal/*"
	default

	if use X; then
		newicon Links_logo.png links.png
		make_desktop_entry 'links -g %u' Links links 'Network;WebBrowser'
		local d="${ED}"/usr/share/applications
		echo 'MimeType=x-scheme-handler/http;' >> "${d}"/*.desktop || die
		if use ssl; then
			sed -i -e 's:x-scheme-handler/http;:&x-scheme-handler/https;:' \
			"${d}"/*.desktop || die
		fi
	fi

	use suid && fperms 4755 /usr/bin/links
}

pkg_preinst() {
	use X && xdg_pkg_preinst
}

pkg_postinst() {
	use X && xdg_pkg_postinst
}

pkg_postrm() {
	use X && xdg_pkg_postrm
}
