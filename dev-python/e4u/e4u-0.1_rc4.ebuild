# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 eapi7-ver

MY_PV="$(ver_rs 2 '' )"

DESCRIPTION="It's the bundle library for emoji4unicode"
HOMEPAGE="https://github.com/lambdalisue/e4u"
SRC_URI="https://github.com/lambdalisue/e4u/archive/0.1rc4.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/beautifulsoup:python-2[${PYTHON_USEDEP}]"

DEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${MY_PV}"

DOCS=( README.rst )
