# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit user golang-build golang-vcs-snapshot systemd

EGO_PN="k8s.io/kubernetes/..."
ARCHIVE_URI="https://github.com/kubernetes/kubernetes/archive/v${PV}.tar.gz -> kubernetes-${PV}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://github.com/kubernetes/kubernetes https://kubernetes.io"
SRC_URI="${ARCHIVE_URI}"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+kubeadm master kubelet rkt systemd"

REQUIRED_USE="kubeadm? ( systemd !master !kubelet )"

DEPEND="<dev-lang/go-1.8 dev-go/go-bindata sys-cluster/kubectl dev-db/etcd"
RDEPEND="
	>=app-emulation/docker-1.11.2
	rkt? ( app-emulation/rkt )"

RESTRICT="test"

KUBE_USER='kube'

pkg_setup() {
	enewuser ${KUBE_USER}
}

src_prepare() {
	default
	sed -i -e "/vendor\/github.com\/jteeuwen\/go-bindata\/go-bindata/d" src/${EGO_PN%/*}/hack/lib/golang.sh || die
	sed -i -e "/export PATH/d" src/${EGO_PN%/*}/hack/generate-bindata.sh || die

	kube_components=""
	install_components=""
	if use kubeadm; then
		kube_components="cmd/kubeadm cmd/kubelet"
		install_components="kubeadm kubelet"
	else
		if use master; then
			kube_components="${kube_components} cmd/kube-apiserver cmd/kube-controller-manager plugin/cmd/kube-scheduler"
			install_components="${install_components} kube-apiserver kube-controller-manager kube-scheduler"
		fi
		if use kubelet; then
			kube_components="${kube_components} cmd/kubelet cmd/kube-proxy"
			install_components="${install_components} kubelet kube-proxy"
		fi
	fi
}

src_compile() {
	#LDFLAGS="" GOPATH="${WORKDIR}/${P}" emake -j1 -C src/${EGO_PN%/*} WHAT=cmd/${PN}
	LDFLAGS="" GOPATH="${WORKDIR}/${P}" emake -j1 -C src/${EGO_PN%/*} WHAT="${kube_components}"

	pushd src/${EGO_PN%/*} || die
	./hack/generate-docs.sh
	popd || die
}

src_install() {
	pushd src/${EGO_PN%/*} || die
	for i in $install_components;do dobin _output/bin/${i}; done
	doman docs/man/man1/*.1
	popd || die

	if use kubeadm; then
		systemd_dounit "${FILESDIR}"/kubelet/kubeadm.service
	elif use systemd; then
		dodir /etc/kubernetes
		insinto /etc/kubernetes
		doins "${FILESDIR}"/systemd/environ/*

		systemd_dounit "${FILESDIR}"/systemd/*.service
		systemd_dotmpfilesd "${FILESDIR}"/systemd/tmpfiles.d/*
	fi
}
