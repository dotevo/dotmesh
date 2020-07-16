#!/bin/bash
echo "+-----------------------------+"
echo "|                             |"
echo "|        D O T M E S H        |"
echo "|                   by dotevo |"
echo "+-----------------------------+"
echo "Konfiguracja węzła tak aby przyjmował cały ruch sieci z podwęzłów lokalnych."


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
command() {
    echo "Execuing... : $1";
    if [[ "$TESTING" != 'true' ]]; then
        ret_val=$(eval "$1")
    fi;
}

question_yn "Czy chcesz kontynuować konfigurację? (Nowa konfiguracja nadpisze starą)"
E=$?
if [ $E -eq 1 ]; then
    exit 0
fi;

echo "Konfigurowanie węzła głównego dla TINC..."
echo 'Instalacja wymaganych pakietów...'
command 'opkg update'
command 'opkg install tinc'

echo "========================================================="

echo "Pobieranie host name..."
command 'uci get system.@system[0].hostname'
HOST=$ret_val

echo "========================================================="
echo "Konfigurowanie WIFI-LAN..."
read -p "SSID:" ssid
echo -n "Hasło (min. 8 znaków):" 
read -s password

command "uci set wireless.full_radio0=wifi-iface"
command "uci set wireless.full_radio0.device='radio0'"
command "uci set wireless.full_radio0.network='lan'"
command "uci set wireless.full_radio0.mode='ap'"
command "uci set wireless.full_radio0.key='$password'"
command "uci set wireless.full_radio0.ssid='$ssid'"
command "uci set wireless.full_radio0.encryption='psk2'"
command "uci set wireless.full_radio0.ieee80211r='1'"

command "uci set wireless.local_radio0=wifi-iface"
command "uci set wireless.local_radio0.device='radio0'"
command "uci set wireless.local_radio0.network='lan'"
command "uci set wireless.local_radio0.mode='ap'"
command "uci set wireless.local_radio0.key='$password'"
command "uci set wireless.local_radio0.ssid='$ssid-$HOST'"
command "uci set wireless.local_radio0.encryption='psk2'"

command "uci commit"
command "service network restart"

echo "========================================================="
echo "Konfigurowanie TINC..."
command "ip -o -6 addr show bat0 | grep global | sed -e 's/^.*inet6 \([^/]\+\).*/\1/'"
IP=$ret_val
echo "BAT0 IP: $IP"

command "cat /dev/null > /etc/config/tinc"
command "mkdir /etc/tinc"
command "mkdir /etc/tinc/local"
command "mkdir /etc/tinc/local/hosts"

command "uci set tinc.local=tinc-net"
command "uci set tinc.local.enabled=1"
command "uci set tinc.local.generate_keys=0"
command "uci set tinc.local.key_size=2048"
command "uci set tinc.local.logfile='/tmp/log/tinc.log'"
command "uci set tinc.local.debug=3"

command "uci set tinc.local.AddressFamily=any"
command "uci set tinc.local.BindToAddress='$IP'"
command "uci set tinc.local.BindToInterface='bat0'"

command "uci set tinc.local.Forwarding='internal'"
command "uci set tinc.local.GraphDumpFile='/tmp/log/tinc.dot'"
command "uci set tinc.local.Hostnames='1'"

command "uci set tinc.local.Interface='tap0'"
command "uci set tinc.local.KeyExpire='3600'"
command "uci set tinc.local.MACExpire='600'"
command "uci set tinc.local.MaxTimeout='900'"
command "uci set tinc.local.Mode='switch'"
command "uci set tinc.local.Name='$HOST'"
command "uci set tinc.local.PrivateKeyFile='/etc/tinc/local/rsa_key.priv'"
command "uci set tinc.local.ProcessPriority='normal'"
command "uci set tinc.local.ReplayWindow='16'"
#list ConnectTo master

command "uci set tinc.$HOST=tinc-host"
command "uci set tinc.$HOST.enabled=1"
command "uci set tinc.$HOST.net=local"
command "uci set tinc.$HOST.Port=655"
command "uci set tinc.$HOST.Subnet='10.10.1.0/24'" # FIXME:

#config tinc-host ajmaster    
#        option enabled 1                                    
#        option net jordanek                                 
#        list Address fd70:3ac8:4d33:5fcd:b7e1:3e5a:d5f2:6f4
#        option Subnet 10.10.10.0/24

command "echo 'Name = $HOST' > /etc/tinc/local/tinc.conf"
command "echo 'Device = /dev/net/tun' >> /etc/tinc/local/tinc.conf"
command "tincd -n local -K"
