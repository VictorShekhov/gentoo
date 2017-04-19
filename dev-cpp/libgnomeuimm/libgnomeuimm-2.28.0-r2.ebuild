# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GNOME_TARBALL_SUFFIX="bz2"
GCONF_DEBUG="no"

inherit flag-o-matic gnome2

DESCRIPTION="C++ bindings for libgnomeui"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.6"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="
	>=gnome-base/libgnomeui-2.7.1
	dev-cpp/glibmm
	>=dev-cpp/libgnomemm-2.16.0
	>=dev-cpp/libgnomecanvasmm-2.6
	>=dev-cpp/gconfmm-2.6
	>=dev-cpp/libglademm-2.4
	>=dev-cpp/gnome-vfsmm-2.16
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	append-cxxflags -std=c++11
	gnome2_src_prepare
}
