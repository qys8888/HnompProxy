#!/bin/bash
stty erase ^H

red='\e[91m'
green='\e[92m'
yellow='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
'amd64' | x86_64) ;;
*)
    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1
    ;;
esac

if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

if [ ! -d "/etc/ethminerpro/" ]; then
    mkdir /etc/ethminerpro/
fi

error() {
    echo -e "\n$red 输入错误!$none\n"
}

install_download() {
    installPath="/etc/ethminerpro"
    $cmd update -y
    if [[ $cmd == "apt-get" ]]; then
        $cmd install -y git curl wget supervisor
        service supervisor restart
    else
        $cmd install -y epel-release
        $cmd update -y
        $cmd install -y git curl wget supervisor
        systemctl enable supervisord
        service supervisord restart
    fi
    [ -d ./ethminerpro ] && rm -rf ./ethminerpro
    git clone https://github.com/ethminerpro/minerproxy.git

    if [[ ! -d ./minerproxy ]]; then
        echo
        echo -e "$red 克隆脚本仓库出错了...$none"
        echo
        echo -e " 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
        echo
        exit 1
    fi
    mv minerproxy ethminerpro
    cp -rf ./ethminerpro /etc/
    if [[ ! -d $installPath ]]; then
        echo
        echo -e "$red 复制文件出错了...$none"
        echo
        echo -e " 使用最新版本的Ubuntu或者CentOS再试试"
        echo
        exit 1
    fi
}

start_write_config() {
    echo
    echo "下载完成，开启守护"
    echo
    supervisorctl stop all
    chmod a+x $installPath/ethminerpro_linux
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/ethminerpro.conf -f
        echo "[program:ethminerpro]" >>/etc/supervisor/conf/ethminerpro.conf
        echo "command=${installPath}/ethminerpro_linux" >>/etc/supervisor/conf/ethminerpro.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf/ethminerpro.conf
        echo "autostart=true" >>/etc/supervisor/conf/ethminerpro.conf
        echo "autorestart=true" >>/etc/supervisor/conf/ethminerpro.conf
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/ethminerpro.conf -f
        echo "[program:ethminerpro]" >>/etc/supervisor/conf.d/ethminerpro.conf
        echo "command=${installPath}/ethminerpro_linux" >>/etc/supervisor/conf.d/ethminerpro.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ethminerpro.conf
        echo "autostart=true" >>/etc/supervisor/conf.d/ethminerpro.conf
        echo "autorestart=true" >>/etc/supervisor/conf.d/ethminerpro.conf
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/ethminerpro.ini -f
        echo "[program:ethminerpro]" >>/etc/supervisord.d/ethminerpro.ini
        echo "command=${installPath}/ethminerpro_linux" >>/etc/supervisord.d/ethminerpro.ini
        echo "directory=${installPath}/" >>/etc/supervisord.d/ethminerpro.ini
        echo "autostart=true" >>/etc/supervisord.d/ethminerpro.ini
        echo "autorestart=true" >>/etc/supervisord.d/ethminerpro.ini
    else
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " Supervisor安装目录没了，安装失败"
        echo
        exit 1
    fi

    if [[ $cmd == "apt-get" ]]; then
        ufw disable
    else
        systemctl stop firewalld
    fi

    changeLimit="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 60000" >>/etc/security/limits.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root hard nofile 60000" >>/etc/security/limits.conf
        changeLimit="y"
    fi

    clear
    echo
    echo "----------------------------------------------------------------"
    echo
    if [[ "$changeLimit" = "y" ]]; then
        echo "系统连接数限制已经改了，如果第一次运行本程序需要重启!"
        echo
    fi
    supervisorctl start all
    supervisorctl reload
    echo "如果还无法连接，请到云服务商控制台操作安全组，放行对应的端口"
    echo
    echo "安装完成...守护模式无日志，需要日志的请以nohup ./ethminerpro_linux &方式运行"
    echo
    echo "以下配置文件：/etc/ethminerpro/conf.yaml，网页端可修改登录密码token"
    echo
    echo "[*---------]"
    sleep 1
    echo "[**--------]"
    sleep 1
    echo "[***-------]"
    sleep 1
    echo "[****------]"
    sleep 1
    echo "[*****-----]"
    sleep 1
    echo "[******----]"
    echo
    cat /etc/ethminerpro/conf.yaml
    echo "----------------------------------------------------------------"
}

