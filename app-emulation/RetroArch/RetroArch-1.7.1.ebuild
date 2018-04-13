# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic

DESCRIPTION="RetroArch is a sophisticated libretro frontend for emulators, game engines and media players."
HOMEPAGE="http://retroarch.com/"
SRC_URI="https://github.com/libretro/RetroArch/archive/v1.7.1.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~ia64"
IUSE="+opengl +pulseaudio -alsa -sdl -X cg"

DEPEND="
	dev-libs/libxml2
	>=media-libs/freetype-2.8
	opengl? ( virtual/opengl )
	X? ( x11-libs/libX11 x11-apps/xinput )
	pulseaudio? ( media-sound/pulseaudio )
	alsa? ( media-sound/alsa-utils )
	sdl? ( media-libs/libsdl2 )"

RDEPEND="
	${DEPEND}
	x86? ( cg? ( media-gfx/nvidia-cg-toolkit ) )
	amd64? ( cg? ( media-gfx/nvidia-cg-toolkit ) )"

src_configure(){
	./configure
}

src_prepare(){
	append-cflags "-v"
	default
}
