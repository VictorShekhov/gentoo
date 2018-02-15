# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit elisp

DESCRIPTION="An Emacs minor mode for highlighting broken formatting rules"
HOMEPAGE="https://www.jpl.org/ftp/pub/elisp/
	https://www.emacswiki.org/emacs/DevelockMode"
# taken from http://www.jpl.org/ftp/pub/elisp/${PN}.el.gz
SRC_URI="https://dev.gentoo.org/~ulm/distfiles/${P}.el.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"

SITEFILE="50${PN}-gentoo.el"
