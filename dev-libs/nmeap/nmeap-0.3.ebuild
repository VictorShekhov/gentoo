# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Extensible NMEA-0183 (GPS) data parser in standard C"
HOMEPAGE="http://nmeap.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test-programs"

DEPEND="doc? ( app-doc/doxygen )"

src_prepare() {
	default

	# Repsect users CFLAGS and LDFLAGS for the static lib archive
	sed -i -e 's/CFLAGS/FLAGS/g' src/Makefile || die
	sed -i -e 's/-g -O0 -Werror -Wall/$(CFLAGS) $(LDFLAGS)/g' src/Makefile || die

	# Respect users CFLAGS and LDFLAGS for the test programs
	if use test-programs; then
		sed -i -e 's/-g -O0//g' tst/Makefile || die
		sed -i -e 's/-Wall -Werror/$(CFLAGS) $(LDFLAGS)/g' tst/Makefile || die
	fi

	# Silent output of Doxygen and update it, since it is quite old
	if use doc; then
		sed -i -e 's/QUIET.*/QUIET = YES/' Doxyfile || die
		doxygen -u Doxyfile || die
	fi

	# Only build those test programs, if a user wants it
	if ! use test-programs; then
		sed -i -e '/TST/d' Makefile || die
	fi
}

src_install() {
	insinto /usr/include
	doins inc/nmeap.h inc/nmeap_def.h

	insinto /usr/$(get_libdir)
	doins lib/libnmeap.a

	if use test-programs; then
		local number
		for number in {1..3}; do
			exeinto /usr/bin
			newexe tst/test$number nmeap-test$number
		done
	fi

	if use doc; then
		local HTML_DOCS=( "doc/tutorial.html" "doc/html" )
		doxygen Doxyfile || die
		einstalldocs
	fi
}
