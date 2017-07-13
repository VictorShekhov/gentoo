# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit eutils flag-o-matic linux-info multilib pam prefix python-single-r1 \
		systemd user versionator

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~ppc-macos ~x86-solaris"

SLOT=$(get_major_version)

MY_PV=${PV/_/}
S="${WORKDIR}/${PN}-${MY_PV}"

SRC_URI="mirror://postgresql/source/v${MY_PV}/postgresql-${MY_PV}.tar.bz2"

LICENSE="POSTGRESQL GPL-2"
DESCRIPTION="PostgreSQL RDBMS"
HOMEPAGE="http://www.postgresql.org/"

LINGUAS="af cs de en es fa fr hr hu it ko nb pl pt_BR ro ru sk sl sv tr zh_CN
		 zh_TW"
IUSE="doc kerberos kernel_linux ldap libressl nls pam perl -pg_legacytimestamp
	  python +readline selinux +server systemd ssl static-libs tcl threads uuid
	  xml zlib"

for lingua in ${LINGUAS}; do
	IUSE+=" linguas_${lingua}"
done
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

wanted_languages() {
	local enable_langs

	for lingua in ${LINGUAS} ; do
		use linguas_${lingua} && enable_langs+="${lingua} "
	done

	echo -n ${enable_langs}
}

CDEPEND="
>=app-eselect/eselect-postgresql-2.0
sys-apps/less
virtual/libintl
kerberos? ( virtual/krb5 )
ldap? ( net-nds/openldap )
pam? ( virtual/pam )
perl? ( >=dev-lang/perl-5.8:= )
python? ( ${PYTHON_DEPS} )
readline? ( sys-libs/readline:0= )
server? ( systemd? ( sys-apps/systemd ) )
ssl? (
	!libressl? ( >=dev-libs/openssl-0.9.6-r1:0= )
	libressl? ( dev-libs/libressl:= )
)
tcl? ( >=dev-lang/tcl-8:0= )
xml? ( dev-libs/libxml2 dev-libs/libxslt )
zlib? ( sys-libs/zlib )
"

# uuid flags -- depend on sys-apps/util-linux for Linux libcs, or if no
# supported libc in use depend on dev-libs/ossp-uuid. For BSD systems,
# the libc includes UUID functions.
UTIL_LINUX_LIBC=( elibc_{glibc,uclibc,musl} )
BSD_LIBC=( elibc_{Free,Net,Open}BSD )

