#!/bin/bash
echo "+-----------------------------+"
echo "|                             |"
echo "|        D O T M E S H        |"
echo "|                   by dotevo |"
echo "+-----------------------------+"
echo "Konfiguracja routera tak aby dołączył do sieci dotmesh."

ret_val=""
question_yn()
{
    while true; do
    read -p "$1 [Tak/Nie]" yn
    case $yn in
        [Tt]* ) return 0; break;;
        [Nn]* ) return 1;;
        * ) echo "Odpowiedz tak lub nie.";;
    esac
    done
}

question_yn "Czy chcesz kontynuować konfigurację? (Nowa konfiguracja nadpisze starą)"

E=$?
if [ $E -eq 1 ]; then
    exit 0
fi;

command() {
    echo "Execuing... : $1";
    if [[ "$TESTING" != 'true' ]]; then
        ret_val=$(eval "$1")
    fi;
}

echo 'Instalacja wymaganych pakietów...'
command 'opkg update'
command 'opkg remove wpad-basic'
command 'opkg install batctl-full kmod-batman-adv wpad-mesh-openssl'
command 'opkg install bmx7 bmx7-iwinfo bmx7-json bmx7-topology bmx7-uci-config'

echo 'Konfiguracja nazwy hosta...'
read -p "Nazwa hosta:" host
command "uci set system.@system[0].hostname='$host'"
command "uci commit system"
command "/etc/init.d/system reload"

# SWITCH
echo "========================================================="
echo "Konfiguracja portów..."
WAN_PORTS='1'
LAN_PORTS=''
MESH_PORTS=''
BRIDGE_PORTS=''
for i in $(seq 2 5)
do
    while true; do
    read -p "Przydziel port $i. do [LAN/MESH/BRIDGE]" yn
    case $yn in
        LAN* ) LAN_PORTS="$LAN_PORTS $i"; break;;
        MESH* ) MESH_PORTS="$MESH_PORTS $i"; break;;
        BRIDGE* ) BRIDGE_PORTS="$BRIDGE_PORTS $i"; break;;
        * ) echo "Poprawne odpowiedzi to: LAN, MESH, BRIDGE.";;
    esac
    done
done
echo "Porty WAN: $WAN_PORTS"
echo "Porty LAN: $LAN_PORTS"
echo "Porty MESH: $MESH_PORTS"
echo "Porty BRIDGE: $BRIDGE_PORTS"

echo "Usuwanie starej konfiguracji..."
command 'uci delete network.@switch_vlan[3]'
command 'uci delete network.@switch_vlan[2]'
command 'uci delete network.@switch_vlan[1]'
command 'uci delete network.@switch_vlan[0]'

echo "Konfigurowanie nowych portów..."
command 'uci get network.@switch[0].name'
SWITCH=$ret_val
echo "Switch: $SWITCH"

# ADD WAN
echo "Configuring WAN port..."
command "uci add network switch_vlan"
command "uci set network.@switch_vlan[0].name=wan"
command "uci set network.@switch_vlan[0].device=$SWITCH"
command "uci set network.@switch_vlan[0].vlan=1"
command "uci set network.@switch_vlan[0].ports='1 0t'"
command "uci set network.@switch_vlan[0].vid='1'"
# ADD LAN
echo "Configuring LAN ports..."
command "uci add network switch_vlan"
command "uci set network.@switch_vlan[1].name=lan"
command "uci set network.@switch_vlan[1].device=$SWITCH"
command "uci set network.@switch_vlan[1].vlan=2"
command "uci set network.@switch_vlan[1].ports='$LAN_PORTS 0t'"
command "uci set network.@switch_vlan[1].vid='2'"
# ADD MESH
echo "Configuring MESH ports..."
command "uci add network switch_vlan"
command "uci set network.@switch_vlan[2].name=mesh"
command "uci set network.@switch_vlan[2].device=$SWITCH"
command "uci set network.@switch_vlan[2].vlan=3"
command "uci set network.@switch_vlan[2].ports='$MESH_PORTS 0t'"
command "uci set network.@switch_vlan[2].vid='3'"
# ADD BRIDGE
echo "Configuring BRIDGE ports..."
command "uci add network switch_vlan"
command "uci set network.@switch_vlan[2].name=mesh"
command "uci set network.@switch_vlan[2].device=$SWITCH"
command "uci set network.@switch_vlan[2].vlan=4"
command "uci set network.@switch_vlan[2].ports='$BRIDGE_PORTS 0t'"
command "uci set network.@switch_vlan[2].vid='4'"


