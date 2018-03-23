# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 gnome2-utils xdg-utils

DESCRIPTION="GUI app that can merge or split pdfs and rotate, crop and rearrange their pages"
HOMEPAGE="https://sourceforge.net/projects/pdfshuffler/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="|| ( dev-python/PyPDF2 dev-python/pyPdf )
	dev-python/python-poppler"
RDEPEND="${DEPEND}"

DOCS="ChangeLog README TODO AUTHORS"
PATCHES=( "${FILESDIR}"/${PN}-0.6.0-PyPDF2.patch )

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
