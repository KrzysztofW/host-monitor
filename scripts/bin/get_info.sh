#!/bin/bash

installed_pkgs="teams onlyoffice pdfshuffler"
installed_pkgs_cmd=''
for i in $installed_pkgs; do
	cmd="dpkg -l | grep $i | grep ii | sed 's/ii[ ][ ]\([^ ]*\) .*/\1/'"
	if [ "$installed_pkgs_cmd" == "" ]; then
		installed_pkgs_cmd="$cmd"
	else
		installed_pkgs_cmd="$installed_pkgs_cmd;$cmd"
	fi
done

echo "{
      \"who\": \"`who | sed -r 's/([a-z.A-Z0-9]*) .*/\1/' | grep -v '^$' | sort -u|tr '\n' ' '`\",
      \"hostname\": \"`hostname`\",
      \"kernel\": \"`uname -r`\",
      \"version\" : \"`head -1 /etc/issue | sed 's/ \\\n \\\l//'`\",
      \"keyname\" : \"`ls /etc/openvpn/*.key 2>/dev/null | sed 's/.*\\/\(.*\).key/\1/'`\",
      \"pkgs\" : \"`eval $installed_pkgs_cmd| tr '\n' ' '`\",
      \"date\" : \"`date '+%Y-%m-%d %H:%M:%S'`\"
}"
