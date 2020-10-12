#!/bin/bash

# *******************************************************
# *******************************************************
#
#   installIcecast
#
#   By Jay Wheeler, EarthWalk Software. 02-18-2016.
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
#    Copyright (C) 2016. EarthWalk Software
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#   Icecast constants - modify as needed
#
# *******************************************************
HOST="192.168.0.64"
RUNUSER="${USER}"

USERLIST=(jay)
CONFIGTYPE="full"

# *******************************************************
#
#   Setable options - change default,
#			or as command line options
#
# *******************************************************
TESTING=0	# Debug output if not 0
SILENT=0    # Set to 1 for absolutely NO output

declare -a CONFIGS
CONFIGS=(full,min,url,shout)

# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
USERS=""
CONFIGTYPE="full"

declare -a USERLIST		# an array of users

# *******************************************************
#
#    display
#      print message, if allowed
#
# *******************************************************
lmsConioDisplay()
{
    if [ ${SILENT} -eq 0 ]
    then
    	if [ $# == 2 ]
    	then
            echo -n "$1"
    	else
            echo "$1"
    	fi
    fi
}

# *******************************************************
#
#    lmsConioDebug
#      print debug message, if allowed
#
# *******************************************************
lmsConioDebug()
{
    if [ ${TESTING} -ne 0 ]
    then
        lmsConioDisplay "$1"
    fi
}

# *******************************************************
#
#    checkResult
#
# *******************************************************
checkResult()
{
    result=$1

    lmsConioDebug "(checkResult) result: ${result}"
    if [ $result -ne 0 ]
    then
	    lmsConioDebug "Command failed: $result"
        lmsConioDisplay "Exit with failure."
        exit 1
    fi
}

# *******************************************************
#
#    lmsConioPrompt
#
# *******************************************************
lmsConioPrompt()
{
    lmsConioDisplay "$1: " -n
    read
}

# *******************************************************
#
#    inputNoEcho
#
# *******************************************************
inputNoEcho()
{
    lmsConioDisplay "$1: " -n
    read -s
}

# *******************************************************
#
#    getUsers
#
# *******************************************************
getUsers()
{
	USERLIST=$(echo ${USERS} | tr "," "\n")
	for user in ${USERLIST}
	do
		lmsConioDebug "(getUsers) user name = ${user}"
	done

	if [ ${#USERLIST} -eq 0 ]
	then
		lmsConioDebug "(getUserrs) no user names provided"
		exit 1
	fi
}

# *******************************************************
#
#    addUsers
#
# *******************************************************
addUsers()
{
	lmsConioDebug "(addUsers) add users to icecast group"

	for user in ${USERLIST}
	do
		lmsConioDebug "(addUsers) adding user '$user'"
		sudo usermod --append --groups icecast $user
		checkResult $?
	done
}

# *******************************************************
#
#    validConfigOption
#
# *******************************************************
validConfigOption()
{
    local data=$1
    local found=1

	local configlist=$(echo ${CONFIGS} | tr "," "\n")

   	lmsConioDebug "(validConfigOption) looking for option: '${data}'"

    for value in ${configlist}
    do
    	lmsConioDebug "(validConfigOption) CHECK value: ${value}"

        if [ "$value" == "$data" ]
        then
    		lmsConioDebug "(validConfigOption) FOUND option: ${value}"
            found=0
            break
        fi
    done

   	lmsConioDebug "(validConfigOption) FOUND result: $found"
    return ${found}
}

# *******************************************************
#
#    getConfigType
#
# *******************************************************
getConfigType()
{
    if [ -z "${CONFIGTYPE}" ]
    then
    	debutOutput "(getConfigType) unspecified configuration type"
    	exit 2
    fi

	lmsConioDebug "(getConfigType) checking for configuration type: '${CONFIGTYPE}'"

	validConfigOption ${CONFIGTYPE}
	checkResult $?

	lmsConioDebug "(getConfigType) configuration '${CONFIGTYPE}' is VALID"
}

# *******************************************************
#
#   getHost
#     get host name/address
#
# *******************************************************
getHost()
{
    if [ -z "${HOST}" ]
    then
        lmsConioPrompt "Enter host name/address"

    	if [ -z "${REPLY}" ]
    	then
	        lmsConioDisplay "Missing host name"
            lmsConioDebug '(getHost) Quitting'
       	    exit 1
    	fi

	    HOST=${REPLY}
    fi

    lmsConioDebug "(getHost) host: ${HOST}"
}

# *******************************************************
#
#    installIcecastServer
#
# *******************************************************
installIcecastServer()
{
    lmsConioDebug "(main) install icecast"

	sudo dnf -y install icecast icecast-doc
	checkResult $?

    lmsConioDebug "(main) copying configuration"

	case "${CONFIGTYPE}" in

		full)
			sudo cp /usr/share/doc/icecast/conf/icecast.xml.dist /etc/icecast.xml
			;;

		min)
			sudo cp /usr/share/doc/icecast/conf/icecast_minimal.xml.dist /etc/icecast.xml
			;;

		url)
			sudo cp /usr/share/doc/icecast/conf/icecast_urlauth.xml.dist /etc/icecast.xml
			;;

		shout)
			sudo cp /usr/share/doc/icecast/conf/icecast_shoutcast_compat.xml.dist /etc/icecast.xml
			;;

	esac

	checkResult $?
}

