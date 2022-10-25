EAPI=8

MY_PN="mullvad-bin"  
DESCRIPTION="Mullvad is a VPN service that helps keep your online activity, identity, and location private."
HOMEPAGE="https://mullvad.net"
SRC_URI="https://mullvad.net/download/app/rpm/latest"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
PROPERTIES+=" live"

src_unpack() {

    curl -L "https://mullvad.net/download/app/rpm/latest" \
        -o  ${S}/mullvad_latest-bin.rpm || die "Could not fetch mullvad rpm package."

    rpm2tar ${S}/mullvad_latest-bin.rpm || die "Could not convert rpm to tar archive."

    tar -xvf ${S}/mullvad_latest-bin.tar || die "Could not extract tar archive."

}

src_install() {

    cp -r ${S}/opt / || die "Failed to copy data files."
    cp -r ${S}/usr/bin /usr || die "Failed to copy binaries."
    cp -r ${S}/usr/share /usr || die "Failed to copy shareable files."

}

pkg_postinst() {

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
