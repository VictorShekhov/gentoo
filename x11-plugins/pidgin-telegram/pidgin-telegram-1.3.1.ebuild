# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A libpurple protocol plugin that adds support for the Telegram messenger"
HOMEPAGE="https://github.com/majn/telegram-purple"
SRC_URI="https://github.com/majn/telegram-purple/releases/download/v${PV}/telegram-purple_${PV}.orig.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+gcrypt +icons +nls +webp +zlib"

RDEPEND="net-im/pidgin
	gcrypt? ( dev-libs/libgcrypt:0= )
	!gcrypt? ( dev-libs/openssl:0= )
	nls? ( sys-devel/gettext )
	webp? ( media-libs/libwebp )
	zlib? ( sys-libs/zlib )"

DEPEND="${RDEPEND}"

S="${WORKDIR}/telegram-purple"

src_prepare() {
	# Set file for removing '-Werror'
	local WERROR_FILES=( "Makefile.mingw" "Makefile.tgl.mingw" "tgl/Makefile.in" "tgl/tl-parser/Makefile.in" )

	# Remove '-Werror' to make it compile
	local werror_file
	for werror_file in "${WERROR_FILES[@]}"; do
		sed -i -e 's/-Werror //' "${werror_file}" || die
	done

	# Apply user patches
	eapply_user
}

src_configure() {
	# Run 'configure'
	econf \
		$(use_enable gcrypt) \
		$(use_enable nls translation) \
		$(use_enable webp libwebp) \
		$(use_with zlib)
}

src_install() {
	# Set and install docs
	local DOCS=( "AUTHORS" "CHANGELOG.md" "HACKING.md" "HACKING.BUILD.md" "README.md" )
	einstalldocs

	# Install icons depending on users choice
	if ! use icons; then
		# Run 'make install'
		emake DESTDIR="${D}" noicon_install
	else
		# Run 'default'
		default
	fi
}
