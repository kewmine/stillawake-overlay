EAPI=8
inherit rpm xdg-utils

MY_PN="jetbrains-toolbox"  
DESCRIPTION="An app to manage JetBrains IDEs with ease."
HOMEPAGE="https://www.jetbrains.com/toolbox-app"
LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 CC-BY-2.5 CDDL-1.1 codehaus-classworlds CPL-1.0 EPL-1.0 EPL-2.0 GPL-2 GPL-2-with-classpath-exception ISC JDOM LGPL-2.1 LGPL-2.1+ LGPL-3-with-linking-exception MIT MPL-1.0 MPL-1.1 OFL ZLIB"

SRC_URI="https://github.com/mullvad/mullvadvpn-app/releases/download/${PV}/MullvadVPN-${PV}_x86_64.rpm"
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
    doinitd ${FILESDIR}/mullvadd
    doinitd ${FILESDIR}/mullvadd-early-boot-blocking   
}

src_install() {
    cp -r ${S}/* ${D} || die "Install failed!"
}

pkg_postinst() {
    INIT_SYS="$(ps -p 1 -o comm=)"
	
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
        
        *)
            "Couldn't find a supported init system"
            ;;
    esac

    xdg_icon_cache_update
}

pkg_postrm() {
    xdg_icon_cache_update
}
