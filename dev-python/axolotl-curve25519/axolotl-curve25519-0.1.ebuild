# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="This is python wrapper for curve25519 library with ed25519 signatures."
HOMEPAGE="https://github.com/tgalal/python-axolotl-curve25519"
SRC_URI="https://pypi.python.org/packages/69/e0/9605cac4c83c12d0bef5c2e9992f0bcbce4fae9a252899d545ccb7dc8717/python-${P}.tar.gz" #md5=f28d902df9044f0bf86a35a4bd2ec092"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/axolotl[${PYTHON_USEDEP}]"

DEPEND="${RDEPEND}"

S="${WORKDIR}/python-${P}"
