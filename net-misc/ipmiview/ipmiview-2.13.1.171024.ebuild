# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop eapi7-ver java-vm-2 unpacker

MY_DATE="$(ver_cut 4)"
MY_PN="IPMIView"
MY_PV="$(ver_cut 1-3)"

DESCRIPTION="A GUI application that allows to manage multiple target systems through BMC"
HOMEPAGE="https://www.supermicro.com/"
SRC_URI="amd64? ( ftp://ftp.supermicro.com/utility/${MY_PN}/Linux/${MY_PN}_${MY_PV}_build.${MY_DATE}_bundleJRE_Linux_x64.tar.gz )
	x86? ( ftp://ftp.supermicro.com/utility/${MY_PN}/Linux/${MY_PN}_${MY_PV}_build.${MY_DATE}_bundleJRE_Linux.tar.gz )"

LICENSE="supermicro"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

RDEPEND="net-misc/stunnel
	virtual/jre"

RESTRICT="bindist fetch mirror strip"

S="${WORKDIR}"

QA_PREBUILT="opt/ipmiview/libiKVM*.so
	opt/ipmiview/libSharedLibrary*.so"

pkg_nofetch() {
	elog "Please download ${A} from"
	elog "https://www.supermicro.com/SwDownload/UserInfo.aspx?sw=0&cat=IPMI"
	elog "and place it in your DISTDIR directory."
}

src_unpack() {
	# Unpack archive
	unpack ${A}

	# Extract *.jar to get *.ico logos for the menu entries
	if use amd64; then
		unpack_zip ${MY_PN}_${MY_PV}_build.${MY_DATE}_bundleJRE_Linux_x64/IPMIView20.jar
	else
		unpack_zip ${MY_PN}_${MY_PV}_build.${MY_DATE}_bundleJRE_Linux/IPMIView20.jar
	fi
}

src_install() {
	# Choose ARCH
	if use amd64; then
		local my_arch="${MY_PN}_${MY_PV}_build.${MY_DATE}_bundleJRE_Linux_x64"
	else
		local my_arch="${MY_PN}_${MY_PV}_build.${MY_DATE}_bundleJRE_Linux"
	fi

	# Install binary
	exeinto /opt/ipmiview
	doexe ${my_arch}/iKVM ${my_arch}/IPMIView20 ${my_arch}/JViewerX9 ${my_arch}/TrapReceiver

	# Install libs
	exeinto /opt/ipmiview
	if use amd64; then
		doexe ${my_arch}/*64.so
	else
		doexe ${my_arch}/*32.so
	fi

	# Install java libs
	exeinto /opt/ipmiview
	if use amd64; then
		doexe ${my_arch}/*64.jnilib
	fi

	# Install files
	touch "${T}"/account.properties "${T}"/email.properties "${T}"/IPMIView.properties "${T}"/timeout.properties || die
	insinto /opt/ipmiview
	doins ${my_arch}/*.jar ${my_arch}/*.lax "${T}"/*.properties

	# Use system java
	dosym ../..${JAVA_VM_SYSTEM}/jre /opt/ipmiview/jre

	# Install certificates
	insinto /opt/ipmiview/BMCSecurity
	doins ${my_arch}/BMCSecurity/*.crt ${my_arch}/BMCSecurity/*.key ${my_arch}/BMCSecurity/*.pem ${my_arch}/BMCSecurity/*.txt

	# Install Stunnel config
	insinto /opt/ipmiview/BMCSecurity/linux
	doins ${my_arch}/BMCSecurity/linux/stunnel.conf

	# Use system stunnel
	dosym ../../../../usr/bin/stunnel /opt/ipmiview/BMCSecurity/linux/stunnel$(usex amd64 64 32)

	# Install icons
	newicon images/Ipmiview.ico ipmiview.ico
	newicon images/Ipmitrap.ico ipmitrap.ico

	# Install menu entry
	make_desktop_entry ipmiview IPMIView /usr/share/pixmaps/ipmiview.ico Network Path=/opt/ipmiview
	make_desktop_entry trapreceiver "Trap Receiver" /usr/share/pixmaps/ipmitrap.ico Network Path=/opt/ipmiview

	# Install symlink
	dodir /opt/bin
	dosym ../ipmiview/iKVM /opt/bin/ikvm
	dosym ../ipmiview/IPMIView20 /opt/bin/ipmiview
	dosym ../ipmiview/JViewerX9 /opt/bin/jviewerx9
	dosym ../ipmiview/TrapReceiver /opt/bin/trapreceiver

	# Install docs
	local DOCS=( "${my_arch}/IPMIView20_User_Guide.pdf" "${my_arch}/IPMIView_MicroBlade_User_Guide.pdf" "${my_arch}/IPMIView_SuperBlade_User_Guide.pdf" "${my_arch}/ReleaseNotes.txt" )
	einstalldocs
}
