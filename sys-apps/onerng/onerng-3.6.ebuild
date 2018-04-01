# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit python-r1 udev

DESCRIPTION="Software for the Open Hardware Random Number Generator called OneRNG"
HOMEPAGE="https://www.onerng.info/"
SRC_URI="https://github.com/OneRNG/onerng.github.io/raw/master/sw/${PN}_${PV}.orig.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-crypt/gnupg
	dev-python/python-gnupg[${PYTHON_USEDEP}]
	sys-apps/rng-tools
	sys-process/at
	virtual/udev"

DEPEND="virtual/pkgconfig
	virtual/udev"

S="${WORKDIR}/${PN}_${PV}"

src_install() {
	# Set docs
	local DOCS=( "AUTHORS" "ChangeLog" "INSTALL" "NEWS" "README" )

	# Run default
	default
}

pkg_postinst() {
	# Reload UDEV rules after install
	udev_reload
}

pkg_postrm() {
	# Reload UDEV rules after uninstall
	udev_reload
}
