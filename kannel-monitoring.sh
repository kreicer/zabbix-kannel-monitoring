#!/bin/bash

#Author: kreicer
#Version: 0.5
#Requirements: xmllint (apt-get install libxml2-utils)

xmlstatus=$1
zabbixconf="/etc/zabbix/zabbix_agentd.conf"
xmlpath="/tmp/kannel-monitoring.xml"
outpath="/tmp/smscstat.txt"

case $2 in
	discovery)
		curl "$xmlstatus" -o $xmlpath --silent
		echo '{"data":['
		xmllint --xpath "//smsc/id" $xmlpath | sed 's/<\/id>/"},\n/g' | sed 's/<id>/{"{#SMSC}"\:"/g' | sed '$ s/.$//'
		echo ']}'
		;;
	data)
		curl "$xmlstatus" -o $xmlpath --silent
		
		cat /dev/null > $outpath
		
		for smsc in $(xmllint --xpath "/gateway/smscs/smsc/id" $xmlpath | sed 's/<\/id>/ /g' | sed 's/<id>//g');
		do
		
			status=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/status/text()' $xmlpath | awk '{print $1}')
			echo "$3 kannel[$2,$smsc,status] $status" >> $outpath
			
			uptime=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/status/text()' $xmlpath | awk '{print $2}' | sed 's/s//g')
			echo "$3 kannel[$2,$smsc,uptime] $uptime" >> $outpath
			
			sms_rcvd=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/sms/received/text()' $xmlpath)
			echo "$3 kannel[$2,$smsc,sms_rcvd] $sms_rcvd" >> $outpath
			
			dlr_rcvd=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/dlr/received/text()' $xmlpath)
			echo "$3 kannel[$2,$smsc,dlr_rcvd] $dlr_rcvd" >> $outpath
			
			sms_sent=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/sms/sent/text()' $xmlpath)
			echo "$3 kannel[$2,$smsc,sms_sent] $sms_sent" >> $outpath
			
			dlr_sent=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/dlr/sent/text()' $xmlpath)
			echo "$3 kannel[$2,$smsc,dlr_sent] $dlr_sent" >> $outpath
			
			failed=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/failed/text()' $xmlpath)
			echo "$3 kannel[$2,$smsc,failed] $failed" >> $outpath
			
			queued=$(xmllint --xpath '/gateway/smscs/smsc[id="'"$smsc"'"]/queued/text()' $xmlpath)
			echo "$3 kannel[$2,$smsc,queued] $queued" >> $outpath
		
		done
		
		kannel_status=$(xmllint --xpath "/gateway/status/text()" $xmlpath | awk '{print $1}' | sed 's/,//g')
		echo "$3 kannel[$2,status] $kannel_status" >> $outpath
		
		kannel_sms_rcvd=$(xmllint --xpath "/gateway/sms/received/total/text()" $xmlpath)
		echo "$3 kannel[$2,sms_rcvd] $kannel_sms_rcvd" >> $outpath
		
		kannel_sms_sent=$(xmllint --xpath "/gateway/sms/sent/total/text()" $xmlpath)
		echo "$3 kannel[$2,sms_sent] $kannel_sms_sent" >> $outpath
		
		kannel_dlr_rcvd=$(xmllint --xpath "/gateway/dlr/received/total/text()" $xmlpath)
		echo "$3 kannel[$2,dlr_rcvd] $kannel_dlr_rcvd" >> $outpath
		
		kannel_dlr_sent=$(xmllint --xpath "/gateway/dlr/sent/total/text()" $xmlpath)
		echo "$3 kannel[$2,dlr_sent] $kannel_dlr_sent" >> $outpath		
		
		zabbix_sender -c $zabbixconf -i $outpath &>/dev/null
		date
		;;
	*) 
		echo "Usage: ./kannel-monitoring.sh [statuspage xml address] [discovery|data] [if data: host for receiving info]"
		;;
esac
