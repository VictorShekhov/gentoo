# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit scons-utils toolchain-funcs

DESCRIPTION="A C++ library for implementing XMPP applications"
HOMEPAGE="https://www.swift.im/"
SRC_URI="https://swift.im/downloads/releases/swift-${PV}/swift-${PV}.tar.gz"

LICENSE="BSD BSD-1 CC-BY-3.0 GPL-3 OFL-1.1"
SLOT="0/4"
KEYWORDS="~amd64 ~x86"
IUSE="avahi ccache debug distcc doc expat experimental icu idn optimize static upnp"

DEPEND="dev-db/sqlite
	dev-libs/boost
	dev-libs/openssl:0=
	sys-libs/zlib
	avahi? ( net-dns/avahi )
	ccache? ( dev-util/ccache )
	distcc? ( sys-devel/distcc )
	doc? ( app-text/docbook-xsl-stylesheets
		app-text/docbook-xml-dtd:4.5 )
	expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	icu? ( dev-libs/icu )
	idn? ( net-dns/libidn )
	upnp? (	net-libs/libnatpmp
		net-libs/miniupnpc )"

RDEPEND="${DEPEND}"

S="${WORKDIR}/swift-${PV}"

src_prepare() {
	# Remove those directories, as the system libs are used
	rm -fr 3rdParty/Boost 3rdParty/DocBook 3rdParty/Expat 3rdParty/LibIDN 3rdParty/LibMiniUPnPc 3rdParty/LibNATPMP 3rdParty/Lua 3rdParty/OpenSSL 3rdParty/SCons 3rdParty/SQLite 3rdParty/Unbound 3rdParty/Zlib || die

	# Remove 'Limber', 'Slimber' and 'Sluift', when compiling headless
	rm -fr Limber Slimber Sluift || die

	# Apply user patches
	eapply_user
}

src_configure() {
	# Set options for 'SCons configuration' and configure project 'Swiften'
	MYSCONS=(
		ar="$(tc-getAR)"
		allow_warnings="$(usex debug yes no)"
		assertions="$(usex debug yes no)"
		build_examples="yes"
		boost_bundled_enable="false"
		boost_force_bundled="false"
		cc="$(tc-getCC)"
		ccache="$(usex ccache yes no)"
		ccflags="${CFLAGS}"
		coverage="$(usex debug yes no)"
		cxx="$(tc-getCXX)"
		cxxflags="${CXXFLAGS}"
		debug="$(usex debug yes no)"
		distcc="$(usex distcc yes no)"
		$(usex doc "docbook_xml=${EPREFIX}/usr/share/sgml/docbook/xml-dtd-4.5" "" )
		$(usex doc "docbook_xsl=${EPREFIX}/usr/share/sgml/docbook/xsl-stylesheets" "")
		experimental="$(usex experimental yes no)"
		experimental_ft="$(usex experimental yes no)"
		hunspell_enable="false"
		install_git_hooks="no"
		libidn_bundled_enable="false"
		libminiupnpc_force_bundled="false"
		libnatpmp_force_bundled="false"
		link="$(tc-getCXX)"
		linkflags="${LDFLAGS}"
		max_jobs="yes"
		optimize="$(usex optimize yes no)"
		qt5="false"
		swiften_dll="$(usex static false true)"
		swift_mobile="no"
		target="native"
		test="none"
		try_avahi="$(usex avahi true false)"
		try_expat="$(usex expat true false)"
		try_gconf="false"
		try_libidn="$(usex idn true false)"
		try_libxml="$(usex expat false true)"
		tls_backend="openssl"
		unbound="no"
		valgrind="no"
		zlib_bundled_enable="false"
		Swiften
	)
}

src_compile() {
	# Run 'SCons compiler' and compile project 'Swiften'
	escons "${MYSCONS[@]}" PROJECTS="Swiften" Swiften
}

src_install() {
	# Run 'Scons installer'
	escons "${MYSCONS[@]}" SWIFTEN_INSTALLDIR="${D}/usr" SWIFTEN_LIBDIR="${D}/usr/$(get_libdir)" "${D}/usr" Swiften
}
