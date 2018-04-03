# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="yowsup"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
PYTHON_REQ_USE="readline"

inherit distutils-r1

DESCRIPTION="A library that enables you to build applications which use the WhatsApp service"
HOMEPAGE="https://github.com/tgalal/yowsup"
SRC_URI="https://github.com/tgalal/yowsup/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-python/axolotl-curve25519[${PYTHON_USEDEP}]
	dev-python/configargparse[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/protobuf-python[${PYTHON_USEDEP}]
	dev-python/pycrypto[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	# Remove argparse as dependency, as it's built in
	sed -i -e "s/, 'argparse'//" setup.py || die

	# Allow newer version of dev-python/six
	sed -i -e 's/six==1.10/six>=1.10/' setup.py || die

	# Apply user patches
	eapply_user
}
