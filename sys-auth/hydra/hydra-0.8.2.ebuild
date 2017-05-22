# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit user eutils golang-build systemd


DESCRIPTION="OAuth 2.0 server with OpenID Connect support"
HOMEPAGE="https://github.com/ory/hydra"

EGO_PN="github.com/ory/${PN}/..."

if [ ${PV} == "9999" ] ; then
	inherit git-r3 golang-vcs
	EGIT_REPO_URI="https://github.com/ory/${PN}.git"
else
	inherit golang-vcs-snapshot
	SRC_URI="https://github.com/ory/${PN}/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi


LICENSE="Apache-2.0"
SLOT="0"
IUSE="systemd mysql postgres"

REQUIRED_USE="mysql? ( !postgres )"

DEPEND="<=dev-lang/go-1.8.1 dev-go/glide"
RDEPEND="
	systemd? ( sys-apps/systemd )
	mysql? ( sys-db/mysql )
	postgres? ( dev-db/postgresql )"

src_prepare() {
	default
}

src_compile() {
	pushd src/${EGO_PN%/*} || die
	GOPATH="${S}:$(get_golibdir_gopath)" glide --home ${T} install
	popd
	GOPATH="${S}:$(get_golibdir_gopath)" go build -ldflags="-X main.version=${PV}" -o "hydra" src/${EGO_PN%/*}/main.go || die
}

src_install() {
	dobin hydra
	#newinitd ${PN}.init.d ${PN}
	#use systemd && systemd_dounit ${PN}.service
}
