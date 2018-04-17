# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_4 python3_5 python3_6 )

inherit distutils-r1

DESCRIPTION="Raspberry Pi Sense HAT python library"
HOMEPAGE="https://github.com/RPi-Distro/python-sense-hat"
SRC_URI="https://github.com/RPi-Distro/python-sense-hat/archive/v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~arm ~arm64"
LICENSE="GPL-2"
SLOT="0"

S="${WORKDIR}/python-${P}"

RDEPEND="dev-python/numpy
	dev-python/pillow
	dev-python/rtimulib
	dev-python/setuptools"

DEPEND="${RDEPEND}"