uninstall() {
    clear
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/ethminerpro.conf -f
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/ethminerpro.conf -f
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/ethminerpro.ini -f
    fi
    supervisorctl reload
    echo -e "$yellow 已关闭自启动${none}"
}



update(){

    supervisorctl stop ethminerpro
    [ -d ./ethminerpro ] && rm -rf ./ethminerpro
    [ -d ./minerproxy ] && rm -rf ./minerproxy


    git clone https://github.com/ethminerpro/minerproxy.git

    if [[ ! -d ./minerproxy ]]; then
        echo
        echo -e "$red 克隆脚本仓库出错了...$none"
        echo
        echo -e " 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
        echo
        exit 1
    fi
    mv minerproxy ethminerpro
    rm /etc/ethminerpro/ethminerpro_linux -f
    cp -rf ./ethminerpro/ethminerpro_linux /etc/ethminerpro/ethminerpro_linux


    chmod a+x /etc/ethminerpro/ethminerpro_linux
    supervisorctl start ethminerpro


    sleep 2s
    echo "ethminerpro 已經更新至V1.0.0版本並啟動"
    cat /etc/ethminerpro/conf.yaml
    echo ""
    echo "以上是配置文件信息"
}



start(){

    supervisorctl start ethminerpro
    
    echo "ethminerpro已啟動"
}


restart(){
    supervisorctl restart ethminerpro

    echo "ethminerpro 已經重新啟動"
}


stop(){
    supervisorctl stop ethminerpro
    echo "ethminerpro 已停止"
}



change_limit(){
    if grep -q "1000000" "/etc/profile"; then
        echo -n "您的系統連接數限制可能已修改，當前連接限制："
        ulimit -n
        exit
    fi

    cat >> /etc/sysctl.conf <<-EOF
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100

net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768

# forward ipv4
# net.ipv4.ip_forward = 1
EOF

    cat >> /etc/security/limits.conf <<-EOF
*               soft    nofile          1000000
*               hard    nofile          1000000
EOF

    echo "ulimit -SHn 1000000" >> /etc/profile
    source /etc/profile

    echo "系統連接數限制已修改，手動reboot重啟下系統即可生效"
}


check_limit(){
    echo -n "您的系統當前連接限制："
    ulimit -n
}

clear
while :; do
    echo
    echo "-------- ethminerpro 一键安装脚本 by:ethminerpro--------"
    echo "github下载地址:https://github.com/ethminerpro/minerproxy"
    echo "官方电报群:https://t.me/trexminerproxy"
    echo
    echo " 1. 安  装"
    echo
    echo " 2. 卸  载"
    echo
    echo " 3. 更  新"
    echo
    echo " 4. 启  动"
    echo
    echo " 5. 重  启"
    echo
    echo " 6. 停  止"
    echo
    echo " 7. 一鍵解除Linux連接數限制(需手動重啟系統生效)"
    echo
    echo " 8. 查看當前系統連接數限制"
    echo
    read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
    case $choose in
    1)
        install_download
        start_write_config
        break
        ;;
    2)
        uninstall
        break
        ;;
    3)
        update
        ;;
    4)
        start
        ;;
    5)
        restart
        ;;
    6)
        stop
        ;;
    7)
        change_limit
        ;;
    8)
        check_limit
        ;;

    *)
	echo "error請輸入正確的數字！"
        ;;
    esac
done
