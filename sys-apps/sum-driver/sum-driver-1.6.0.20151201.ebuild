# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eapi7-ver linux-mod

MY_DATE="$(ver_cut 4)"
MY_PN="${PN//-/_}"
MY_PV="$(ver_cut 1-3)"

DESCRIPTION="Supermicro Update Manager (SUM) kernel module"
HOMEPAGE="https://www.supermicro.com"
SRC_URI="${MY_PN}_V${MY_PV}_${MY_DATE}.tar.gz"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="supermicro"
SLOT="0"

RESTRICT="bindist fetch mirror strip"

S="${WORKDIR}"/${MY_PN}_V${MY_PV}/Linux

BUILD_TARGETS="clean default"
MODULE_NAMES="sum_bios(misc:${S})"

PATCHES=( "${FILESDIR}/makefile.patch" )

pkg_nofetch() {
	elog "Please download ${A} from"
	elog "sftp://dataharbor.supermicro.com"
	elog "Username: dpguest\$ts"
	elog "Password: supermicro!@#"
	elog "and place it in your DISTDIR directory."
}
