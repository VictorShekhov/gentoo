# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils xdg-utils

DESCRIPTION="Graphical wireless scanning for Linux"
HOMEPAGE="https://sourceforge.net/projects/linssid/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-libs/boost
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	dev-qt/qtsvg:5
	x11-libs/qwt:6[opengl,qt5,svg]"

RDEPEND="${DEPEND}
	app-admin/sudo
	net-wireless/iw
	x11-libs/libxkbcommon[X]"

S="${WORKDIR}/${P}/${PN}-app"

src_prepare() {
	# Use system qwt for compiling
	sed -i -e 's/CONFIG += release/CONFIG += release qwt/' linssid-app.pro || die

	# Fix lib path for x11-libs/qwt
	sed -i -e "s/\/usr\/lib\/libqwt-qt5.so.6/\/usr\/$(get_libdir)\/libqwt6-qt5.so.6/" linssid-app.pro || die

	# Fix QA warnings for .desktop file
	# Change 'Categories', as 'Application' and 'Internet' should not be used
	# Remove 'Version', as it should not specify the package version, but desktop entry specification
	sed -i -e 's/Application\;Network\;Internet\;/Network\;System/' linssid.desktop || die
	sed -i -e '/Version=2.9/d' linssid.desktop || die

	# Apply user patches
	eapply_user
}

src_configure() {
	# Run 'qmake'
	eqmake5
}

src_install() {
	# Run 'make install' with INSTALL_ROOT instead of DESTDIR
	emake INSTALL_ROOT="${D}" install

	# Install docs
	local DOCS=( "INSTALL.txt" "README_${PV}" )
	einstalldocs
}

pkg_postinst() {
	# Update XDG on install
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	# Update XDG on uninstall
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
