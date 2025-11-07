# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# stdsimd
# RUST_MAX_VER="1.77.1"

EGIT_CLONE_TYPE="single"

inherit bash-completion-r1 desktop cargo xdg-utils git-r3

DESCRIPTION="A GPU-accelerated cross-platform terminal emulator and multiplexer"
HOMEPAGE="https://wezfurlong.org/wezterm/"

# MY_PV="$(ver_rs 1 -)-5046fc22"
# MY_P="${PN}-${MY_PV}"

EGIT_REPO_URI="https://github.com/wezterm/wezterm.git"

SUBMODULES=(
	"freetype2 github freetype https://github.com/wez/freetype2 e4586d960f339cf75e2e0b34aee30a0ed8353c0d"
	"libpng github freetype https://github.com/glennrp/libpng 8439534daa1d3a5705ba92e653eda9251246dd61"
	"zlib github freetype https://github.com/madler/zlib cacf7f1d4e3d44d871b605da3b647f07d718623f"
	"harfbuzz github harfbuzz https://github.com/harfbuzz/harfbuzz 894a1f72ee93a1fd8dc1d9218cb3fd8f048be29a"
	"libssh-rs-tmp github crates https://github.com/wez/libssh-rs e57fdc813ed177738828ad73536f657cb2f91cf4"
	"libssh gitlab crates https://gitlab.com/libssh/libssh-mirror 6ad455a8acfe6032c2a87cf83f2d20463c30f8af"
)

# License set may be more restrictive as OR is not respected
# use cargo-license for a more accurate license picture
LICENSE="MIT"
LICENSE+="
        Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD CC0-1.0 ISC
        LGPL-2.1 MIT MPL-2.0 UoI-NCSA Unicode-3.0 Unicode-DFS-2016 WTFPL-2
        ZLIB
"
SLOT="0"
# KEYWORDS="~amd64 ~arm64"
IUSE="wayland"

RESTRICT=test # tests require network

PATCHES=(
    "${FILESDIR}/${PN}-${PV}-vendored-sources.patch"
    # "${FILESDIR}/${PN}-${PV}-cairo.patch"
)

DEPEND="
    dev-libs/libgit2
	dev-libs/openssl
	wayland? ( dev-libs/wayland )
	media-fonts/jetbrains-mono
	media-fonts/noto
	media-fonts/noto-emoji
	media-fonts/roboto
	media-libs/fontconfig
	media-libs/mesa
	sys-apps/dbus
	sys-libs/zlib
	x11-libs/cairo[X]
	x11-libs/libX11
	x11-libs/libxkbcommon[X,wayland?]
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	x11-themes/hicolor-icon-theme
	x11-themes/xcursor-themes
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	dev-vcs/git
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="
	usr/bin/.*
"

# S="${WORKDIR}/${MY_P}"

# submodule_uris() {
# 	for line in "${SUBMODULES[@]}"; do
# 		read -r name hoster dep url commit <<< "${line}" || die

# 		if [ ${hoster} == "github" ];
# 		then
# 			SRC_URI+=" ${url}/archive/${commit}.tar.gz -> ${url##*/}-${commit}.tar.gz"
# 		elif [ ${hoster} == "gitlab" ];
# 		then
# 			SRC_URI+=" ${url}/-/archive/${commit}/${url##*/}-${commit}.tar.gz"
# 		else
# 			die
# 		fi
# 	done
# }

# submodule_uris

src_unpack() {
    git-r3_src_unpack

    pushd ${S}
    eapply "${FILESDIR}/${PN}-${PV}-cairo.patch"
    popd

    cargo_live_src_unpack
}

src_prepare() {
	# for line in "${SUBMODULES[@]}"; do
	# 	read -r name hoster dep url commit <<< "${line}" || die

	# 	mkdir -p "${S}/deps/${dep}/${name}" || die
	# 	cp -r "${WORKDIR}"/${url##*/}-${commit}/* "${S}/deps/${dep}/${name}" || die
	# done

	# pushd "${WORKDIR}"/cargo_home/gentoo/xcb-imdkit-0.1.2 || die
	# eapply "${FILESDIR}"/xcb-imdkit-0.1.2-p1.patch
	# eapply "${FILESDIR}"/xcb-imdkit-0.1.2-p2.patch
	# eapply "${FILESDIR}"/xcb-imdkit-0.1.2-p3-xcb-1.3.patch
	# eapply "${FILESDIR}"/xcb-imdkit-0.1.2-p4.patch
	# popd || die

	# mv "${S}/deps/crates/libssh-rs-tmp/libssh-rs" "${S}/deps/crates" || die
	# mv "${S}/deps/crates/libssh-rs-tmp/libssh-rs-sys" "${S}/deps/crates" || die
	# cp -r "${S}"/deps/crates/libssh/* "${S}/deps/crates/libssh-rs-sys/vendored/" || die
	# rm -rf "${S}/deps/crates/libssh-rs-tmp" || die
	# rm -rf "${S}/deps/crates/libssh" || die
	# echo '{"files":{}}' > "${S}/deps/crates/libssh-rs/.cargo-checksum.json" || die
	# echo '{"files":{}}' > "${S}/deps/crates/libssh-rs-sys/.cargo-checksum.json" || die
	# echo '{"files":{}}' > "${WORKDIR}/cargo_home/gentoo/xcb-imdkit-0.1.2/.cargo-checksum.json" || die

	echo "git-gentoo" > .tag || die

    default
}

src_configure() {
	local myfeatures=(
		distro-defaults
		vendor-nerd-font-symbols-font
		$(usev wayland)
	)
	cargo_src_configure --no-default-features
}

src_compile() {
	cargo_src_compile
}

src_install() {
	exeinto /usr/bin
	doexe "$(cargo_target_dir)/wezterm"
	doexe "$(cargo_target_dir)/wezterm-gui"
	doexe "$(cargo_target_dir)/wezterm-mux-server"
	doexe "$(cargo_target_dir)/strip-ansi-escapes"

	insinto /usr/share/icons/hicolor/128x128/apps
	newins assets/icon/terminal.png org.wezfurlong.wezterm.png

	newmenu assets/wezterm.desktop org.wezfurlong.wezterm.desktop

	insinto /usr/share/metainfo
	newins assets/wezterm.appdata.xml org.wezfurlong.wezterm.appdata.xml

	newbashcomp assets/shell-completion/bash ${PN}

	insopts -m 0644
	insinto /usr/share/zsh/site-functions
	newins assets/shell-completion/zsh _${PN}

	insopts -m 0644
	insinto /usr/share/fish/vendor_completions.d
	newins assets/shell-completion/fish ${PN}.fish
}

pkg_postinst() {
	xdg_icon_cache_update
	einfo "It may be necessary to configure wezterm to use a cursor theme, see:"
	einfo "https://wezfurlong.org/wezterm/faq.html?highlight=xcursor_theme#i-use-x11-or-wayland-and-my-mouse-cursor-theme-doesnt-seem-to-work"
	einfo "It may be necessary to set the environment variable XCURSOR_PATH"
	einfo "to the directory containing the cursor icons, for example"
	einfo 'export XCURSOR_PATH="/usr/share/cursors/xorg-x11/"'
	einfo "before starting the wayland or X11 window compositor to avoid the error:"
	einfo "ERROR  window::os::wayland::frame > Unable to set cursor to left_ptr: cursor not found"
	einfo "For example, in the file ~/.wezterm.lua:"
	einfo "return {"
	einfo '  xcursor_theme = "whiteglass"'
	einfo "}"
}

pkg_postrm() {
	xdg_icon_cache_update
}
