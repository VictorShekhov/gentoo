# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools versionator

MY_PV="$(delete_all_version_separators)"
SOURCES_NAME="linux-UFRII-drv-v${MY_PV}-uken"

DESCRIPTION="Common files for Canon drivers"
HOMEPAGE="https://www.canon-europe.com/support/products/imagerunner/imagerunner-1133.aspx?type=drivers&language=EN&os=LINUX"
SRC_URI="http://gdlp01.c-wss.com/gds/8/0100007658/04/${SOURCES_NAME}.tar.gz"

# GPL-2 License inside LICENSE-EN.txt files
LICENSE="Canon-UFR-II GPL-2 MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/libxml2
	gnome-base/libglade
	net-print/cups
	x11-libs/gtk+:2
"
DEPEND="${DEPEND}"

S="${WORKDIR}/${SOURCES_NAME}/Sources/${P/-lb-${PV}/-3.80}"

pkg_setup() {
	# Don't raise a fuss over pre-built binaries
	QA_PREBUILT="
		/usr/libexec/cups/filter/c3pldrv
		/usr/$(get_abi_LIBDIR x86)/libColorGear.so.0.0.0
		/usr/$(get_abi_LIBDIR x86)/libColorGearC.so.1.0.0
		/usr/$(get_abi_LIBDIR x86)/libc3pl.so.0.0.1
		/usr/$(get_abi_LIBDIR x86)/libcaepcm.so.1.0
		/usr/$(get_abi_LIBDIR x86)/libcaiousb.so.1.0.0
		/usr/$(get_abi_LIBDIR x86)/libcaiowrap.so.1.0.0
		/usr/$(get_abi_LIBDIR x86)/libcanon_slim.so.1.0.0
		/usr/$(get_libdir)/libcanonc3pl.so.1.0.0
	"
	QA_SONAME="
		/usr/$(get_abi_LIBDIR x86)/libcaiousb.so.1.0.0
	"
}

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}/${SOURCES_NAME}/Sources/" || die
	unpack ./${P/-lb-${PV}/-3.80}-1.tar.gz
}

change_dir() {
	for i in cngplp buftool backend; do
		cd "${i}" || die
		"${@}"
		cd "${S}" || die
	done
}

src_prepare() {
	default
	sed -i -e \
		"s:backenddir = \$(libdir)/cups/backend:backenddir = `cups-config --serverbin`/backend:" \
		backend/Makefile.am || die

	export "LIBS=-lgtk-x11-2.0 -lgobject-2.0 -lglib-2.0 -lgmodule-2.0"
	change_dir eautoreconf
}

src_configure() {
	change_dir econf
}

src_compile() {
	change_dir emake

	# Cannot be moved to 'change_dir' as it doesn't need eautoreconf
	( cd "${S}/c3plmod_ipc" && emake ) || die
}

src_install() {
	MAKEOPTS+=" -j1" default

	einstalldocs

	cd "${S}/c3plmod_ipc" || die
	dolib.so libcanonc3pl.so.1.0.0
	dosym libcanonc3pl.so.1.0.0 "/usr/$(get_libdir)/libcanonc3pl.so.1"
	dosym libcanonc3pl.so.1.0.0 "/usr/$(get_libdir)/libcanonc3pl.so"

	cd "${S}/data" || die
	insinto /usr/share/caepcm
	doins *

	ABI=x86
	cd "${S}/libs" || die
	exeinto $(cups-config --serverbin)/filter
	doexe c3pldrv
	dolib.so libcaepcm.so.1.0
	dosym libcaepcm.so.1.0 "/usr/$(get_libdir)/libcaepcm.so.1"
	dosym libcaepcm.so.1.0 "/usr/$(get_libdir)/libcaepcm.so"
	for lib in *.so.?.?.?; do
		dolib.so "${lib}"
		dosym "${lib}" "/usr/$(get_libdir)/${lib%.?.?}"
		dosym "${lib}" "/usr/$(get_libdir)/${lib%.?.?.?}"
	done

	# c3pldrv dlopens the absolute path /usr/lib/libc3pl.so :(
	if [[ "$(get_libdir)" != lib ]]; then
		dosym "../$(get_libdir)/libc3pl.so" /usr/lib/libc3pl.so
	fi
}
