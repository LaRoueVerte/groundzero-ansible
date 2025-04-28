#!/bin/bash
#Script checking that all sub process of apache2 have been restarted after apache graceful
#Return:
#    Display 0 (exit 0) if OK
#    Display 1 (exit 1) if Not OK.
#Can be used with "-debug" to display debug information

#Get apache PID from /var/run
APACHEPID=$(cat /var/run/apache2/apache2.pid)
if [[ $1 == "--debug" ]]; then
        echo "Apache PID =$APACHEPID"
fi

#Get the date apache changed state (could be something else than reload but subprocesses must restart in anyway) 
RELOADSTATEDATE=$(date -d "$(systemctl show apache2 | grep "StateChangeTimestamp=" | sed -E "s/StateChangeTimestamp=(.*)/\\1/g")" +"%Y-%m-%d %H:%M:%S")
if [[ $1 == "--debug" ]]; then
        echo "RELOADSTATEDATE=$RELOADSTATEDATE"
fi

#For each subprocess, get the date of the process and check if it's lower than parent PID. If so, return error 
for SUBPID in $(pgrep --parent $APACHEPID apache2); do
        SUBDATE=$(date  -d "$(stat /proc/$SUBPID | grep Mod | sed -E "s/Mod.+: (.*)/\\1/g")" +"%Y-%m-%d %H:%M:%S")
        if [[ $1 == "--debug" ]]; then
                echo "SUB=$SUBPID SUBDATE=$SUBDATE"
        fi
        if [[ "$SUBDATE" < "$RELOADSTATEDATE" ]]; then
                if [[ $1 == "--debug" ]]; then
                        echo "SUBPID $SUBPID has wrong date" 
                fi
                echo "1"
                exit 1
        fi
done
echo "0"
exit 0
