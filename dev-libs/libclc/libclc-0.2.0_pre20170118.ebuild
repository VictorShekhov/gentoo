# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

EGIT_REPO_URI="http://llvm.org/git/${PN}.git
	https://github.com/llvm-mirror/${PN}.git"
EGIT_COMMIT="2ec7d80d5e1c96fb85c694cc6ac0a78faf01a614"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
else
	GIT_ECLASS="vcs-snapshot"
fi

inherit llvm python-any-r1 toolchain-funcs ${GIT_ECLASS}

DESCRIPTION="OpenCL C library"
HOMEPAGE="http://libclc.llvm.org/"

if [[ ${PV} = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="https://github.com/llvm-mirror/libclc/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
		${SRC_PATCHES}"
fi

LICENSE="|| ( MIT BSD )"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

RDEPEND="
	>=sys-devel/clang-4
	>=sys-devel/llvm-4"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}"

llvm_check_deps() {
	has_version "sys-devel/clang:${LLVM_SLOT}"
}

pkg_setup() {
	# we do not need llvm_pkg_setup
	python-any-r1_pkg_setup
}

src_configure() {
	./configure.py \
		--with-cxx-compiler="$(tc-getCXX)" \
		--with-llvm-config="$(get_llvm_prefix)/bin/llvm-config" \
		--prefix="${EPREFIX}/usr" || die
}

src_compile() {
	emake VERBOSE=1
}
