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

src_unpack() {
    rpm_src_unpack ${A}
}

pkg_preinst() {
	mkdir "${S}/init_scripts"

    init_sys="$(ps -p 1 -o comm=)"

    case $init_sys in
        init)
            echo "Preparing files for openrc."

            echo -e '\
#!/sbin/openrc-run

description="Mullvad VPN Service"
depend() {
    need net
}

supervisor="supervise-daemon"
command="/opt/Mullvad\ VPN/resources/mullvad-daemon"
command_args="${MULLVPN_OPTS}"
pidfile="/run/${RC_SVCNAME}.pid"
command_background=true' > ${S}/init_scripts/mullvadd
            ;;

        systemd)
            echo "Preparing files for systemd."

            echo -e '\
# Systemd service unit file for the Mullvad VPN daemon
# testing if new changes are added

[Unit]
Description=Mullvad VPN daemon
Before=network-online.target
After=mullvad-early-boot-blocking.service NetworkManager.service systemd-resolved.service

StartLimitBurst=5
StartLimitIntervalSec=20
RequiresMountsFor=/opt/Mullvad\x20VPN/resources/

[Service]
Restart=always
RestartSec=1
ExecStart=/usr/bin/mullvad-daemon -v --disable-stdout-timestamps
Environment="MULLVAD_RESOURCE_DIR=/opt/Mullvad VPN/resources/"

[Install]
WantedBy=multi-user.target' > ${S}/init_scripts/mullvad-daemon.service
            ;;
        
        *)
            echo "Can't recoginize init system."
            exit 1
            ;;
    esac
}
  
src_install() {
    echo -e "\n\
    #----------------------------\n \
    This block is src_install()\n \
    #----------------------------\n \
    "

    insinto /opt
    cp -vR "${S}/opt" "${D}/opt" || die "Failed to install data files."
    cp -vR "${S}/usr/bin" "${D}/usr/bin" || die "Failed to install binaries."
    cp -vR "${S}/usr/share" "${D}/usr/share" || die "Failed to install shareable files."

}



