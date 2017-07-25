# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit findlib eutils

DESCRIPTION="A pure OCaml implementation of the DNS protocol"
HOMEPAGE="https://github.com/mirage/ocaml-dns https://mirage.io"
SRC_URI="https://github.com/mirage/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2 LGPL-2.1-with-linking-exception ISC"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=dev-lang/ocaml-4:=
	>=dev-ml/ocaml-base64-2.0.0:=
	>=dev-ml/ocaml-cstruct-3.0.2:=[ppx]
	dev-ml/ocaml-hashcons:=
	>=dev-ml/ocaml-ipaddr-2.6.0:=
	dev-ml/ocaml-re:=
	>=dev-ml/ocaml-uri-1.7.0:=
	dev-ml/result:=
	!dev-ml/odns
"
DEPEND="
	dev-ml/jbuilder
	dev-ml/opam
	${RDEPEND}
"

# Do not work
RESTRICT="test"

src_compile() {
	jbuilder build @install -p dns || die
}

src_test() {
	jbuilder runtest -p dns || die
}

src_install() {
	opam-installer -i \
		--prefix="${ED}/usr" \
		--libdir="${D}/$(ocamlc -where)" \
		--docdir="${ED}/usr/share/doc/${PF}" \
		dns.install || die
}
