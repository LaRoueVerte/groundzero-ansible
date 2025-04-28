#!/bin/bash

PKG=
COMMMAND=CONTINUE
while [[ ! "$COMMAND" = "X" ]]; do
	echo 
	echo "=================================="
	if [[ ! $PKG = "" ]]; then
		echo "Working on $PKG"
	fi
	echo "Type : "
	echo " X for exit"
	if [[ ! $PKG = "" ]]; then
		echo " D for checking Dependencies of $PKG"
		echo " A for checking other package install in Apt-get for $PKG_NOVER"
		echo " P for apt-get purge $PKG"
		echo " I for apt-get Install $PKG"
	fi
	echo " N for listing Not debian packages"
	echo " O for listing deborphan packages"
	echo " C, or any string starting with lowercase character, for changing package"
	NEXT=
	if [[ -e /tmp/deborphan.list ]];then
		NEXT=$(head -1 /tmp/deborphan.list)
		echo " S for Selecting next package $NEXT"
		echo " K for sKipping package $NEXT"
	fi
	read -r COMMAND;
	echo
	echo "=================================="

	FOUND=N
	if [[ ! $PKG = "" ]]; then
		case "$COMMAND" in
			D)
				FOUND=Y
				apt-cache rdepends -o APT::Cache::RecurseDepends=true --installed $PKG
			;;

			P)
				FOUND=Y
				apt-get purge $PKG
				if [[ "$NEXT" == "$PKG" ]]; then
					grep -v $PKG /tmp/deborphan.list > /tmp/deborphan.list.new
					mv /tmp/deborphan.list.new /tmp/deborphan.list
				fi
			;;

			I)
				FOUND=Y
				apt-get install $PKG
			;;

			A)
				FOUND=Y
				echo "Checking $PKG_NOVER"
				dpkg --list | grep $PKG_NOVER
			;;

			X)
				FOUND=Y
			;;
		esac
	fi
	if [[ $FOUND = "N" ]]; then
		case "$COMMAND" in
			N)
				FOUND=Y
				aptitude search '~i(!~ODebian)'
				aptitude search -F "%p" '~i(!~ODebian)' > /tmp/deborphan.list
			;;

			O)
				FOUND=Y
				deborphan --guess-all | tee /tmp/deborphan.list
			;;

			C)
				FOUND=Y
				echo "Type package name :"
				read -r PKG
			;;
			K)
				FOUND=Y
				grep -v $NEXT /tmp/deborphan.list > /tmp/deborphan.list.new
				mv /tmp/deborphan.list.new /tmp/deborphan.list
				echo "Skipped $NEXT"
			;;
			S)
				FOUND=Y
				if [[ "$NEXT" == "" ]]; then
					echo "No package to select"
				else
					PKG=$NEXT
				fi
			;;
			[a-z]*)
				FOUND=Y
				PKG=$COMMAND
			;;
		esac
		PKG_NOVER=`echo "$PKG" | sed -s 's/[0-9].*$//g'`
	fi
	if [[ $FOUND = "N" ]]; then
		echo "ERROR : Unknown option $COMMAND"
	fi
done
