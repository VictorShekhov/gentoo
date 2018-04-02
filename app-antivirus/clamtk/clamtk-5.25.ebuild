# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PLOCALES="af ar ast az bg bs ca cs da de el_GR en_AU en_CA en_GB eo \
	es eu fi fo fr ga gl he hr hu id it ja km ko lo lt lv mr ms \
	nb nl nl_BE nn pa pl pt pt_BR ro ru si sk sl sr@latin sv ta \
	te th tr ug uk uz zh_CN zh_TW"

PLOCALE_BACKUP="en_GB"

inherit desktop l10n perl-functions xdg-utils

DESCRIPTION="A graphical front-end for ClamAV"
HOMEPAGE="https://dave-theunsub.github.io/clamtk/"
SRC_URI="https://bitbucket.org/davem_/clamtk/downloads/${P}.tar.xz"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="app-antivirus/clamav
	dev-perl/File-chdir
	dev-perl/Gtk2
	dev-perl/JSON
	dev-perl/LWP-Protocol-https
	dev-perl/LWP-UserAgent-Cached
	dev-perl/Locale-gettext
	dev-perl/Text-CSV
	dev-perl/glib-perl
	dev-perl/libwww-perl
	virtual/perl-Digest-MD5
	virtual/perl-Digest-SHA
	virtual/perl-Encode
	virtual/perl-MIME-Base64
	virtual/perl-Time-Piece"

DEPEND="nls? ( sys-devel/gettext )"

src_install() {
	# Install perl script
	dobin clamtk

	# Install perl modules
	perl_set_version
	insinto "${VENDOR_LIB}"/ClamTk
	doins lib/*.pm

	# Install locales
	if use nls; then
		l10n_for_each_locale_do src_install_locales
	fi

	# Install icons
	doicon images/clamtk.png images/clamtk.xpm

	# Install menu entry
	domenu clamtk.desktop

	# Install docs
	local DOCS=( "CHANGES" "DISCLAIMER" "README.md" )
	einstalldocs

	# Install man page
	gunzip clamtk.1.gz || die
	doman clamtk.1
}

src_install_locales() {
	# Install locales
	domo "po/${1}.mo";
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
