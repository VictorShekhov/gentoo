# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user

DESCRIPTION="This is the command-line version of the Steam client for dedicated servers"
HOMEPAGE="https://developer.valvesoftware.com/wiki/SteamCMD"
SRC_URI="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+ SteamCMD"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

RDEPEND="app-misc/screen"

RESTRICT="bindist mirror strip"

S="${WORKDIR}"

pkg_setup() {
	# Create SteamCMD user and group
	enewgroup steamcmd
	enewuser steamcmd -1 -1 /opt/steamcmd steamcmd
}

src_install() {
	# Install SteamCMD script
	exeinto /opt/steamcmd
	doexe steamcmd.sh

	# Install SteamCMD binary and lib
	exeinto /opt/steamcmd/linux32
	doexe linux32/steamcmd linux32/libstdc++.so.6

	# Install init script and conf file
	newinitd "${FILESDIR}"/steamcmd.initd steamcmd
	newconfd "${FILESDIR}"/steamcmd.confd steamcmd

	# Keep directory
	keepdir /opt/steamcmd/.steam/sdk32

	# Set permissions
	fowners -R steamcmd:steamcmd /opt/steamcmd
}

pkg_postinst() {
	# Print usage about this package
	elog "Before you can start installing your favourite dedicated server,"
	elog "you must let SteamCMD do update itself. You can do this, by running SteamCMD itself:"
	elog ""
	elog "cd /opt/steamcmd"
	elog "runuser -l steamcmd -c './steamcmd.sh' -s /bin/bash"
	elog ""
	elog "On the first run, you will see, that SteamCMD starts updating itself."
	elog "After that, SteamCMD is ready to go for installing your favourite dedicated server."
	elog ""
	elog "Please keep in mind: You should not run SteamCMD as root!"
	elog ""
	elog "This package provides an init script and a conf file."
	elog "Don't modify those files directly,"
	elog "but instead make a symlink of that init script and a copy of that conf file."
	elog "You would do this for every server, you want to setup."
	elog ""
	elog "For example, you wan't to setup an old Counter-Strike 1.6 server, you would do:"
	elog ""
	elog "cd /etc/init.d"
	elog "ln -s steamcmd steamcmd.cstrike"
	elog ""
	elog "cd /etc/conf.d"
	elog "cp steamcmd steamcmd.cstrike"
	elog ""
	elog "After that, make your settings in /etc/conf.d/steamcmd.cstrike"
	elog ""
	elog "In order to install with SteamCMD a dedicated server, for example CS 1.6, please run:"
	elog "cd /opt/steamcmd"
	elog "./steamcmd.sh +login anonymous +force_install_dir /opt/steamcmd/hlds +app_set_config 90 mod cstrike +app_update 90 validate +quit"
	elog ""
	elog "While you can use any path for '+force_install_dir', it's recommended to use:"
	elog "'/opt/steamcmd/hlds' for older HL1 based mods."
	elog "'/opt/steamcmd/srcds' for newer HL2 based mods."
	elog ""
	elog "For more information, please visit the Valve Developer Community:"
	elog "https://developer.valvesoftware.com/wiki/SteamCMD"
}
