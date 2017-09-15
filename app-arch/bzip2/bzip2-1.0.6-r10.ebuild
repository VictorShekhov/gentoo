# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic multilib-minimal toolchain-funcs

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"
SUSE_PV="${PV}.0.1"
SUSE_P="${PN}-${SUSE_PV}"
SRC_URI="http://ftp.suse.com/pub/people/sbrabec/bzip2/tarballs/${SUSE_P}.tar.gz"
S="${WORKDIR}/${SUSE_P}"

LICENSE="BZIP2"
SLOT="0/1" # subslot = SONAME
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="static static-libs"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.6-progress.patch
	"${FILESDIR}"/${PN}-1.0.4-POSIX-shell.patch #193365
	"${FILESDIR}"/${PN}-1.0.6-mingw.patch #393573
	"${FILESDIR}"/${PN}-1.0.6-CVE-2016-3189.patch #620466
)

DOCS=( manual.pdf NEWS README.autotools README README.XML.STUFF )
HTML_DOCS=( manual.html )

multilib_src_configure() {
	# use static && append-ldflags -static # doesn't seem to work...
	# fails at gen_usr_ldscript because adding -static to ldflags
	# prevents generation of libbz2.so

	ECONF_SOURCE="${S}" econf \
		$(use_enable static-libs static)
}

multilib_src_install() {
	emake DESTDIR="${E}" install
	gen_usr_ldscript -a bz2
}

multilib_src_install_all() {
	default
	find "${E}" -name '*.la' -delete || die
	mkdir -p "${ED}/bin" || die
	for i in bzip2$(get_exeext) bunzip2$(get_exeext) bzcat$(get_exeext); do
		mv "${ED}/usr/bin/$i" "${ED}/bin/" || die
	done
}
