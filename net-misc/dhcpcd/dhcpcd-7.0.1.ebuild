# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://roy.marples.name/dhcpcd"
	inherit git-r3
else
	MY_P="${P/_alpha/-alpha}"
	MY_P="${MY_P/_beta/-beta}"
	MY_P="${MY_P/_rc/-rc}"
	SRC_URI="http://roy.marples.name/downloads/${PN}/${MY_P}.tar.xz"
	KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ia64 ~mips ~ppc ~ppc64 ~s390 ~sh sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"
	S="${WORKDIR}/${MY_P}"
fi

inherit eutils systemd toolchain-funcs

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
LICENSE="BSD-2"
SLOT="0"
IUSE="elibc_glibc +embedded ipv6 kernel_linux +udev"

COMMON_DEPEND="udev? ( virtual/udev )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_configure()
{
	local dev hooks rundir
	use udev || dev="--without-dev --without-udev"
	hooks="--with-hook=ntp.conf"
	use elibc_glibc && hooks="${hooks} --with-hook=yp.conf"
	use kernel_linux && rundir="--rundir=${EPREFIX}/run"
	econf \
		--prefix="${EPREFIX}" \
		--libexecdir="${EPREFIX}/lib/dhcpcd" \
		--dbdir="${EPREFIX}/var/lib/dhcpcd" \
		--localstatedir="${EPREFIX}/var" \
		${rundir} \
		$(use_enable embedded) \
		$(use_enable ipv6) \
		${dev} \
		CC="$(tc-getCC)" \
		${hooks}
}

src_install()
{
	default
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
}

pkg_postinst()
{
	local dbdir="${EROOT%/}"/var/lib/dhcpcd old_files=

	local old_old_duid="${EROOT%/}"/var/lib/dhcpcd/dhcpcd.duid
	local old_duid="${EROOT%/}"/etc/dhcpcd.duid
	local new_duid="${dbdir}"/duid
	if [ -e "${old_old_duid}" ]; then
		# Upgrade the duid file to the new format if needed
		if ! grep -q '..:..:..:..:..:..' "${old_old_duid}"; then
			sed -i -e 's/\(..\)/\1:/g; s/:$//g' "${old_old_duid}"
		fi

		# Move the duid to /etc, a more sensible location
		if [ ! -e "${old_duid}" ]; then
			cp -p "${old_old_duid}" "${new_duid}"
		fi
		old_files="${old_files} ${old_old_duid}"
	fi

	# dhcpcd-7 moves the files out of /etc
	if [ -e "${old_duid}" ]; then
		if [ ! -e "${new_duid}" ]; then
			cp -p "${old_duid}" "${new_duid}"
		fi
		old_files="${old_files} ${old_duid}"
	fi
	local old_secret="${EROOT%/}"/etc/dhcpcd.secret
	local new_secret="${dbdir}"/secret
	if [ -e "${old_secret}" ]; then
		if [ ! -e "${new_secret}" ]; then
			cp -p "${old_secret}" "${new_secret}"
		fi
		old_files="${old_files} ${old_secret}"
	fi

	# dhcpcd-7 renames some files in /var/lib/dhcpcd
	local old_rdm="${dbdir}"/dhcpcd-rdm.monotonic
	local new_rdm="${dbdir}"/rdm_monotonic
	if [ -e "${old_rdm}" ]; then
		if [ ! -e "${new_rdm}" ]; then
			cp -p "${old_rdm}" "${new_rdm}"
		fi
		old_files="${old_files} ${old_rdm}"
	fi
	local lease=
	for lease in "${dbdir}"/dhcpcd-*.lease*; do
		[ -f "$lease" ] || continue
		old_files="${old_files} ${lease}"
		local new_lease=$(basename "$lease" | sed -e "s/dhcpcd-//")
		[ -e "${dbdir}/${new_lease}" ] && continue
		cp "${lease}" "${dbdir}/${new_lease}"
	done

	# Warn about removing stale files
	if [ -n "${old_files}" ]; then
		elog
		elog "dhcpcd-7 has copied dhcpcd.duid and dhcpcd.secret from"
		elog "${EROOT%/}/etc to ${dbdir}"
		elog "and copied leases in ${dbdir} to new files with the dhcpcd-"
		elog "prefix dropped."
		elog
		elog "You should remove these files if you don't plan on reverting"
		elog "to an older version:"
		local old_file=
		for old_file in ${old_files}; do
			elog "	${old_file}"
		done
	fi

	if [ -z "$REPLACING_VERSIONS" ]; then
		elog
		elog "dhcpcd has zeroconf support active by default."
		elog "This means it will always obtain an IP address even if no"
		elog "DHCP server can be contacted, which will break any existing"
		elog "failover support you may have configured in your net configuration."
		elog "This behaviour can be controlled with the noipv4ll configuration"
		elog "file option or the -L command line switch."
		elog "See the dhcpcd and dhcpcd.conf man pages for more details."

		elog
		elog "Dhcpcd has duid enabled by default, and this may cause issues"
		elog "with some dhcp servers. For more information, see"
		elog "https://bugs.gentoo.org/show_bug.cgi?id=477356"
	fi

	if ! has_version net-dns/bind-tools; then
		elog
		elog "If you activate the lookup-hostname hook to look up your hostname"
		elog "using the dns, you need to install net-dns/bind-tools."
	fi
}
