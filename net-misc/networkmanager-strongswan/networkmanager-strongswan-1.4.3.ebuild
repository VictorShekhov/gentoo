# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P=${P/networkmanager/NetworkManager}

DESCRIPTION="NetworkManager StrongSwan plugin"
HOMEPAGE="https://www.strongswan.org/"
SRC_URI="https://download.strongswan.org/NetworkManager/${MY_P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="glib"

RDEPEND="net-misc/networkmanager
	net-vpn/strongswan[networkmanager]"

DEPEND="dev-util/intltool
	virtual/pkgconfig
	${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	# Don't enable all warnings, as some are treated as errors
	local myconf="--disable-more-warnings"

	# Run configure
	econf \
		$(usex glib '' --without-libnm-glib) \
		${myconf}
}
