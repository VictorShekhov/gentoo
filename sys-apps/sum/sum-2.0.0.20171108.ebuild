# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eapi7-ver

MY_DATE="$(ver_cut 4)"
MY_PV="$(ver_cut 1-3)"

DESCRIPTION="Updates the BIOS and IPMI firmware and system settings on Supermicro mainboards."
HOMEPAGE="https://www.supermicro.com"
SRC_URI="${PN}_${MY_PV}_Linux_x86_64_${MY_DATE}.tar.gz"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="supermicro"
SLOT="0"

RDEPEND="sys-apps/sum-driver"

RESTRICT="bindist fetch mirror strip"

S="${WORKDIR}/${PN}_${MY_PV}_Linux_x86_64"

QA_PREBUILT="opt/sum/sum"

pkg_nofetch() {
	elog "Please download ${A} from"
	elog "sftp://dataharbor.supermicro.com"
	elog "Username: dpguest\$ts"
	elog "Password: supermicro!@#"
	elog "and place it in your DISTDIR directory."
}

src_install() {
	# Install binary
	exeinto "/opt/sum"
	doexe "sum"

	# Install symlink
	dodir "/opt/bin"
	dosym "../sum/sum" "/opt/bin/sum"

	# Install docs
	local DOCS=( "ReleaseNote.txt" "SUM_UserGuide.pdf" "ExternalData"/*.txt )
	einstalldocs
}
