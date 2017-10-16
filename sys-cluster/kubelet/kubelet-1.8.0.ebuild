# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit golang-build golang-vcs-snapshot

EGO_PN="k8s.io/kubernetes"
ARCHIVE_URI="https://github.com/kubernetes/kubernetes/archive/v${PV}.tar.gz -> kubernetes-${PV}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="Kubernetes Node Agent"
HOMEPAGE="https://github.com/kubernetes/kubernetes https://kubernetes.io"
SRC_URI="${ARCHIVE_URI}"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="hardened"

DEPEND="dev-go/go-bindata"

RESTRICT="test"

src_prepare() {
	default
	sed -i -e "/vendor\/github.com\/jteeuwen\/go-bindata\/go-bindata/d" src/${EGO_PN}/hack/lib/golang.sh || die
	sed -i -e "/export PATH/d" src/${EGO_PN}/hack/generate-bindata.sh || die
}

src_compile() {
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')"
	LDFLAGS="" GOPATH="${WORKDIR}/${P}" emake -j1 -C src/${EGO_PN} WHAT=cmd/${PN}
}

src_install() {
	pushd src/${EGO_PN} || die
	dobin _output/bin/${PN}
	popd || die
	keepdir /etc/kubernetes/manifests /var/log/kubelet /var/lib/kubelet
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotated ${PN}
}
