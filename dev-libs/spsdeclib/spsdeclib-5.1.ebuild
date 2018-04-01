# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils unpacker

DESCRIPTION="Kryoflux SPS Decoder Library"
HOMEPAGE="https://www.kryoflux.com/"
SRC_URI="https://www.kryoflux.com/download/${PN}_${PV}_source.zip"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="Kryoflux-MAME"
SLOT="0"

DEPEND="app-arch/unzip"

S="${WORKDIR}/capsimg_source_linux_macosx/CAPSImg"

src_unpack() {
	# Unpack archive
	unpack ${A}

	# Unpacked ZIP-file contains two ZIP files
	unpack_zip capsimg_source_linux_macosx.zip
}

src_prepare() {
	# Respect users CFLAGS and CXXFLAGS
	sed -i -e '/CFLAGS="-Wall -Wno-sign-compare -Wno-missing-braces -Wno-parentheses -g ${CFLAGS}"/d' configure.in || die
	sed -i -e '/CXXFLAGS="${CFLAGS}  -fno-exceptions -fno-rtti -std=c++0x"/d' configure.in || die

	# Run autoconf
	mv configure.in configure.ac || die
	eautoconf

	# Fix permissions, as configure is not marked executable
	chmod +x configure || die

	# Fix symlinks
	eapply "${FILESDIR}"/${P}_add_symlink.patch

	# Apply user patches
	eapply_user
}

src_install() {
	# Set docs
	local DOCS=( "${WORKDIR}/DONATIONS.txt" "${WORKDIR}/HISTORY.txt" "${WORKDIR}/RELEASE.txt" )

	# Run default
	default
}