# *******************************************************
#
#    lmsUtilIsUser
#
# *******************************************************
lmsUtilIsUser()
{
    ACTIVEUSER=$( whoami )

    if [[ "${RUNUSER}" == "root" || "${ACTIVEUSER}" == "root" ]]
    then
	    lmsConioDisplay ""
        lmsConioDisplay "    User = ${ACTIVEUSER} (${RUNUSER})"
	    lmsConioDisplay ""
        lmsConioDisplay "        installIcecast can only be run by a sudo user."
	    lmsConioDisplay ""

	    exit 2
    fi

    lmsConioDebug "(lmsUtilIsUser) User: ${ACTIVEUSER} (${RUNUSER})"
}


# *******************************************************
#
#    checkReuiredFields
#
# *******************************************************
checkRequiredFields()
{
    SILENTFLAG=${SILENT}
    SILENT=0

    lmsUtilIsUser

    getHost
	getUsers
	getConfigType

    SILENT=${SILENTFLAG}
}

# *******************************************************
#
#    displayHelp
#
# *******************************************************
displayHelp()
{
    lmsConioDisplay " "
    lmsConioDisplay "makeRepo [ [-h] [-a [ss]] [-c ss] [-d [nn]] [-q [nn]] [-u ss] [--help]"
    lmsConioDisplay " "
    lmsConioDisplay "  options:"
    lmsConioDisplay " "
    lmsConioDisplay "    -a = set Icecast Server host address/fqn"
    lmsConioDisplay "    -c = configuration copy type (full, min, url, shout)"
    lmsConioDisplay "    -u = comma-separated user list"
    lmsConioDisplay " "
    lmsConioDisplay "    -d = debug flag setting (0 = no debug, otherwise debug level)"
    lmsConioDisplay "    -q = quiet (no output) if set to non-zero"
    lmsConioDisplay "    -h = help (display this message)"
    lmsConioDisplay " "
    lmsConioDisplay " where nn = numeric value"
    lmsConioDisplay "       ss = string value"
}


# *******************************************************
#
#    Start Main Script
#
# *******************************************************

while test $# -gt 0
do
	case $1 in

		-a)
            HOST=$2
	        lmsConioDebug "Host: ${HOST}"
            shift
            ;;

		-c)
			CONFIGTYPE=$2
			lmsConioDebug "Config type: ${CONFIGTYPE}"
			shift
			;;

		-u)
            USERS=$2
	        lmsConioDebug "Users: ${USERS}"
            shift
            ;;

				# ***********************************************

        -d)
            TESTING=$2
	    	if [ -e $TESTING ]
	    	then
	        	TESTING=1
 	    	fi

        	if [ ! -z "${TESTING##*[!0-9]*}" ]
        	then
	    		lmsConioDebug "debug: $TESTING"
	    		shift
	    	else
	    		lmsConioDebug "debug: $TESTING -- Arguement is a NOT number..."
	    		TESTING=1
	    	fi
        	;;

		-q)
      		SILENT=1
	    	;;

		# ***********************************************

		-h)
	    	displayHelp
	    	exit 1
        	;;

		--help)
	    	displayHelp
	    	exit 1
        	;;

    	*)
        	echo >&2 "Invalid argument: $1"
        	;;

   	esac
   	shift

done

# *******************************************************

checkRequiredFields

sudo find /usr/bin/icecast 1>/dev/null 2>&1
if [ $? -ne 0 ]
then
	installIcecastServer
else
	lmsConioDebug "(main) icecast already installed"
fi

# ###################################################################

addUsers

# ###################################################################

lmsConioDebug "(main) create log files"
sudo touch /var/log/icecast/errors.log
checkResult $?

sudo touch /var/log/icecast/access.log
checkResult $?

# ###################################################################

lmsConioDebug "(main) chmod"
sudo chmod 666 /var/log/icecast/*.log
checkResult $?

# ###################################################################

lmsConioDebug "(main) setup firewall"
sudo firewall-cmd --permanent --add-port=8000/tcp
checkResult $?

sudo firewall-cmd --reload
checkResult $?

# ###################################################################

lmsConioDebug "(main) enable and start the icecast server"
sudo systemctl enable icecast.service
checkResult $?

sudo systemctl start icecast.service
checkResult $?

# ###################################################################

exit 0

