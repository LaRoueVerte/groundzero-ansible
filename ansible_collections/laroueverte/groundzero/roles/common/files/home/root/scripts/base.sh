#!/bin/bash
function showHeader() {
	echo "["`date  +%Y-%m-%d\ %H\:%M\:%S`"]Running script: $0 on host = "`hostname`
}
function  testResult () {
	RES=$?
	if [ $RES"" != "0" ]; then
         echo "Erreur ? ";
         if [[ "$1" != "" ]]; then
			eval $1
	     fi
         exit $RES;
    fi
	export TESTED_RESULT=$RES
}

function testExistFichier() {
	if [ ! -e $1"" ]; then
		echo "Le fichier $1 n'existe pas!!!";
		return 2
	fi;
	return 0;
}


function testPGDatabase() {
	psql -U postgres -c "select 1" -d $1 > /dev/null 2>&1
	RES=$?
	if [ $RES"" != "0" ]; then
		echo "La base de donnees $1 n'existe pas!!";
		echo "Liste des bases de donnees existentes:"
		psql -U postgres -c '\l'
		return 1
	fi
	return 0;

}

function startScript() {
	eval START_SCRIPT_$1=`date +%s`
}

function endScript() {
	eval END_SCRIPT_$1=`date +%s`
	eval EXPR=\$\(\( \$END_SCRIPT_$1 \- \$START_SCRIPT_$1 \)\)
	DURATION=$(( $EXPR  ))
	endScriptTime $1 $DURATION

}	

function endScriptTime() {
	DURATION=$2
        echo "["`date  +%Y-%m-%d\ %H\:%M\:%S`"] Duration of this script $1 is $DURATION seconds"
        if [[ -x /usr/bin/zabbix_sender ]]; then
        	/usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k $1State -o $DURATION
       	else
       		echo /usr/bin/zabbix_sender not found, skipping sending script time to zabbix
        fi
}

function sendZabbixTrapperValue() {
    if [[ -x /usr/bin/zabbix_sender ]]; then
		/usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k $1 -o $2
   	else
   		echo /usr/bin/zabbix_sender not found, skipping sending trapper value to zabbix
    fi
}

