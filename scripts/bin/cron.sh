#!/bin/bash

if [ `whoami` != "root" ]; then
	echo you have to be root!
	exit 1
fi

usage()
{
cat << EOF
usage: $0 options

This script retrives remote host status and applies upgrades

OPTIONS:
   -h      Show this message
   -v      Verbose
EOF

}
verbose=0

while getopts v opt
do
	case "$opt" in
		v)
			verbose=1
			;;
		?)
			usage
			exit 1
			;;
	esac
done

networks="192.168.0.3-100 192.168.1.2-254"
basedir=`dirname $0`/..

function log() {
	if [ $verbose -eq 1 ]; then
		echo "$@"
	fi
}

cpt_connected=0
cpt_failed=0
up_hosts=''

# $1 - network
function get_info() {
	if [ $# != 1 ]; then
		echo "$0: need network argument"
		return 1
	fi
	hosts=`nmap -sT -p22 $1 | grep "22/tcp open" -B4 | grep "Nmap scan report for " | sed -r 's/Nmap scan report for [a-zA-Z ]?*\(?([0-9.]*)\)?$/\1/'`

	for h in $hosts; do
		mkdir -p $basedir/reports/$h
		log $h
		cmds=`cat $basedir/bin/get_info.sh`
		s=`ssh -o "StrictHostKeyChecking no" -o "PasswordAuthentication no" $h "echo $cmds" 2>/dev/null`
		e=$?
		if [ $e -ne 0 ]; then
			echo $e > $basedir/reports/$h/connect_failed
			cpt_failed=$((cpt_failed+1))
			continue
		fi
		rm -f $basedir/reports/$h/connect_failed
		cpt_connected=$((cpt_connected+1))
		up_hosts="$up_hosts $h"
		echo "$s" > $basedir/reports/$h/report.json

		cd $basedir/updates/
		for u in *; do
			touch ../reports/$h/updates_list
			grep -q $u ../reports/$h/updates_list && continue
			log installing update $u on host $h
			rsync -a -e 'ssh -o "StrictHostKeyChecking no" -o "PasswordAuthentication no"' $u $h:/tmp/ && ssh $h /tmp/$u/exec.sh
			echo "$u $?" >> ../reports/$h/updates_list
		done
		cd - > /dev/null
	done
}

lock=`ps aux | grep -v grep |grep cron.sh 2>/dev/null| wc -l || echo 0`
[ $lock -gt 2 ] && echo already running && exit 0

for n in $networks; do
	log network: $n
	get_info $n
done

echo $cpt_connected $cpt_failed > $basedir/reports/count
echo $up_hosts > $basedir/reports/up_hosts
date "+%Y-%m-%d %H:%M:%S" > $basedir/reports/last_check