nest_usedep() {
	local front back
	while [[ ${#} -gt 1 ]]; do
		front+="${1}? ( "
		back+=" )"
		shift
	done
	echo "${front}${1}${back}"
}

IUSE+=" ${UTIL_LINUX_LIBC[@]} ${BSD_LIBC[@]}"
CDEPEND+="
uuid? (
	${UTIL_LINUX_LIBC[@]/%/? ( sys-apps/util-linux )}
	$(nest_usedep ${UTIL_LINUX_LIBC[@]/#/!} ${BSD_LIBC[@]/#/!} dev-libs/ossp-uuid)
)"

DEPEND="${CDEPEND}
!!<sys-apps/sandbox-2.0
sys-devel/bison
sys-devel/flex
nls? ( sys-devel/gettext )
xml? ( virtual/pkgconfig )
"

RDEPEND="${CDEPEND}
!dev-db/postgresql-docs:${SLOT}
!dev-db/postgresql-base:${SLOT}
!dev-db/postgresql-server:${SLOT}
selinux? ( sec-policy/selinux-postgresql )
"

pkg_setup() {
	use server && CONFIG_CHECK="~SYSVIPC" linux-info_pkg_setup

	enewgroup postgres 70
	enewuser postgres 70 /bin/sh /var/lib/postgresql postgres

	use python && python-single-r1_pkg_setup
}

src_prepare() {
	# Work around PPC{,64} compilation bug where bool is already defined
	sed '/#ifndef __cplusplus/a #undef bool' -i src/include/c.h || die

	# Set proper run directory
	sed "s|\(PGSOCKET_DIR\s\+\)\"/tmp\"|\1\"${EPREFIX}/run/postgresql\"|" \
		-i src/include/pg_config_manual.h || die

	# Rely on $PATH being in the proper order so that the correct
	# install program is used for modules utilizing PGXS in both
	# hardened and non-hardened environments. (Bug #528786)
	sed 's/@install_bin@/install -c/' -i src/Makefile.global.in || die

	use server || eapply "${FILESDIR}/${PN}-${SLOT}beta2-no-server.patch"

	# Fix bug 486556 where the server would crash at start up because of
	# an infinite loop caused by a self-referencing symlink.
	#eapply "${FILESDIR}/postgresql-9.2-9.4-tz-dir-overflow.patch"

	if use pam ; then
		sed -e "s/\(#define PGSQL_PAM_SERVICE \"postgresql\)/\1-${SLOT}/" \
			-i src/backend/libpq/auth.c || \
			die 'PGSQL_PAM_SERVICE rename failed.'
	fi

	eapply_user
}

src_configure() {
	case ${CHOST} in
		*-darwin*|*-solaris*)
			use nls && append-libs intl
			;;
	esac

	export LDFLAGS_SL="${LDFLAGS}"
	export LDFLAGS_EX="${LDFLAGS}"

	local PO="${EPREFIX%/}"

	local i uuid_config=""
	if use uuid; then
		for i in ${UTIL_LINUX_LIBC[@]}; do
			use ${i} && uuid_config="--with-uuid=e2fs"
		done
		for i in ${BSD_LIBC[@]}; do
			use ${i} && uuid_config="--with-uuid=bsd"
		done
		[[ -z $uuid_config ]] && uuid_config="--with-uuid=ossp"
	fi

	econf \
		--prefix="${PO}/usr/$(get_libdir)/postgresql-${SLOT}" \
		--datadir="${PO}/usr/share/postgresql-${SLOT}" \
		--docdir="${PO}/usr/share/doc/${PF}" \
		--includedir="${PO}/usr/include/postgresql-${SLOT}" \
		--mandir="${PO}/usr/share/postgresql-${SLOT}/man" \
		--sysconfdir="${PO}/etc/postgresql-${SLOT}" \
		--with-system-tzdata="${PO}/usr/share/zoneinfo" \
		$(use_enable !pg_legacytimestamp integer-datetimes) \
		$(use_enable threads thread-safety) \
		$(use_with kerberos gssapi) \
		$(use_with ldap) \
		$(use_with pam) \
		$(use_with perl) \
		$(use_with python) \
		$(use_with readline) \
		$(use_with ssl openssl) \
		$(usex server "$(use_with systemd)" '--without-systemd') \
		$(use_with tcl) \
		${uuid_config} \
		$(use_with xml libxml) \
		$(use_with xml libxslt) \
		$(use_with zlib) \
		"$(use_enable nls nls "$(wanted_languages)")"
}

src_compile() {
	emake
	emake -C contrib
}

src_install() {
	emake DESTDIR="${D}" install
	emake DESTDIR="${D}" install -C contrib

	dodoc README HISTORY doc/{TODO,bug.template}

	# man pages are already built, but if we have the target make them,
	# they'll be generated from source before being installed so we
	# manually install man pages.
	# We use ${SLOT} instead of doman for postgresql.eselect
	insinto /usr/share/postgresql-${SLOT}/man/
	doins -r doc/src/sgml/man{1,3,7}
	if ! use server; then
		# Remove man pages for non-existent binaries
		serverman=(
			initdb
			pg_{archivecleanup,controldata,ctl,resetwal,rewind,standby}
			pg_{test_{fsync,timing},upgrade,waldump}
			post{gres,master}
		)
		for m in ${serverman[@]} ; do
			rm "${ED}/usr/share/postgresql-${SLOT}/man/man1/${m}.1"
		done
	fi
	docompress /usr/share/postgresql-${SLOT}/man/man{1,3,7}

	# Create slot specific man pages
	local bn f mansec slotted_name
	for mansec in 1 3 7 ; do
		local rel_manpath="../../postgresql-${SLOT}/man/man${mansec}"

		mkdir -p "${ED}"/usr/share/man/man${mansec} || die "making man dir"
		pushd "${ED}"/usr/share/man/man${mansec} > /dev/null

		for f in "${ED}/usr/share/postgresql-${SLOT}/man/man${mansec}"/* ; do
			bn=$(basename "${f}")
			slotted_name=${bn%.${mansec}}${SLOT}.${mansec}
			case ${bn} in
				TABLE.7|WITH.7)
					echo ".so ${rel_manpath}/SELECT.7" > ${slotted_name}
					;;
				*)
					echo ".so ${rel_manpath}/${bn}" > ${slotted_name}
					;;
			esac
		done

		popd > /dev/null
	done

	insinto /etc/postgresql-${SLOT}
	newins src/bin/psql/psqlrc.sample psqlrc

	use static-libs || find "${ED}" -name '*.a' -delete

	local f bn
	for f in $(find "${ED}/usr/$(get_libdir)/postgresql-${SLOT}/bin" \
					-mindepth 1 -maxdepth 1)
	do
		bn=$(basename "${f}")
		# Temporarily tack on tmp to workaround a file collision
		# issue. This is only necessary for 9.7 and earlier. 10 never
		# had this issue.
		dosym "../$(get_libdir)/postgresql-${SLOT}/bin/${bn}" \
			  "/usr/bin/${bn}${SLOT/.}"
	done

	if use doc ; then
		docinto html
		dodoc doc/src/sgml/html/*

		docinto sgml
		dodoc doc/src/sgml/*.{sgml,dsl}
	fi

	if use server; then
		sed -e "s|@SLOT@|${SLOT}|g" -e "s|@LIBDIR@|$(get_libdir)|g" \
			"${FILESDIR}/${PN}.confd-9.3" | newconfd - ${PN}-${SLOT}

		sed -e "s|@SLOT@|${SLOT}|g" -e "s|@LIBDIR@|$(get_libdir)|g" \
			"${FILESDIR}/${PN}.init-9.3-r1" | newinitd - ${PN}-${SLOT}

		if use systemd; then
			sed -e "s|@SLOT@|${SLOT}|g" -e "s|@LIBDIR@|$(get_libdir)|g" \
				"${FILESDIR}/${PN}.service-9.6" | \
				systemd_newunit - ${PN}-${SLOT}.service
		fi

		newbin "${FILESDIR}"/${PN}-check-db-dir ${PN}-${SLOT}-check-db-dir

		use pam && pamd_mimic system-auth ${PN}-${SLOT} auth account session

		if use prefix ; then
			keepdir /run/postgresql
			fperms 0775 /run/postgresql
		fi
	fi
}

pkg_postinst() {
	postgresql-config update

	elog "If you need a global psqlrc-file, you can place it in:"
	elog "    ${EROOT%/}/etc/postgresql-${SLOT}/"

	if use server ; then
		elog
		elog "Gentoo specific documentation:"
		elog "https://wiki.gentoo.org/wiki/PostgreSQL"
		elog
		elog "Official documentation:"
		elog "http://www.postgresql.org/docs/${SLOT}/static/index.html"
		elog
		elog "The default location of the Unix-domain socket is:"
		elog "    ${EROOT%/}/run/postgresql/"
		elog
		elog "Before initializing the database, you may want to edit PG_INITDB_OPTS"
		elog "so that it contains your preferred locale in:"
		elog "    ${EROOT%/}/etc/conf.d/postgresql-${SLOT}"
		elog
		elog "Then, execute the following command to setup the initial database"
		elog "environment:"
		elog "    emerge --config =${CATEGORY}/${PF}"
	fi
}

pkg_prerm() {
	if use server && [[ -z ${REPLACED_BY_VERSION} ]] ; then
		ewarn "Have you dumped and/or migrated the ${SLOT} database cluster?"
		ewarn "\thttps://wiki.gentoo.org/wiki/PostgreSQL/QuickStart#Migrating_PostgreSQL"

		ebegin "Resuming removal in 10 seconds (Control-C to cancel)"
		sleep 10
		eend 0
	fi
}

pkg_postrm() {
	postgresql-config update
}

pkg_config() {
	use server || die "USE flag 'server' not enabled. Nothing to configure."

	[[ -f "${EROOT%/}/etc/conf.d/postgresql-${SLOT}" ]] \
		&& source "${EROOT%/}/etc/conf.d/postgresql-${SLOT}"
	[[ -z "${PGDATA}" ]] && PGDATA="${EROOT%/}/etc/postgresql-${SLOT}/"
	[[ -z "${DATA_DIR}" ]] \
		&& DATA_DIR="${EROOT%/}/var/lib/postgresql/${SLOT}/data"

	# environment.bz2 may not contain the same locale as the current system
	# locale. Unset and source from the current system locale.
	if [ -f "${EROOT%/}/etc/env.d/02locale" ]; then
		unset LANG
		unset LC_CTYPE
		unset LC_NUMERIC
		unset LC_TIME
		unset LC_COLLATE
		unset LC_MONETARY
		unset LC_MESSAGES
		unset LC_ALL
		source "${EROOT%/}/etc/env.d/02locale"
		[ -n "${LANG}" ] && export LANG
		[ -n "${LC_CTYPE}" ] && export LC_CTYPE
		[ -n "${LC_NUMERIC}" ] && export LC_NUMERIC
		[ -n "${LC_TIME}" ] && export LC_TIME
		[ -n "${LC_COLLATE}" ] && export LC_COLLATE
		[ -n "${LC_MONETARY}" ] && export LC_MONETARY
		[ -n "${LC_MESSAGES}" ] && export LC_MESSAGES
		[ -n "${LC_ALL}" ] && export LC_ALL
	fi

	einfo "You can modify the paths and options passed to initdb by editing:"
	einfo "    ${EROOT%/}/etc/conf.d/postgresql-${SLOT}"
	einfo
	einfo "Information on options that can be passed to initdb are found at:"
	einfo "    http://www.postgresql.org/docs/${SLOT}/static/creating-cluster.html"
	einfo "    http://www.postgresql.org/docs/${SLOT}/static/app-initdb.html"
	einfo
	einfo "PG_INITDB_OPTS is currently set to:"
	if [[ -z "${PG_INITDB_OPTS}" ]] ; then
		einfo "    (none)"
	else
		einfo "    ${PG_INITDB_OPTS}"
	fi
	einfo
	einfo "Configuration files will be installed to:"
	einfo "    ${PGDATA}"
	einfo
	einfo "The database cluster will be created in:"
	einfo "    ${DATA_DIR}"
	einfo

	ebegin "Continuing initialization in 5 seconds (Control-C to cancel)"
	sleep 5
	eend 0

	if [ -n "$(ls -A ${DATA_DIR} 2> /dev/null)" ] ; then
		eerror "The given directory, '${DATA_DIR}', is not empty."
		eerror "Modify DATA_DIR to point to an empty directory."
		die "${DATA_DIR} is not empty."
	fi

	einfo "Creating the data directory ..."
	if [[ ${EUID} == 0 ]] ; then
		mkdir -p "${DATA_DIR}"
		chown -Rf postgres:postgres "${DATA_DIR}"
		chmod 0700 "${DATA_DIR}"
	fi

	einfo "Initializing the database ..."

	if [[ ${EUID} == 0 ]] ; then
		su postgres -c "${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}/bin/initdb -D \"${DATA_DIR}\" ${PG_INITDB_OPTS}"
	else
		"${EROOT%/}"/usr/$(get_libdir)/postgresql-${SLOT}/bin/initdb -U postgres -D "${DATA_DIR}" ${PG_INITDB_OPTS}
	fi

	if [[ "${DATA_DIR%/}" != "${PGDATA%/}" ]] ; then
		mv "${DATA_DIR%/}"/{pg_{hba,ident},postgresql}.conf "${PGDATA}"
		ln -s "${PGDATA%/}"/{pg_{hba,ident},postgresql}.conf "${DATA_DIR%/}"
	fi

	# unix_socket_directory has no effect in postgresql.conf as it's
	# overridden in the initscript
	sed '/^#unix_socket_directories/,+1d' -i "${PGDATA%/}"/postgresql.conf

	cat <<- EOF >> "${PGDATA%/}"/postgresql.conf
		# This is here because of https://bugs.gentoo.org/show_bug.cgi?id=518522
		# On the off-chance that you might need to work with UTF-8 encoded
		# characters in PL/Perl
		plperl.on_init = 'use utf8; use re; package utf8; require "utf8_heavy.pl";'
	EOF

	einfo "The autovacuum function, which was in contrib, has been moved to the main"
	einfo "PostgreSQL functions starting with 8.1, and starting with 8.4 is now enabled"
	einfo "by default. You can disable it in the cluster's:"
	einfo "    ${PGDATA%/}/postgresql.conf"
	einfo
	if ! use systemd; then
		einfo "The PostgreSQL server, by default, will log events to:"
		einfo "    ${DATA_DIR%/}/postmaster.log"
		einfo
	fi
	if use prefix ; then
		einfo "The location of the configuration files have moved to:"
		einfo "    ${PGDATA}"
		einfo "To start the server:"
		einfo "    pg_ctl start -D ${DATA_DIR} -o '-D ${PGDATA} --data-directory=${DATA_DIR}'"
		einfo "To stop:"
		einfo "    pg_ctl stop -D ${DATA_DIR}"
		einfo
		einfo "Or move the configuration files back:"
		einfo "mv ${PGDATA}*.conf ${DATA_DIR}"
	elif use systemd; then
		einfo "You should use the 'postgresql-${SLOT}.service' unit to run PostgreSQL"
		einfo "instead of 'pg_ctl'."
	else
		einfo "You should use the '${EROOT%/}/etc/init.d/postgresql-${SLOT}' script to run PostgreSQL"
		einfo "instead of 'pg_ctl'."
	fi
}

src_test() {
	if use server && [[ ${UID} -ne 0 ]] ; then
		emake check

		einfo "If you think other tests besides the regression tests are necessary, please"
		einfo "submit a bug including a patch for this ebuild to enable them."
	else
		use server || \
			ewarn 'Tests cannot be run without the "server" use flag enabled.'
		[[ ${UID} -eq 0 ]] || \
			ewarn 'Tests cannot be run as root. Enable "userpriv" in FEATURES.'

		ewarn 'Skipping.'
	fi
}
