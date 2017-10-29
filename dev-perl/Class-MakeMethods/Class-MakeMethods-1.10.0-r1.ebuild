# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

MODULE_AUTHOR=EVO
MODULE_VERSION=1.01
inherit perl-module

DESCRIPTION="Automated method creation module for Perl"

SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc s390 sh sparc x86 ~ppc-aix ~x86-solaris"
IUSE=""

PATCHES=( "${FILESDIR}/${P}-perl526.patch" )
SRC_TEST="do"
