# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="A WhatsApp XMPP Gateway based on Spectrum 2 and Yowsup 2."
HOMEPAGE="https://github.com/stv0g/transwhat"
SRC_URI="https://github.com/stv0g/transwhat/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/e4u[${PYTHON_USEDEP}]
	dev-python/protobuf-python[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	net-im/yowsup2[${PYTHON_USEDEP}]"
DEPEND="${DEPEND}"

DOCS=( "INSTALL.rst" "README.rst" "USAGE.rst" )

src_prepare() {
	# Move config.py into 'Spectrum2'
	mv config.py Spectrum2/config.py

	# Fix import for net-im/spectrum2
	sed -i -e 's/config import SpectrumConfig/Spectrum2.config import SpectrumConfig/' transWhat/transwhat.py

	# Apply user patches
	eapply_user
}
