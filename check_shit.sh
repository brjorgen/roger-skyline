#!/bin/bash

RED='\033[0;33m'
NC='\033[0m'

function do_task () {
    case $1 in
	"disk-size")
	    df --output --si | head -n 1 ; df --output --si | grep "/home"
	    ;;
	"sudoers")
	    # str8 to the point.
	    echo -e "${RED}===== non-root user is in group sudo ===== ${NC}"
	    groups brian  | grep --color sudo
	    echo -e "${RED}========================================== ${NC}"
	    ;;
	"static-ip")
	    echo -e "${RED}===== ip stuff ============== ${NC}"
	    # I mean, might aswell. Here we go, exactly what we care about.
	    /sbin/ifconfig -a enp0s3 | grep inet
	    echo -e "${RED}===== interface config ====== ${NC}"
	    # Where we had to change some stuff to make it werk.
	    cat /etc/network/interfaces
	    ;;
	"ssh")
	    echo -e "${RED}===== ssh status ===== ${NC}"
	    # full command shows journalctl log, also shows port.
	    systemctl status ssh | head -n 3 
	    echo -e "${RED}====== ssh port ====== ${NC}"
	    # straight to the source, baby.
	    grep -i "port" /etc/ssh/sshd_config | head -n 1
	    echo -e "${RED}====== ssh keys ====== ${NC}"
	    ls -la /home/brian/.ssh | grep .pub
	    echo -e "${RED}====================== ${NC}"
	    ;;
	"firewall")
	    ## Try to log in as root through ssh to see ban report on ip.
	    echo -e "${RED}===== ufw status (iptable wrapper firewall) ===== ${NC}"
	    /sbin/ufw status
	    ;;
	"dos")
	    echo -e "${RED}========== fail2ban firewall status ============= ${NC}"
	    ## who cares about the rest of the info? we might aswell cut to the chase.
	    systemctl status fail2ban | head -n 3
	    echo -e "${RED}============== fail2ban config ================== ${NC}"
	    cat /etc/fail2ban/jail.d/jail-debian.local
	    echo -e "${RED}============== fail2ban log tail ================ ${NC}"
	    ## Only show the latest stufferino by only reading the tail
	    tail /var/log/fail2ban.log
	    echo -e "${RED}============== fail2ban ssh status ============== ${NC}"
	    ## 'Cause at the end of the day, that's the only real point of entry to this system.
	    fail2ban-client status sshd
	    ;;
	"port-scan")
	    echo -e "${RED}===  psad status(port scan monitoring daemon) === ${NC}"
	    ## This is another daemon that works with iptables. It scans the report files for sus
	    ## stuff.
	    systemctl status psad | head -n 3 # or, if you prefer, ps -A | grep "psad"
	    echo -e "${RED}================ psad conf ====================== ${NC}"
	    echo "Truncated. see /etc/psad/psad.conf for config."
	    ;;
	"active-services")
	    echo -e "${RED}====== active services ====== ${NC}"
	    # glory to grep
	    service --status-all | grep +
	    echo -e "${RED}============================= ${NC}"
	    ;;
	"cron")
	    echo -e "${RED}====== cron job list ======== ${NC}"
	    # root aint got no cron tab yet
	    crontab -l
	    echo -e "${RED}============================= ${NC}"
	    ;;
	"open-ports")
	    echo -e "${RED}==== machine's open ports === ${NC}"
	    lsof -i -P -n | grep LISTEN
	    echo -e "${RED}============================= ${NC}"
	    ;;
	*)
	    echo -e "${RED}unhandled option.\
usage:\n\tsudo ./check_shit.sh [sudoers/firewall/port-scan/\
ssh/static-ip/active-services/open-ports/cron/dos/all] ${NC}"
	    ;;
    esac
}

case $1 in
    "all")
	requirements=(
	    "sudoers"
	    "static-ip"
	    "ssh"
	    "firewall"
	    "port-scan"
	    "open-ports"
	    "active-services"
	    "cron"
	    "dos"
	)

	for i in "${requirements[@]}"
	do
	    do_task $i
	done
	echo -e "Ran all the checks. Hope it went well!"
	;;
    *)
	do_task $1
	;;
esac
