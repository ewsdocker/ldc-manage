#!/bin/bash

# *******************************************************
# *******************************************************
#
#   createAdminAccounts
#
#   By Jay Wheeler, EarthWalk Software. 02-19-2016.
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
#   Global constants - modify as needed
#
# *******************************************************
HOST="192.168.0.64"
RUNUSER="${USER}"

USERS=""
SETGROUPS="wheel,yumex,lightdm,vboxsf"

# *******************************************************
#
#   Setable options - change default,
#			or as command line options
#
# *******************************************************
TESTING=0	# Debug output if not 0
SILENT=0    # Set to 1 for absolutely NO output

# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
declare -a USERLIST		# an array of users
declare -a GROUPLIST	# an array of groups to add users to

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
#    getGroups
#
# *******************************************************
getGroups()
{
	GROUPLIST=$(echo ${SETGROUPS} | tr "," "\n")
	for name in ${GROUPLIST}
	do
		lmsConioDebug "(getGroups) group name = ${name}"
	done

	if [ ${#GROUPLIST} -eq 0 ]
	then
		lmsConioDebug "(getGroups) no group names provided"
		exit 1
	fi
}

# *******************************************************
#
#    getUsers
#
# *******************************************************
getUsers()
{
	USERLIST=$(echo ${USERS} | tr "," "\n")
	for name in ${USERLIST}
	do
		lmsConioDebug "(getUsers) user name = ${name}"
	done

	if [ ${#USERLIST} -eq 0 ]
	then
		lmsConioDebug "(getUsers) no user names provided"
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
	lmsConioDebug "(addUsers) add users to groups"

	for user in ${USERLIST}
	do
		lmsConioDebug "(addUsers) adding user '$user'"
		sudo adduser --create-home --user-group --groups ${SETGROUPS} $user 1>/dev/null 2>&1
		checkResult $?
	done
}

# *******************************************************
#
#    checkGroups
#
# *******************************************************
checkGroups()
{
	lmsConioDebug "(checkGroups) check the groups list: " $GROUPLIST

	for name in ${GROUPLIST}
	do
		lmsConioDebug "(checkGroups) checking group '$name'"

		sudo getent group $name 1>/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			lmsConioDisplay "Non-existent group: $name"
			lmsConioDebug "(checkGroups) non-existent group: $name"
			exit 1
		fi
	done
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
        lmsConioDisplay "        createAdminAccounts can only be run by a sudo user."
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

	getGroups
	getUsers

	checkGroups

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
    lmsConioDisplay "createAdminAccounts [ [-h] [-a ss] [-g ss] [-u ss] [-d [nn]] [-q [nn]] [--help]"
    lmsConioDisplay " "
    lmsConioDisplay "  options:"
    lmsConioDisplay " "
    lmsConioDisplay "    -a = append comma separted group list to default group list"
    lmsConioDisplay "    -g = comma separted group list"
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
			SETGROUPS="$SETGROUPS,$2"
	        lmsConioDebug "Appended groups '$2': $SETGROUPS"
            shift
            ;;

		-g)
            SETGROUPS=$2
	        lmsConioDebug "Groups: ${SETGROUPS}"
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

# ###################################################################

addUsers

# ###################################################################

exit 0

