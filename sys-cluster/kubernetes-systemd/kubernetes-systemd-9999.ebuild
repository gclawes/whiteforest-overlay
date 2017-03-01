# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit user git-r3 systemd

DESCRIPTION="Kubernetes single-node systemd integration"
HOMEPAGE="https://github.com/kubernetes/contrib https://kubernetes.io"

EGIT_REPO_URI="https://github.com/kubernetes/contrib.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {

	# FIXME: add kube user
	dodir /etc/kubernetes
	insinto /etc/kubernetes

	for i in apiserver config controller-manager kubelet proxy scheduler; do
		doins init/systemd/environ/$i
	done

	for i in kube-apiserver kube-controller-manager kube-proxy kube-scheduler kubelet; do
		systemd_dounit init/systemd/${i}.service
	done
}

