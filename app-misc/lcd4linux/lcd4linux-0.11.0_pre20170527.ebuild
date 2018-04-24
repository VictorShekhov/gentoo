# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit autotools flag-o-matic python-single-r1

DESCRIPTION="A small program that grabs information and displays it on an external LCD"
HOMEPAGE="https://lcd4linux.bulix.org/"
SRC_URI="https://www.bl4ckb0x.de/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dmalloc outb"
REQUIRED_USE="lcd_devices_hd44780? ( !lcd_devices_hd44780-i2c )
	lcd_devices_hd44780-i2c? ( !lcd_devices_hd44780 )
	python? ( ${PYTHON_REQUIRED_USE} )"

# Define the list of valid lcd devices.
# Some drivers were removed from this list:
# - lcdlinux: It's an ancient driver, which needs app-misc/lcd-linux, that made it never to the portage tree.
# - lcdlinux: Besides, app-misc/lcd-linux won't compile on a modern linux kernel.
# - st2205: It's needs dev-libs/libst2205,  which made it never to the portage tree and is quite outdated.
IUSE_LCD_DEVICES=( astusb beckmannegle bwct crystalfontz curses cwlinux d4d dpf
	ea232graphic efn futabavfd fw8888 g15 glcd2usb hd44780 hd44780-i2c
	irlcd lcd2usb lcdterm ledmatrix lph7508 luise
	lwabp m50530 matrixorbital matrixorbitalgx mdm166a milfordinstruments
	newhaven noritake null pertelian phanderson
	picgraphic picolcd picolcdgraphic png ppm routerboard
	sample samsungspf serdisplib shuttlevfd simplelcd t6963
	teaklcm trefon ula200 usbhub usblcd vnc wincornixdorf x11 )

# Define the list of valid lcd4linux plugins.
# Some plugins were removed from this list:
# - imon: Uses telmond, which is only available on a fli4l router or an eisfair server.
# - ppp: It has been replaced by the netdev plugin.
# - seti: SETI@home software was replaced by sci-misc/boinc, which is not compatible.
# - xmms: XMMS software was replaced by media-sound/xmms2, which is not compatible.
IUSE_LCD4LINUX_PLUGINS=( apm asterisk button_exec cpuinfo dbus diskstats dvb exec event
	fifo file gps hddtemp huawei i2c_sensors iconv isdn kvv
	loadavg meminfo mpd mpris_dbus mysql netdev netinfo pop3
	proc_stat python qnaplog raspi sample statfs uname uptime
	w1retap wireless )

# Add supported drivers from 'IUSE_LCD_DEVICES' to 'IUSE' and 'REQUIRED_USE'
IUSE="${IUSE} $(printf 'lcd_devices_%s ' ${IUSE_LCD_DEVICES[@]})"
REQUIRED_USE="${REQUIRED_USE} || ( $(printf 'lcd_devices_%s ' ${IUSE_LCD_DEVICES[@]}) )"

# Add supported plugins from 'IUSE_LCD4LINUX_PLUGINS' to 'IUSE' and 'REQUIRED_USE'
IUSE="${IUSE} $(printf '%s ' ${IUSE_LCD4LINUX_PLUGINS[@]})"
REQUIRED_USE="${REQUIRED_USE} || ( $(printf '%s ' ${IUSE_LCD4LINUX_PLUGINS[@]}) )"

# Define dependencies for all drivers in 'IUSE_LCD_DEVICES'
DEPEND_LCD_DEVICES="lcd_devices_astusb? ( virtual/libusb:0= )
	lcd_devices_bwct? ( virtual/libusb:0= )
	lcd_devices_curses? ( sys-libs/ncurses:0= )
	lcd_devices_dpf? ( virtual/libusb:0= )
	lcd_devices_g15? ( virtual/libusb:0= )
	lcd_devices_glcd2usb? ( virtual/libusb:0= )
	lcd_devices_irlcd? ( virtual/libusb:0= )
	lcd_devices_lcd2usb? ( virtual/libusb:0= )
	lcd_devices_ledmatrix? ( virtual/libusb:0= )
	lcd_devices_luise? ( dev-libs/luise-bin
		virtual/libusb:0= )
	lcd_devices_matrixorbitalgx? ( virtual/libusb:0= )
	lcd_devices_mdm166a? ( virtual/libusb:0= )
	lcd_devices_picolcd? ( virtual/libusb:0= )
	lcd_devices_picolcdgraphic? ( virtual/libusb:0= )
	lcd_devices_png? ( media-libs/gd[png]
		media-libs/libpng:0= )
	lcd_devices_ppm? ( media-libs/gd )
	lcd_devices_samsungspf? ( virtual/libusb:0= )
	lcd_devices_serdisplib? ( dev-libs/serdisplib )
	lcd_devices_shuttlevfd? ( virtual/libusb:0= )
	lcd_devices_trefon? ( virtual/libusb:0= )
	lcd_devices_ula200? ( dev-embedded/libftdi:1=
		virtual/libusb:0= )
	lcd_devices_usbhub? ( virtual/libusb:0= )
	lcd_devices_usblcd? ( virtual/libusb:0= )
	lcd_devices_vnc? ( net-libs/libvncserver )
	lcd_devices_x11? ( x11-libs/libX11 )"

