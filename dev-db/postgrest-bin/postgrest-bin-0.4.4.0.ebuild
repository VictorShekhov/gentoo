# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user eutils systemd

MY_PN="${PN/-bin/}"

DESCRIPTION="PostgREST serves a fully RESTful API from existing PostgreSQL database (Binary)"
HOMEPAGE="https://postgrest.com"

uri() {
	echo "https://github.com/begriffs/postgrest/releases/download/v${PV}/${MY_PN}-v${PV}-ubuntu$1.tar.xz"
}

SRC_URI="
		x86? ( $(uri i386) )
		amd64? ( $(uri) )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	!dev-db/postgrest
	dev-db/postgresql"

QA_PREBUILT="/usr/bin/postgrest-bin"
QA_PRESTRIPPED="/usr/bin/postgrest-bin"

S=${WORKDIR}

USER_NAME="postgrest"

pkg_setup() {
	enewgroup ${USER_NAME}
	enewuser ${USER_NAME} -1 -1 -1  ${USER_NAME}
}

src_prepare() {
	default

	mv postgrest postgrest-bin || die
}

src_install() {
	dobin postgrest-bin
	dosym postgrest-bin /usr/bin/postgrest
	dodir /etc/${MY_PN}
	insinto /etc/${MY_PN}
	doins "${FILESDIR}/${MY_PN}.conf.sample"
	systemd_newunit "${FILESDIR}/systemd/${MY_PN}.service" "${MY_PN}@.service"
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
