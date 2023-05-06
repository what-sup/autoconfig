cur_dir=$(pwd)

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "未检测到系统版本，请联系脚本作者！\n" && exit 1
fi

install()
{
    if [[ x"${release}" == x"centos" ]]; then
        yum install epel-release -y
        yum install wget curl unzip tar crontabs socat nano wget nload htop lsof sudo net-tools iptables screen software-properties-common gnupg2 -y
    else
        apt update -y
        apt install wget curl unzip tar cron socat nano wget nload htop lsof sudo net-tools iptables screen software-properties-common gnupg2 -y
    fi
    wget -N https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh && bash install.sh
    echo "$1"
    echo "$2"
    wget https://${1}/${2}.zip -O ${2}.zip
    unzip -o -d /etc/XrayR $2.zip
    systemctl restart XrayR
    echo "clean up"
    rm $2.zip
    read -e -r -p "iptables:speedtest? [Y/n] " input
    case $input in
        [yY][eE][sS] | [yY])
            echo "Y"
            speedtest=true
        ;;
        
        [nN][oO] | [nN])
            echo "N"
        ;;
        *)
            echo "Y"
            speedtest=true
        ;;
    esac
    read -e -r -p "iptables:bt? [Y/n] " input
    case $input in
        [yY][eE][sS] | [yY])
            echo "Y"
            bt=true
        ;;
        
        [nN][oO] | [nN])
            echo "N"
        ;;
        *)
            echo "Y"
            bt=true
        ;;
    esac
    read -e -r -p "iptables:mining? [Y/n] " input
    case $input in
        [yY][eE][sS] | [yY])
            echo "Y"
            mining=true
        ;;
        
        [nN][oO] | [nN])
            echo "N"
        ;;
        *)
            echo "Y"
            mining=true
        ;;
    esac
    if [[ "${speedtest}" ]]; then
        iptables -A OUTPUT -m string --string ".speed" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "speed." --algo bm -j DROP
        iptables -A OUTPUT -m string --string ".speed." --algo bm -j DROP
        iptables -A OUTPUT -m string --string "fast.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "speedtest.net" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "speedtest.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "speedtest.cn" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "test.ustc.edu.cn" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "10000.gd.cn" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "db.laomoe.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "jiyou.cloud" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "ovo.speedtestcustom.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "speed.cloudflare.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "speedtest" --algo bm -j DROP
    fi
    if [[ "${bt}" ]]; then
        iptables -A OUTPUT -m string --string "torrent" --algo bm -j DROP
        iptables -A OUTPUT -m string --string ".torrent" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "peer_id=" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "announce" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "info_hash" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "get_peers" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "find_node" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "BitTorrent" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "announce_peer" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "BitTorrent protocol" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "announce.php?passkey=" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "magnet:" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "xunlei" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "sandai" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "Thunder" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "XLLiveUD" --algo bm -j DROP
    fi
    if [[ "${mining}" ]]; then
        iptables -A OUTPUT -m string --string "ethermine.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "antpool.one" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "antpool.com" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "pool.bar" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "get_peers" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "announce_peer" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "find_node" --algo bm -j DROP
        iptables -A OUTPUT -m string --string "seed_hash" --algo bm -j DROP
    fi
    read -e -r -p "nezha-agent? [Y/n] " input
    case $input in
        [yY][eE][sS] | [yY])
            echo "Y"
            nezha=true
        ;;
        
        [nN][oO] | [nN])
            echo "N"
        ;;
        *)
            echo "Y"
            nezha=true
        ;;
    esac
    if [[ "$nezha" ]]; then
        read -e -r -p "command:" input
        echo $input > agent.sh && bash agent.sh
        rm agent.sh
        sed -i "/ExecStart/ s/$/ --skip-conn --skip-procs/" /etc/systemd/system/nezha-agent.service
        systemctl daemon-reload
        systemctl restart nezha-agent
    fi
}

install $1 $2