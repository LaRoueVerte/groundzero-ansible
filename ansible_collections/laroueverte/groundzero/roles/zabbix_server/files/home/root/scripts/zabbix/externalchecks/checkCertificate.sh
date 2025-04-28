#!/bin/bash

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
	echo "Usage : $0 domain days [debug] [nowww] [host] "
	echo "      domain is the domain to check, i.e. mycompany.net. Will try to check www.[domain] as well."
	echo "      days is the number of days the certificate is valid"
	echo "      debug is an optional boolean, if defined and values 'true' prints debug information "
	echo "      nowww is an optional boolean, if defined and values true, disables nowww. If false or omitted the given domain must not start with www"
	echo "      host is an optional host to contact for checking certificate. If not using SNI, the IP must be used to check the certificate. Default is the same as domain."
	exit
fi

DOMAIN=$1
DAYS=$2
NOWWW=$4

if [[ $NOWWW != "true" ]]; then
	echo ${DOMAIN} | grep www  2>&1 > /dev/null
	RES=$?
	if [[ $RES == "0" ]];then
		echo "${DOMAIN} can not start with www when nowww is false or omitted"
		echo 1;
		exit 1;
	fi
fi

COMMON_OPTIONS="-p 443 -c ${DAYS} --ignore-host-cn -w ${DAYS}" 
OPTIONS="${COMMON_OPTIONS} -m ${DOMAIN}"
OPTIONS_WWW="${COMMON_OPTIONS} -m www.${DOMAIN}"

if [[ $5 != "" ]]; then
     CHECKHOST=$5
     CERTOPTION="--sni ${DOMAIN} -H ${CHECKHOST} ${OPTIONS}"
     CERTOPTION_WWW="--sni www.${DOMAIN} -H ${CHECKHOST} ${OPTIONS_WWW}"
else
     CERTOPTION="-H ${DOMAIN} ${OPTIONS}"
     CERTOPTION_WWW="-H www.${DOMAIN} ${OPTIONS_WWW}"
fi

if [[ $3 == "true" ]];then
	echo "Using check_ssl_cert options : ${CERTOPTION}"
	echo "Using check_ssl_cert options www : ${CERTOPTION_WWW}"
fi

MY_DIR=$(dirname -- "$0")

OUT=`echo | $MY_DIR/check_ssl_cert.sh $CERTOPTION 2>&1`
RES=$?
if [[ $RES != "0" ]];then
	echo $OUT
	echo 2;
	exit 2;
fi

# NOWWW != "true" means perform www checks
if [[ $NOWWW != "true" ]]; then
	OUT=`echo | $MY_DIR/check_ssl_cert.sh $CERTOPTION_WWW 2>&1`
	RES=$?
	if [[ $RES != "0" ]];then
		echo $OUT
		echo 3;
		exit 3;
	fi
fi

echo "0"
exit 0