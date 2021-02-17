#!/bin/bash

# test update

CURDIR=`dirname $0`

function check_debian_pkg_running_processes()
{
	for i in dpkg apt-check apt-get aptitude; do
		ps aux | grep -v grep | grep -w $i > /dev/null && return 1
	done
	return 0
}

while [ 1 ]; do
	check_debian_pkg_running_processes && break
	sleep 5
done

date >> /tmp/test

exit 0
