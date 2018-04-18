# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user eutils systemd git-r3

DESCRIPTION="PostgREST serves a fully RESTful API from any existing PostgreSQL database."
HOMEPAGE="https://postgrest.com"
EGIT_REPO_URI="https://github.com/begriffs/${PN}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-haskell/stack"
RDEPEND="!dev-db/postgrest-bin
	dev-db/postgresql
"

USER_NAME="postgrest"

pkg_setup() {
	enewgroup ${USER_NAME}
	enewuser ${USER_NAME} -1 -1 -1  ${USER_NAME}
}

src_compile() {
	stack build --system-ghc --copy-bins --local-bin-path "${S}" || die
}

src_install() {
	dobin ${PN}
	dodir /etc/${PN}
	insinto /etc/${PN}
	doins "${FILESDIR}/${PN}.conf.sample"
	systemd_newunit "${FILESDIR}/systemd/${PN}.service"  "${PN}@.service"
}

pkg_postinst() {
	elog
	elog "If you want to enable postgrest server when your system boots"
	elog "then create configuration file:"
	elog "    /etc/postgrest/*.conf"
	elog
	elog "And execute the following commands:"
	elog "$   systemctl enable postgrest@*.service"
	elog "$   systemctl start postgrest@*.service"
	elog
}
