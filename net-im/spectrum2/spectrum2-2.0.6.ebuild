# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils user

DESCRIPTION="An open source instant messaging transport"
HOMEPAGE="https://www.spectrum.im"
SRC_URI="https://github.com/SpectrumIM/spectrum2/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc frotz irc mysql postgres purple sms sqlite test twitter xmpp"
REQUIRED_USE="|| ( mysql postgres sqlite )"

DEPEND="dev-libs/boost
	dev-libs/expat
	dev-libs/libxml2
	dev-libs/log4cxx
	dev-libs/jsoncpp
	dev-libs/openssl:0=
	dev-libs/popt
	dev-libs/protobuf
	net-dns/libidn
	sys-libs/zlib
	doc? ( app-doc/doxygen )
	frotz? ( !games-engines/frotz )
	irc? ( net-im/libcommuni )
	mysql? ( || ( dev-db/mariadb-connector-c dev-db/mysql-connector-c ) )
	postgres? ( dev-db/postgresql:= )
	purple? ( dev-libs/glib
		dev-libs/libev
		net-im/pidgin )
	sms? ( app-mobilephone/smstools )
	sqlite? ( dev-db/sqlite )
	test? ( dev-util/cppunit )
	xmpp? ( net-im/swiften )"

RDEPEND="${DEPEND}"

pkg_setup() {
	# Create Spectrum2 user and group
	enewgroup spectrum
	enewuser spectrum -1 -1 /var/lib/spectrum2 spectrum
}

src_prepare() {
	# Patch for finding qt5 compiled libcommuni
	eapply "${FILESDIR}"/${P}-add_qt5_libcommuni.patch

	# Run 'cmake configure'
	cmake-utils_src_prepare
}

src_configure() {
	# If USE="debug", enable debug compilation
	if use debug; then
		CMAKE_BUILD_TYPE="Debug"
	fi

	# Translate USE flags into configure options
	local mycmakeargs=(
		-DENABLE_DOCS="$(usex doc ON OFF)" \
		-DENABLE_FROTZ="$(usex frotz ON OFF)" \
		-DENABLE_IRC="$(usex irc ON OFF)" \
		-DENABLE_MYSQL="$(usex mysql ON OFF)" \
		-DENABLE_PQXX="$(usex postgres ON OFF)" \
		-DENABLE_PURPLE="$(usex purple ON OFF)" \
		-DENABLE_SMSTOOLS3="$(usex sms ON OFF)" \
		-DENABLE_SQLITE3="$(usex sqlite ON OFF)" \
		-DENABLE_TESTS="$(usex test ON OFF)" \
		-DENABLE_TWITTER="$(usex twitter ON OFF)" \
		-DENABLE_XMPP="$(usex xmpp ON OFF)" \
		-DLIB_INSTALL_DIR="$(get_libdir)"
	)

	# Run 'cmake configure'
	cmake-utils_src_configure
}

src_install() {
	# Run 'cmake install'
	cmake-utils_src_install

	# Keep directories
	keepdir /var/log/spectrum2
	keepdir /var/lib/spectrum2

	# Install init script
	newinitd "${FILESDIR}"/spectrum2.initd spectrum2

	# Install docs
	einstalldocs

	# Set permissions
	fowners -R spectrum:spectrum /etc/spectrum2 /var/lib/spectrum2 /var/log/spectrum2
}
