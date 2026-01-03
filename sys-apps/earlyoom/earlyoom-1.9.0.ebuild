# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd toolchain-funcs

DESCRIPTION="Early OOM Daemon for Linux"
HOMEPAGE="https://github.com/rfjakob/earlyoom"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/rfjakob/earlyoom.git"
	inherit git-r3
else
	SRC_URI="https://github.com/rfjakob/earlyoom/archive/v${PV}.tar.gz -> ${P}.tar.gz"

	KEYWORDS="amd64 x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="man"

BDEPEND="
	man? ( virtual/pandoc )
"

src_unpack() {
	default
}

src_compile() {
	tc-export CC

	emake \
		PREFIX="${EPREFIX}"/usr \
		VERSION="v${PV}" \
		SYSTEMDUNITDIR="$(systemd_get_systemunitdir)" \
		earlyoom earlyoom.service $(usev man 'earlyoom.1')
}

src_install() {
	dobin earlyoom

	use man && doman earlyoom.1

	insinto /etc/default
	newins earlyoom.default earlyoom

	dodir /etc/conf.d
	dosym -r /etc/default/earlyoom /etc/conf.d/earlyoom

	newinitd "${FILESDIR}"/${PN}-r1 ${PN}
	systemd_dounit earlyoom.service
}
