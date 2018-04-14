# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="bfa527ff69"

inherit systemd user

DESCRIPTION="A Management Controller for Ubiquiti Networks UniFi APs"
HOMEPAGE="https://www.ubnt.com"
SRC_URI="https://dl.ubnt.com/unifi/${PV}-${MY_PV}/UniFi.unix.zip -> ${P}.zip"

LICENSE="ubiquiti"
SLOT="0"

RDEPEND="dev-db/mongodb
	dev-java/tomcat-native
	virtual/jre:1.8"

RESTRICT="bindist mirror strip"

S="${WORKDIR}/UniFi"

QA_PREBUILT="usr/lib/unifi/lib/native/Linux/x86_64/*.so
	usr/lib64/unifi/lib/native/Linux/x86_64/*.so"

pkg_setup() {
	# Create UniFi user and group
	enewgroup unifi
	enewuser unifi -1 -1 /var/lib/unifi unifi
}

src_install() {
	# Install files
	insinto /usr/$(get_libdir)/unifi
	doins -r dl webapps

	# Install MongoDB wrapper script, to avoid problems with >= 3.6.x
	# See https://community.ubnt.com/t5/UniFi-Routing-Switching/MongoDB-3-6/td-p/2195435
	if has_version ">=dev-db/mongodb-3.6.0"; then
		exeinto /usr/$(get_libdir)/unifi/bin
		doexe "${FILESDIR}"/mongod
	else
		dodir /usr/$(get_libdir)/unifi/bin
		dosym ../../bin/mongod mongod
	fi

	# Install jars
	insinto /usr/$(get_libdir)/unifi/lib
	doins lib/*.jar

	# Install libs
	exeinto /usr/$(get_libdir)/unifi/lib/native/Linux/x86_64
	doexe lib/native/Linux/x86_64/*.so

	# Create directories
	for dir in conf run tmp work; do
		keepdir /var/lib/unifi/${dir}
	done
	keepdir /var/lib/unifi
	keepdir /var/log/${PN}

	# Create symlinks
	for symlink in conf run work; do
		dosym ../../../var/lib/unifi/${symlink} /usr/$(get_libdir)/unifi/${symlink}
	done
	dosym ../../../var/log/unifi /usr/$(get_libdir)/unifi/logs
	dosym ../../../usr/$(get_libdir)/unifi/lib /var/lib/unifi/lib

	# Install init script and systemd unit
	newinitd "${FILESDIR}"/${PN}.initd unifi
	systemd_dounit "${FILESDIR}"/${PN}.service

	# Install docs
	local DOCS=( "readme.txt" )
	einstalldocs

	# Protect config
	echo 'CONFIG_PROTECT="/var/lib/unifi"' > "${T}"/99unifi || die
	doenvd "${T}"/99unifi

	# Set permissions
	fowners -R unifi:unifi /usr/$(get_libdir)/unifi /var/lib/unifi /var/log/unifi
}
