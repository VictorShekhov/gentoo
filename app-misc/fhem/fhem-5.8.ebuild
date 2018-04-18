# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user

DESCRIPTION="A GPL'd perl server for house automation"
HOMEPAGE="https://www.fhem.de/"
SRC_URI="https://www.fhem.de/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE="doc"

RDEPEND="dev-perl/Crypt-CBC
	dev-perl/Device-SerialPort
	dev-perl/Digest-CRC
	dev-perl/JSON"

DEPEND="media-gfx/pngcrush"

QA_PREBUILT="opt/fhem/contrib/lcd4linux/fritzbox_dpf/lcd4linux
		opt/fhem/contrib/lcd4linux/rpi_dpf/lcd4linux"

pkg_setup() {
	# Create FHEM user and group
	enewgroup fhem
	enewuser fhem -1 -1 /opt/fhem fhem
}

src_prepare() {
	# Fix install path in Makefile
	sed -i -e 's,^\(BINDIR=\).*,\1'${D}/opt/fhem',' Makefile || die

	# Remove docs in Makefile, as they will be installed manually
	sed -i -e 's/docs//g' Makefile || die
	sed -i -e '/README_DEMO.txt/d' Makefile || die

	# Remove manpage in Makefile, as it will be installed manually
	sed -i -e '/fhem.pl.1/d' Makefile || die

	# Remove log dir, as it will be replaced with a symlink
	rm -r log || die

	# Fix fhemicon_darksmall.png, as it reports "broken IDAT window length"
	pngcrush -fix -force -ow www/images/default/fhemicon_darksmall.png || die

	cp "${FILESDIR}"/fhem.cfg fhem.cfg || die

	eapply_user
}

src_compile() {
	# Nothing to compile
	return
}

src_install() {
	newinitd "${FILESDIR}"/fhem.initd fhem
	newconfd "${FILESDIR}"/fhem.confd fhem

	local DOCS=( "CHANGED" "HISTORY" "README.SVN" "README_DEMO.txt" "docs"/*.txt "docs"/*.patch "docs"/*.pdf "docs/changelog" "docs/copyright" "docs/dotconfig" "docs/fhem.odg.readme" "docs/LIESMICH.update-thirdparty" "docs"/README* "docs/X10" )
	if use doc; then
		local DOCS+=( "docs/X10" )
		local HTML_DOCS=( "docs/"*.eps "docs/"*.html "docs"/*.jpg "docs"/*.js "docs"/*.odg "docs/"*.png "docs/km271" )
	fi
	einstalldocs

	newman docs/fhem.man fhem.pl.1

	keepdir "/var/lib/fhem"
	keepdir "/var/log/fhem"

	dosym ../../var/log/fhem /opt/fhem/log
	dosym ../../var/lib/fhem /opt/fhem/data

	echo 'CONFIG_PROTECT="/opt/fhem /var/lib/fhem"' > "${T}"/99fhem || die
	doenvd "${T}"/99fhem

	emake install

	fperms +x /opt/fhem/fhem.pl
	fowners -R fhem:fhem /opt/fhem
	fowners fhem:fhem /var/lib/fhem
	fowners fhem:fhem /var/log/fhem
}