# Define dependencies for all plugins in 'IUSE_LCD4LINUX_PLUGINS'
DEPEND_LCD4LINUX_PLUGINS="asterisk? ( net-misc/asterisk )
	dbus? ( sys-apps/dbus )
	gps? ( dev-libs/nmeap )
	hddtemp? ( app-admin/hddtemp )
	iconv? ( virtual/libiconv )
	mpd? ( media-libs/libmpd )
	mpris_dbus? ( sys-apps/dbus )
	mysql? ( || ( dev-db/mariadb-connector-c
		dev-db/mysql-connector-c ) )
	python? ( ${PYTHON_DEPS} )
	wireless? ( || ( net-wireless/iw
		net-wireless/wireless-tools ) )"

RDEPEND="dmalloc? ( dev-libs/dmalloc )
	${DEPEND_LCD_DEVICES}
	${DEPEND_LCD4LINUX_PLUGINS}"

DEPEND="${RDEPEND}"

pkg_setup() {
	if use python; then
		python-single-r1_pkg_setup
	fi
}

src_prepare() {
	default

	# Install new version of ax_python_devel.m4, to fix support for >=dev-lang/python-3.
	# Patch also plugin_python.c, to compile with >=dev-lang/python-3.
	# The compilation seems also not to link against >=dev-lang/python-3 correctly, so adding it to the libs.
	# See https://lcd4linux.bulix.org/wiki/plugin_python for more information.
	if use python; then
		if ! use python_single_target_python2_7; then
			cp "${FILESDIR}"/ax_python_devel.m4 ax_python_devel.m4 || die
			eapply "${FILESDIR}"/${PN}-0.11.0-add_python3_support.patch
			append-libs "-lpython${EPYTHON#python}m"
		fi
	fi

	eautoreconf
}

src_configure() {
	# Define 'real names' from configure for 'LCD_DEVICES'
	local LCD_DEVICES_NAMES=( ASTUSB BeckmannEgle BWCT CrystalFontz Curses Cwlinux D4D DPF
		EA232graphic EFN FutabaVFD FW8888 G15 GLCD2USB HD44780 HD44780-I2C
		IRLCD LCD2USB LEDMatrix LCDTerm LPH7508 LUIse
		LW_ABP M50530 MatrixOrbital MatrixOrbitalGX MilfordInstruments MDM166A
		Newhaven Noritake NULL Pertelian PHAnderson
		PICGraphic picoLCD picoLCDGraphic PNG PPM RouterBoard
		Sample SamsungSPF serdisplib ShuttleVFD SimpleLCD T6963
		TeakLCM Trefon ULA200 USBHUB USBLCD VNC WincorNixdorf X11 )

	# Enable all users enabled lcd devices
	local myconf_lcd_devices
	for lcd_device in ${!IUSE_LCD_DEVICES[@]}; do
		if use lcd_devices_${IUSE_LCD_DEVICES[$lcd_device]}; then
			if [[ -z "${myconf_lcd_devices}" ]]; then
				myconf_lcd_devices="${LCD_DEVICES_NAMES[$lcd_device]}"
			else
				myconf_lcd_devices="${myconf_lcd_devices},${LCD_DEVICES_NAMES[$lcd_device]}"
			fi
		fi
	done

	# Enable all users enabled lcd4linux plugins
	local myconf_lcd4linux_plugins
	for lcd4linux_plugin in ${!IUSE_LCD4LINUX_PLUGINS[@]}; do
		if use ${IUSE_LCD4LINUX_PLUGINS[$lcd4linux_plugin]}; then
			if [[ -z "${myconf_lcd4linux_plugins}" ]]; then
				myconf_lcd4linux_plugins="${IUSE_LCD4LINUX_PLUGINS[$lcd4linux_plugin]}"
			else
				myconf_lcd4linux_plugins="${myconf_lcd4linux_plugins},${IUSE_LCD4LINUX_PLUGINS[$lcd4linux_plugin]}"
			fi
		fi
	done

	econf \
		--disable-rpath \
		$(use_with dmalloc) \
		$(use_with outb) \
		$(usex python "--with-python PYTHON_VERSION=${EPYTHON#python}" "--without-python") \
		$(usex lcd_devices_x11 "--with-x" "--without-x") \
		$(usex lcd_devices_x11 "--x-include=/usr/include --x-libraries=/usr/$(get_libdir)" "") \
		--with-drivers="${myconf_lcd_devices}" \
		--with-plugins="${myconf_lcd4linux_plugins}"
}

src_install() {
	default

	# Install sample config, and must have 600, as lcd4linux checks this.
	insinto	/etc/lcd4linux
	insopts -m 0600
	doins lcd4linux.conf.sample

	newinitd "${FILESDIR}/lcd4linux-r1.initd" lcd4linux
}

pkg_postinst() {
	if use python; then
		if ! use python_single_target_python2_7; then
			elog "Since you have choosen to use python3 for the python plugin,"
			elog "you must now use 'python3::exec' instead of 'python::exec'"
			elog "in your lcd4linux configuration file."
		fi
	fi
}
