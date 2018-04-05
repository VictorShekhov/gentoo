# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils

DESCRIPTION="A cross-platform IRC framework written with Qt"
HOMEPAGE="http://communi.github.io/"
SRC_URI="https://github.com/communi/libcommuni/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="benchmarks debug examples icu qml static tests +uchardet"

# Compiling with USE="examples" or USE="tests" is currently broken with dev-libs/icu
REQUIRED_USE="^^ ( icu uchardet )
		examples? ( uchardet )
		tests? ( uchardet )"

RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	icu? ( dev-libs/icu )
	uchardet? ( app-i18n/uchardet )"

DEPEND="${RDEPEND}"

src_configure() {
	# Run 'eqmake5' with users options
	# Option 'no_rpath' is needed for fixing the QA Notice
	eqmake5 libcommuni.pro \
		-config no_rpath
		-config $(usex benchmarks 'benchmarks' 'no_benchmarks') \
		-config $(usex debug 'debug' 'release') \
		-config $(usex examples 'examples' 'no_examples') \
		-config $(usex icu 'icu' 'no_icu') \
		-config $(usex qml 'install_imports' 'no_install_imports') \
		-config $(usex qml 'install_qml' 'no_install_qml') \
		-config $(usex tests 'tests' 'no_tests') \
		-config $(usex uchardet 'uchardet' 'no_uchardet') \
		$(usex static '-config static' '')
}

src_install() {
	# Run 'make install' with INSTALL_ROOT instead of DESTDIR
	emake install INSTALL_ROOT="${D}"
}
