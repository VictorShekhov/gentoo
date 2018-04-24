# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit udev

DESCRIPTION="Library to drive several displays with built-in controllers or display modules"
HOMEPAGE="http://serdisplib.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="deprecated dlo experimental sdl static-libs threads tools usb"

# Define the list of valid lcd devices.
IUSE_LCD_DEVICES=( acoolsdcm ddusbt directgfx displaylink framebuffer glcd2usb
	goldelox i2c ks0108 l4m lc7981 lh155 nokcol pcd8544
	remote rs232 sed133x sed153x sed156x ssdoled stv8105 t6963 )

# Add supported drivers from 'IUSE_LCD_DEVICES' to 'IUSE' and 'REQUIRED_USE'
IUSE="${IUSE} $(printf 'lcd_devices_%s ' ${IUSE_LCD_DEVICES[@]})"
REQUIRED_USE="${REQUIRED_USE} || ( $(printf 'lcd_devices_%s ' ${IUSE_LCD_DEVICES[@]}) )"

# Specific drivers will need some features to be enabled
REQUIRED_USE="${REQUIRED_USE}
	lcd_devices_acoolsdcm? ( usb )
	lcd_devices_directgfx? ( sdl )
	lcd_devices_glcd2usb? ( usb )
	lcd_devices_displaylink? ( deprecated dlo )
	lcd_devices_remote? ( experimental )"

RDEPEND="media-libs/gd[jpeg,png,tiff]
	dlo? ( x11-libs/libdlo )
	sdl? ( media-libs/libsdl )
	usb? ( virtual/libusb:1= )
	${DEPEND_LCD_DEVICES}"

DEPEND="${RDEPEND}"

DOCS=( "AUTHORS" "BUGS" "DOCS" "HISTORY" "PINOUTS" "README" "TODO" )

src_prepare() {
	default

	# Only build the static library, if a user wants it
	if ! use static-libs; then
		eapply "${FILESDIR}"/disable-static-build.patch
	fi

	# Fix Makefile, as it will fail, when USE="tools" is not set
	if ! use tools; then
		sed -i -e '/$(INSTALL_PROGRAM) $(PROGRAMS) $(bindir)/d' src/Makefile.in || die
	fi

	# Fix QA-Warning "QA Notice: pkg-config files with wrong LDFLAGS detected"
	sed -i -e '/@LDFLAGS@/d' serdisplib.pc.in || die
}

src_configure() {
	# Enable all users enabled lcd devices
	local myconf_lcd_devices
	for lcd_device in ${!IUSE_LCD_DEVICES[@]}; do
		if use lcd_devices_${IUSE_LCD_DEVICES[$lcd_device]}; then
			if [[ -z "${myconf_lcd_devices}" ]]; then
				myconf_lcd_devices="${IUSE_LCD_DEVICES[$lcd_device]}"
			else
				myconf_lcd_devices="${myconf_lcd_devices},${IUSE_LCD_DEVICES[$lcd_device]}"
			fi
		fi
	done

	econf \
		$(use_enable deprecated) \
		$(use_enable dlo libdlo) \
		$(use_enable experimental) \
		$(use_enable sdl libSDL) \
		$(use_enable static-libs statictools) \
		$(use_enable threads pthread) \
		$(use_enable tools) \
		$(use_enable usb libusb) \
		--prefix="${ED}"/usr \
		--sysconfdir="${ED}"/etc \
		--with-drivers="${myconf_lcd_devices}"
}

src_install() {
	default

	# Install udev rule
	udev_dorules 90-libserdisp.rules
}

pkg_postinst() {
	# Reload UDEV rules on install
	udev_reload
}

pkg_postrm() {
	# Reload UDEV rules on uninstall
	udev_reload
}
