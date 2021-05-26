#!/bin/bash

logfile=/var/log/update_script.log
echo "================================================================================" >> $logfile
timedatectl | head -n 1 >> $logfile
echo "================================================================================" >> $logfile
apt-get update -y >> $logfile
apt-get upgrade -y >> $logfile
