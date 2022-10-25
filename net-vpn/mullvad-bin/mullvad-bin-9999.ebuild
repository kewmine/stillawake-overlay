EAPI=8

inherit rpm

MY_PN="mullvad-bin"  
DESCRIPTION="Mullvad is a VPN service that helps keep your online activity, identity, and location private."
HOMEPAGE="https://mullvad.net"
SRC_URI="https://mullvad.net/download/app/rpm/latest -> mullvad_latest-bin.rpm"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
PROPERTIES+=" live"
FEATURES="-sandbox"

src_unpack() {
    rpm_src_unpack ${A}
}

pkg_postinst() {
    
    cp -r ${S}/opt / || die "Failed to copy data files."
    cp -vr ${S}/usr/bin /usr || die "Failed to copy binaries."
    cp -vr ${S}/usr/share /usr || die "Failed to copy shareable files."

    init_sys="$(ps -p 1 -o comm=)"

    case $init_sys in
        init)
            echo "Installing files for openrc."
            cp ${FILESDIR}/mullvadd-openrc /etc/init.d/mullvadd
            rc-update add mullvadd default
            rc-service mullvadd start 
            ;;

        systemd)
            echo "Installing files for systemd."
            cp ${FILESDIR}/mullvadd-systemd /usr/lib/systemd/system/mullvad-daemon.service
            systemctl enable mullvad-daemon
            systemctl start mullvad-daemon
            ;;
 
        *)
            echo -e "Can't recognize init system, available init files are in ${FILESDIR}"
            exit 1
            ;;
    esac
}
