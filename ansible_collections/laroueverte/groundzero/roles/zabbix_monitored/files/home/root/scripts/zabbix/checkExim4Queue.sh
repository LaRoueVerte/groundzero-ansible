#!/bin/bash

if [[ $1 = "" ]] ; then
        echo "Usage : $0 seconds"
        echo "       seconds is the number of seconds to check for stuck messages"
        echo "       displays the count of messages stuck in queue for more than seconds"
        exit
fi

exiqgrep -bo $1 | wc -l
