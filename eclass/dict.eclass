# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: dict.eclass
# @MAINTAINER:
# maintainer-needed@gentoo.org
# @AUTHOR:
# Original author: Seemant Kulleen
# @BLURB: Ease the installation of dict and freedict translation dictionaries
# @DESCRIPTION:
# This eclass exists to ease the installation of dictd and freedictd translation
# dictionaries.  The only variables which need to be defined in the actual
# ebuilds are FORLANG and TOLANG for the source and target languages,
# respectively, and DICTS if the package ships more than one dictionary
# and cannot be determined from ${PN}.

# @ECLASS-VARIABLE: DICTS
# @DESCRIPTION:
# Array of dictionary files (foo.dict.dz and foo.index) to be installed during
# dict_src_install.

# @ECLASS-VARIABLE: FORLANG
# @DESCRIPTION:
# Please see above for a description.

# @ECLASS-VARIABLE: TOLANG
# @DESCRIPTION:
# Please see above for a description.

if [[ -z ${_DICT_ECLASS} ]]; then
_DICT_ECLASS=1

case ${EAPI:-0} in
	6) ;;
	*) die "${ECLASS}.eclass is banned in EAPI=${EAPI}" ;;
esac

if [[ ${PN} == *freedict-* ]]; then
	MY_P=${PN/freedict-/}
	DICTS=( ${MY_P} )

	DESCRIPTION="Freedict for language translation from ${FORLANG} to ${TOLANG}"
	HOMEPAGE="http://freedict.sourceforge.net/"
	SRC_URI="http://freedict.sourceforge.net/download/linux/${MY_P}.tar.gz"
elif [[ ${PN} == *dictd-* ]]; then
	MY_P=${PN/dictd-/}
	DICTS=( ${MY_P} )

	DESCRIPTION="${MY_P} dictionary for dictd"
	HOMEPAGE="http://www.dict.org/"
fi

LICENSE="GPL-2+"
SLOT="0"
IUSE=""

RDEPEND="app-text/dictd"

S="${WORKDIR}"

# @FUNCTION: dict_src_install
# @DESCRIPTION:
# The freedict src_install function, which is exported
dict_src_install() {
	insinto /usr/$(get_libdir)/dict
	for dict in "${DICTS[@]}"; do
		doins ${dict}.dict.dz
		doins ${dict}.index
	done
	einstalldocs
}

EXPORT_FUNCTIONS src_install

fi
