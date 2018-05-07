# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit golang-build golang-vcs-snapshot bash-completion-r1

EGO_PN="github.com/docker/docker-credential-helpers"
ARCHIVE_URI="https://github.com/docker/docker-credential-helpers/archive/v${PV}.tar.gz -> docker-credential-helpers-${PV}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="Docker Credentials Helpers"
HOMEPAGE="https://github.com/docker/docker-credential-helpers"
SRC_URI="${ARCHIVE_URI}"

LICENSE="MIT"
SLOT="0"
IUSE="+client +pass secretservice"

DEPEND="dev-go/go-bindata
	secretservice? ( app-crypt/libsecret )"
RDEPEND="pass? ( app-admin/pass )
	secretservice? ( sys-apps/dbus app-crypt/libsecret )"

RESTRICT=""

src_compile() {
	helpers=""
	use client && helpers="${helpers} client"
	use pass && helpers="${helpers} pass"
	use secretservice && helpers="${helpers} secretservice"
	GOPATH="${WORKDIR}/${P}" emake -C src/${EGO_PN} ${helpers}
}

src_install() {
	pushd src/${EGO_PN} || die
	use client && dobin bin/docker-credential-client
	use pass && dobin bin/docker-credential-pass
	use secretservice && dobin bin/docker-credential-secretservice
	popd || die
}
