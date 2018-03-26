# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_4 python3_5 python3_6 )

inherit distutils-r1

DESCRIPTION="Python Binding for RTIMULib, a versatile IMU library"
HOMEPAGE="https://github.com/RPi-Distro/RTIMULib"
SRC_URI="https://github.com/RPi-Distro/RTIMULib/archive/V${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="-* ~arm ~arm64"
LICENSE="GPL-2"
SLOT="0"

RDEPEND="dev-python/setuptools"

DEPEND="${RDEPEND}"

S="${WORKDIR}/RTIMULib-${PV}/Linux/python"