echo "========================================================="
echo "Konfigurowanie sieci..."
# WAN configuration
echo "Konfigurowanie WAN (DHCP)..."
command 'uci delete network.wan'
command 'uci delete network.wan6'

command "uci set network.wan=interface"
command "uci set network.wan.ifname='eth0.1'"
command "uci set network.wan.proto='dhcp'"
command "uci set network.wan6=interface"
command "uci set network.wan6.ifname='eth0.1'"
command "uci set network.wan6.proto='dhcpv6'"
#network.wan6.reqaddress='try'
#network.wan6.reqprefix='auto'
echo "Konfigurowanie WWAN (DHCP)..."
command 'uci delete network.wwan'
command "uci set network.wwan=interface"
command "uci set network.wwan.proto='dhcp'"

# LAN configuration
echo "Konfigurowanie LAN na nowy switch..."
command "uci set network.lan.ifname='eth0.2'"

echo "Konfigurowanie BRIDGE na nowy switch..."
command "uci set network.bridge=interface"
command "uci set network.bridge.type='bridge'"
command "uci set network.bridge.proto='static'"
command "uci set network.bridge.netmask='255.255.255.0'"
command "uci set network.bridge.ip6assign='60'"
command "uci set network.bridge.ipaddr='10.10.1.2'"
command "uci set network.bridge.ifname='eth0.4'"

echo "========================================================="
echo "Konfigurowanie batman-adv..."
echo "Konfigurowanie interfejsu bat0..."

command "uci set network.bat0=interface"
command "uci set network.bat0.proto='batadv'"
command "uci set network.bat0.routing_algo='BATMAN_IV'"
command "uci set network.bat0.aggregated_ogms='1'"
command "uci set network.bat0.ap_isolation='0'"
command "uci set network.bat0.bonding='0'"
command "uci set network.bat0.gw_mode='off'"
command "uci set network.bat0.fragmentation='1'"
command "uci set network.bat0.log_level='0'"
command "uci set network.bat0.orig_interval='1000'"
command "uci set network.bat0.bridge_loop_avoidance='1'"
command "uci set network.bat0.distributed_arp_table='1'"
command "uci set network.bat0.multicast_mode='1'"
command "uci set network.bat0.network_coding='0'"
command "uci set network.bat0.hop_penalty='30'"
command "uci set network.bat0.isolation_mark='0x00000000/0x00000000'"

echo "Konfigurowanie portu dla bat0..."
command "uci set network.nwi_mesh0_eth0=interface"
command "uci set network.nwi_mesh0_eth0.proto='batadv_hardif'"
command "uci set network.nwi_mesh0_eth0.master='bat0'"
command "uci set network.nwi_mesh0_eth0.mtu='2304'"
command "uci set network.nwi_mesh0_eth0.ifname='eth0.3'"
command "uci set network.nwi_mesh0_eth0.elp_interval='500'"

echo "Konfigurowanie wifi dla bat0..."
command "uci set network.nwi_mesh0=interface"
command "uci set network.nwi_mesh0.proto='batadv_hardif'"
command "uci set network.nwi_mesh0.master='bat0'"
command "uci set network.nwi_mesh0.mtu='2304'"

command "uci set wireless.mesh0=wifi-iface"
command "uci set wireless.mesh0.device='radio1'"
command "uci set wireless.mesh0.ifname='mesh0'"
command "uci set wireless.mesh0.network='nwi_mesh0'"
command "uci set wireless.mesh0.mode='mesh'"
command "uci set wireless.mesh0.mesh_fwding='0'"
command "uci set wireless.mesh0.mesh_id='dotevo.github.io/dotmesh'"
command "uci set wireless.mesh0.encryption='psk2+ccmp'"
command "uci set wireless.mesh0.key='meshmesh'"

command "uci commit"

echo "========================================================="
echo "Konfigurowanie BMX7..."
cat /dev/null > /etc/config/bmx7

command "uci set bmx7.general=bmx7"
command "uci add bmx7 plugin"
command "uci set bmx7.@plugin[-1].plugin='bmx7_json.so'"
command "uci add bmx7 plugin"
command "uci set bmx7.@plugin[-1].plugin='bmx7_iwinfo.so'"
command "uci set bmx7.mesh='dev'"
command "uci set bmx7.mesh.dev='bat0'"

command "uci commit"
