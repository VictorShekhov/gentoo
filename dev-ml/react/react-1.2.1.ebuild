# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit opam

DESCRIPTION="OCaml module for functional reactive programming"
HOMEPAGE="http://erratique.ch/software/react https://github.com/dbuenzli/react"
SRC_URI="http://erratique.ch/software/react/releases/${P}.tbz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~x86-fbsd"
IUSE="test"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-ml/findlib
	>=dev-ml/topkg-0.9
"

src_compile() {
	ocaml pkg/pkg.ml build \
		--tests $(usex test 'true' 'false') \
		|| die
}

src_test() {
	ocaml pkg/pkg.ml test || die
}
