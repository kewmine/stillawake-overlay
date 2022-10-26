EAPI=8
inherit rpm xdg-utils

MY_PN="mullvad-bin"  
DESCRIPTION="Mullvad is a VPN service that helps keep your online activity, identity, and location private."
HOMEPAGE="https://mullvad.net"
SRC_URI="https://github.com/mullvad/mullvadvpn-app/releases/download/${PV}/MullvadVPN-${PV}_x86_64.rpm"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
RESTRICT="strip"

src_unpack() {
    rpm_src_unpack ${A}
}

pkg_preinst() {
    INIT_SYS="$(ps -p 1 -o comm=)"
    INIT_SYS="systemd"

    case $INIT_SYS in
        init)
            rm -r ${S}/usr/lib #systemd files by mullvad
            doinitd ${FILESDIR}/mullvadd
            doinitd ${FILESDIR}/mullvadd-early-boot-blocking
            ;;

        systemd)
            ;;

        *)
            die "Couldn't recognize init system."
            ;;
    esac
}

src_install() {
    cp -r ${S}/* ${D} || die "Install failed!"
}

pkg_postinst() {
	case $INIT_SYS in
        init)
            rc-service mullvadd start
            rc-update add mullvadd default
            echo "added mullvadd to runlevel default"
            ;;

        systemd)
            systemctl start mullvad-daemon
            systemctl enable mullvad-daemon
            echo "added mullvad-daemon to runlevel default"
            ;;
    esac

    xdg_icon_cache_update
}

pkg_postrm() {
    xdg_icon_cache_update
}
