# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils kodi-addon

DESCRIPTION="Kodi's DVBLink client addon"
HOMEPAGE="https://github.com/kodi-pvr/pvr.dvblink"
SRC_URI=""

case ${PV} in
9999)
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/kodi-pvr/pvr.dvblink.git"
	inherit git-r3
	;;
*)
	CODENAME="Krypton"
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/kodi-pvr/pvr.dvblink/archive/${PV}-${CODENAME}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/pvr.dvblink-${PV}-${CODENAME}"
	;;
esac

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="
	=media-tv/kodi-17*
	=media-libs/kodi-platform-17*
	dev-libs/tinyxml2
	"

RDEPEND="
	${DEPEND}
	"
