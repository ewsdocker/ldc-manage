#!/bin/bash

# *******************************************************
# *******************************************************
#
#   createNetworkShare
#
#   By Jay Wheeler, EarthWalk Software. 02-19-2016.
#    Copyright (C) 2016. EarthWalk Software
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#   Global constants - modify as needed
#
#   Setable options - change default, or as command line options
#
# *******************************************************

MOUNTNAME=""				# (m) Name of the share mount point
MOUNTGROUP="netshare"		# (g) the default network share group
MOUNTPATH="/mnt/Multimedia" # (p) path to the mount point on the local host

SHARE="192.168.0.6"			# (nh) the default network share server
SHAREMOUNT=""				# (nS) Name of the share to be mounted

SHAREUSER="netshare"		# (nu) the default network share user (owner)
SHAREPASS=""				# (np) the network share password (owner)

USERS=""					# (u) list of users to enable for the share

CREDNAME=".credentials"		# Name of the credentials file
CREDPATH="/var/local"		# Path to the credentials file
CREDFILE=""					# Credentials file (path + name)

# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************

declare -a USERLIST			# an array of users
declare -a GROUPLIST		# an array of groups to add users to
declare -A GROUPIDS			# an associative array of group name => id
declare -A CLIPARAMETERS	# an associative array of parameters modified by cli

VERS="1.0"

RUNUSER="${USER}"			# the name of the user running this script
OVERRIDE=0					# set to 1 to lmscli_optOverride the SILENT flag

# *******************************************************
# *******************************************************
#
#	External Functions
#
# *******************************************************
# *******************************************************

. ShellSnippets/lmsConio.sh
. ShellSnippets/lmsError.sh

# *******************************************************
# *******************************************************
#
#	Functions
#
# *******************************************************
# *******************************************************

TESTING=0					# (d) Debug output if not 0
SILENT=0    				# (q) Quiet setting: non-zero for absolutely NO output
BATCHIN=0					# (b) Batch mode - missing parameters fail
OVERRIDE=0					# set to 1 to lmscli_optOverride the SILENT flag

# *******************************************************
#
#    initializeErrorCodes
#
#		add error codes and messages to the proper error
#			arrays
#
# *******************************************************
initializeErrorCodes()
{
	# *******************************************************
	#
	#	Place error code name and message here to be added
	#		to the ErrorMsgs associative array
	#
	#		Format: addError <Error-Code-Name> <Error-code-description>
	#
	#		Example:  addError Error_None "No error occured."
	#
	# *******************************************************

	# **************************************************************************
	#
	#	the followin line should always be the first addErrorCode
	#
	addErrorCode Error_None         "No error occured."

	# **************************************************************************
	#
	#	place calls to addErrorCode between this comment block and the next comment block
	#
	addErrorCode Error_NotRoot      "Program must be run by root only."

	addErrorCode Error_ParamErrors  "Parameter errors were detedted."
	addErrorCode Error_ShareUser    "Missing required parameter (-nu)."
	addErrorCode Error_SharePass    "Missing required parameter (-np)."
	addErrorCode Error_NoPass       "SharePass not entered."

	addErrorCode Error_NonGroup     "Non-existent group (-g)."
	addErrorCode Error_TouchFailed  "Touch credentials file failed."
	addErrorCode Error_ChownFailed  "chown on credentials file failed."
	addErrorCode Error_ChmodFailed  "chmod on credentials file failed."
	addErrorCode Error_CreateFolder "Could not create the credentials file."
	addErrorCode Error_WriteError   "Could not write to the credentials file."

	# **************************************************************************
	#
	#	the following addErrorCode line sholuld always be the last line added
	#
	addErrorCode Error_Unknown   "Unknown error."

	# *******************************************************

	lmsConioDebug addErrorCodes " "
	lmsConioDebug addErrorCodes "Total errors: ${#ErrorCode[@]}"
}

# *******************************************************
#
#    checkResult
#
#		check the result provided for error code - exit if found
#
#	parameters:
#		result = the result to check
#
# *******************************************************
checkResult()
{
    local result=$1
    local message=$2

    lmsConioDebug "checkResult" "result: ${result}"
    if [ $result -ne 0 ]
    then
    	if [ ! -z "${message}" ]
    	then
        	lmsConioDisplay "$message ($result)"
    	fi

        exit $result
    fi
}

# *******************************************************
#
#    checkUser
#
#		check for the validity of the provided user
#
#	parameters:
#		name = the name to check for
#
#	returns:
#		sets $? to 0 if valid, 1 if not
#
# *******************************************************
checkUser()
{
	set -o pipefail
	USERID[$name]="$(sudo getent passwd $name | cut -d: -f3)"
	if [ $? -ne 0 ]
	then
		if [ $? -ne 9 ]
		then
			lmsConioDebug "checkUser" "non-existent user: $name"
			return 1
		fi
	fi

	lmsConioDebug "checkUser" "user '$name' = '${USERID[${name}]}'"
	return 0

}

# *******************************************************
#
#    getUser
#
#		get the users from the provided list
#
#	parameters:
#		check = 1 to check validity of the name, otherwise don't
#
# *******************************************************
getUser()
{
	local checkExists=$1

	USERLIST=$(echo ${USERS} | tr "," "\n")
	if [ ${#USERLIST} -eq 0 ]
	then
		lmsConioDisplay "No user names provided."
		exit 1
	fi

	for name in ${USERLIST}
	do
		lmsConioDebug "getUser" "user name = ${name}"
		if [ "${checkExists}" != "0" ]
		then
			checkUser $name
			if [ $? -ne 0 ]
			then
				lmsConioDisplay "Non-existent user: $name"
				exit $?
			fi
		fi
	done

}

# *******************************************************
#
#    addUserToGroups
#
#		add each user to the specified user to the requested groups
#
# *******************************************************
addUserToGroups()
{
	lmsConioDebug "addUserToGroups" "add user to groups"

	for user in ${USERLIST}
	do
		lmsConioDebug "addUserToGroups" "adding user '$user'"

		sudo usermod --append --groups ${MOUNTGROUP} $user 1>/dev/null 2>&1
		checkResult $? "usermod failed"

		lmsConioDisplay "User '${user}' added to groups '${MOUNTGROUP}'"
	done
}

# *******************************************************
#
#    checkGroup
#
#		check the validity of the provided group
#
#	parameters:
#		name = group to check
#
# *******************************************************
checkGroup()
{
	local name=$1
	local create=0

	if [ ! -z "$2" ]
	then
		create=$2
	fi

	lmsConioDebug "checkGroup" "Group '$name', create = ${create}"

	set -o pipefail
	GROUPIDS[$name]="$(sudo getent group $name | cut -d: -f3)"
	if [ $? -ne 0 ]
	then

		lmsConioDebug "checkGroup" "non-existent group: $name"

		if [ $create -ne 0 ]
		then
			lmsConioDebug "checkGroup" "Creating non-existent group: $name"

			sudo groupadd $name 1>/dev/null 2>&1
			checkGroup $1 0
			return 0
		fi

		lmsConioDisplay "Unable to create non-existent group: $name"
		lmsConioDebug "checkGroup" "non-existent group: $name"
		exit $?
	fi

	lmsConioDebug "checkGroups" "gid '${GROUPIDS[${name}]}'"
}

# *******************************************************
#
#    createGroups
#
#		create all provided group names
#
# *******************************************************
createGroups()
{
	lmsConioDebug "createGroups" "parsing MOUNTGROUP"

	GROUPLIST=$(echo ${MOUNTGROUP} | tr "," "\n")
	lmsConioDebug "createGroups" "groups list: " $GROUPLIST

	for name in ${GROUPLIST}
	do
		checkGroup $name 1
		lmsConioDebug "createGroups" "group $name = ${GROUPIDS[$name]}"
	done
}


# *******************************************************
#
#    checkIPAddress
#
#		Check if the provided ip address is in IPv4 format
#
# *******************************************************
checkIPAddress()
{
	local ip="$1"

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		lmsConioDebug "checkIPAddress" "'$ip' is a valid IPv4 format"
    	return 0
	fi

	lmsConioDebug "checkIPAddress" "'$ip' is NOT a valid IPv4 format"
	return 1
}

# *******************************************************
#
#    checkShareHostAddress
#
#		check that SHARE is provided and valid IPv4
#
# *******************************************************
checkShareHostAddress()
{
	lmsConioDebug "checkShareHostAddress" "checking SHARE '${SHARE}' is IPv4 format"

	checkIPAddress $SHARE
	if [ $? -ne 0 ]
	then
		lmsConioDebug "checkShareHostAddress" "SHARE '${SHARE}' is NOT a valid IPv4 format"
		exit 1
	fi

	lmsConioDebug "checkShareHostAddress" "SHARE '${SHARE}' is a valid IPv4 format"
}

# *******************************************************
#
#    createShareAddress
#
#		create a network share address string
#
# *******************************************************
createShareAddress()
{
	SHAREADDRESS="//$SHARE/$SHAREMOUNT"
	lmsConioDebug "createShareAddress" "SHARE address = ${SHAREADDRESS}"
}

# *******************************************************
#
#    createShareCredentials
#
# *******************************************************
createShareCredentials()
{
	CREDFILE=$CREDPATH/$MOUNTGROUP
	lmsConioDebug "createShareCredentials" "CREDFILE = ${CREDFILE}"

	sudo stat $CREDFILE 1>/dev/null 2>&1
	if [ $? -ne 0 ]
	then
		sudo mkdir -p $CREDFILE
		checkResult $? "Could not create '$CREDFILE'"

		CREDFILE="$CREDFILE/$CREDNAME"

		lmsConioDebug "createShareCredentials" "CREDFILE = $CREDFILE"

		su - root -c "touch $CREDFILE"
		checkResult $? "Could not touch $CREDFILE"

#		lmsConioDebug "createShareCredentials" "Changing owner"
#		sudo chown root:wheel 1>/dev/null 2>&1
#		checkResult $? "Unable to chown $CREDFILE"

su - root -c "cat << EOF > $CREDFILE
USERNAME=$SHAREUSER
PASSWORD=$SHAREPASS
EOF"

		checkResult $? "Could not write $CREDFILE"

		sudo chown root:wheel $CREDFILE 1>/dev/null 2>&1
	fi

	lmsConioDebug "createShareCredentials" "Created file $CREDFILE"
}

# *******************************************************
#
#    getSharePwd
#
#		request a login password for the network share
#
# *******************************************************
getSharePwd()
{
	lmsConioDebug "getSharePwd" "Requesting SHAREPASS"

	lmsConioPrompt "Enter a login password for ${SHAREUSER} on ${SHARE}" -n
	checkResult $? "Missing SHAREPASS"

	SHAREPASS=$REPLY
}

# *******************************************************
#
#    checkSharePwd
#
#		check that SHAREPASS is provided, otherwise request it
#
# *******************************************************
checkSharePwd()
{
	lmsConioDebug "checkSharePwd" "checking SHAREPASS"

	if [ -z "${SHAREPASS}" ]
	then
		getSharePwd
	fi

	lmsConioDebug "checkSharePwd" "SHAREPASS = '${SHAREPASS}'"
}

# *******************************************************
#
#    checkShareUser
#
#		check that SHAREUSER is provided
#
# *******************************************************
checkShareUser()
{
	lmsConioDebug "checkShareUser" "checking SHAREUSER"

	if [ -z "${SHAREUSER}" ]
	then
		lmsConioDebug "checkShareUser" "SHAREUSER is missing."
		exit 1
	fi

	lmsConioDebug "checkShareUser" "SHAREUSER = '${SHAREUSER}'"
}

# *******************************************************
#
#    checkShareMount
#
#		check that SHAREMOUNT is provided
#
# *******************************************************
checkShareMount()
{
	lmsConioDebug "checkShareMount" "checking SHAREMOUNT"

	if [ -z "${SHAREMOUNT}" ]
	then
		lmsConioDebug "checkShareMount" "SHAREMOUNT is missing."
		exit 1
	fi

	lmsConioDebug "checkShareMount" "SHARMOUNT = '${SHAREMOUNT}'"
}

# *******************************************************
#
#    lmsUtilIsUser
#
#		check for not root and not sudo execution
#
# *******************************************************
lmsUtilIsUser()
{
    lmsConioDebug "lmsUtilIsUser" "Checking if running by valid user"

    ACTIVEUSER=$( whoami )

    if [[ "${RUNUSER}" == "root" || "${ACTIVEUSER}" == "root" ]]
    then
	    lmsConioDisplay ""
        lmsConioDisplay "    User = ${ACTIVEUSER} (${RUNUSER})"
	    lmsConioDisplay ""
        lmsConioDisplay "        ${BASENAME} can only be run by a normal user with sudoer privilege."
	    lmsConioDisplay ""

	    exit 2
    fi

    lmsConioDebug "lmsUtilIsUser" "User: ${ACTIVEUSER} (${RUNUSER})"
}

# *******************************************************
#
#    checkReuiredFields
#
# *******************************************************
checkRequiredFields()
{
	lmsUtilIsUser
	getUser

	checkShareHostAddress
	checkShareUser
	checkSharePwd
	checkShareMount
}

# *******************************************************
#
#    displayHelp
#
#		Display help message block
#
# *******************************************************
displayHelp()
{
    lmsConioDisplay " "
    lmsConioDisplay "  ${BASENAME} [-h] [--help] [-v]"
    lmsConioDisplay "  ${BASENAME} [-g ss] [-h ss] [-m ss] [-n ss] [-u ss]"
    lmsConioDisplay "              [-nh ss] [-ns ss] [-nu ss] [-np ss]"
    lmsConioDisplay "              [-d [nn]] [-q [nn]]"
    lmsConioDisplay " "
    lmsConioDisplay "    -nh = network share server host address/name"
    lmsConioDisplay "    -ns = network share server share mount name"
    lmsConioDisplay "    -nu = network share server login user"
    lmsConioDisplay "    -np = network share server login password"
    lmsConioDisplay " "
    lmsConioDisplay "    -g = local host group name"
	lmsConioDisplay "    -m = local host mount name"
    lmsConioDisplay "    -p = local host mount path (absolute) to the folder"
    lmsConioDisplay "    -u = comma-separated user list of users to add to the group"
    lmsConioDisplay " "
    lmsConioDisplay "    -d = debug flag setting (0 = no debug, otherwise debug level)"
    lmsConioDisplay "    -q = quiet (no output) if set to non-zero"
    lmsConioDisplay "    -v = show version"
    lmsConioDisplay " "
    lmsConioDisplay "    -h = help (display this message)"
    lmsConioDisplay "    --help = help (display this message)"
    lmsConioDisplay " "
    lmsConioDisplay "   where nn = numeric value"
    lmsConioDisplay "         ss = string value"
    lmsConioDisplay " "
}

# *******************************************************
#
#	showChangedParameters
#
#		display changed parameters
#
# *******************************************************
showChangedParameters()
{
	for parameter in "${!CLIPARAMETERS[@]}"
	do
		case ${parameter} in

			g)
	        	lmsConioDebug "showChangedParameters" "Groups: ${CLIPARAMETERS[$parameter]} changed to ${MOUNTGROUP}"
            	;;

			m)
	        	lmsConioDebug "showChangedParameters" "Share mount point: ${CLIPARAMETERS[$parameter]} changed to ${MOUNTPOINT}"
	        	;;

			p)
	        	lmsConioDebug "showChangedParameters" "Share mount path: ${CLIPARAMETERS[$parameter]} changed to ${MOUNTPATH}"
            	;;

			u)
	        	lmsConioDebug "showChangedParameters" "Users: ${CLIPARAMETERS[$parameter]} changed to ${USERS}"
            	;;

			# ***********************************************

			nh)
	        	lmsConioDebug "showChangedParameters" "Share host: ${CLIPARAMETERS[$parameter]} changed to ${SHARE}"
	        	;;

			ns)
	        	lmsConioDebug "showChangedParameters" "Share name: ${CLIPARAMETERS[$parameter]} changed to ${SHARENAME}"
	        	;;

			nu)
	        	lmsConioDebug "showChangedParameters" "Share user: ${CLIPARAMETERS[$parameter]} changed to ${SHAREUSER}"
	        	;;

			np)
	        	lmsConioDebug "showChangedParameters" "Share password: ${CLIPARAMETERS[$parameter]} changed to ${SHAREPASS}"
	        	;;

			# ***********************************************

        	d)
	        	lmsConioDebug "showChangedParameters" "Debug: ${CLIPARAMETERS[$parameter]} changed to ${TESTING}"
        		;;

			q)
	        	lmsConioDebug "showChangedParameters" "Quiet: ${CLIPARAMETERS[$parameter]} changed to ${SILENT}"
	        	;;

			# ***********************************************

    		*)
        		echo >&2 "(showChangedParameters) Invalid argument: $1"
        		;;

		esac
	done
}

# *******************************************************
# *******************************************************
#
#    		MAIN BODY OF THE SCRIPT
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#    parse and store cli parameters
#
# *******************************************************

ERRORS=0

while test $# -gt 0
do
	case $1 in

		-g)
			CLIPARAMETERS[g]=${MOUNTGROUP}
            MOUNTGROUP=$2
            shift
            ;;

		-m)
			CLIPARAMETERS[m]=${MOUNTNAME}
			MOUNTNAME=$2
			shift
        	;;

		-p)
			CLIPARAMETERS[p]=${MOUNTPATH}
			MOUNTPATH=$2
			shift
        	;;

		-u)
			CLIPARAMETERS[u]=${USERS}
            USERS=$2
            shift
            ;;

		# ***********************************************

		-nh)
			CLIPARAMETERS[nh]=${SHARE}
			SHARE=$2
			shift
        	;;

		-ns)
			CLIPARAMETERS[ns]=${SHAREMOUNT}
			SHAREMOUNT=$2
			shift
        	;;

		-nu)
			CLIPARAMETERS[nu]=${SHAREUSER}
			SHARENAME=$2
			shift
        	;;

		-np)
			CLIPARAMETERS[np]=${SHAREPASS}
			SHAREPASS=$2
			shift
        	;;

		# ***********************************************

        -d)
			CLIPARAMETERS[d]=${TESTING}
            TESTING=$2
	    	if [ -e $TESTING ]
	    	then
	        	TESTING=1
 	    	fi

        	if [ ! -z "${TESTING##*[!0-9]*}" ]
        	then
	    		shift
	    	else
	    		TESTING=1
	    	fi
        	;;

		-q)
			CLIPARAMETERS[q]=${SILENT}
      		SILENT=$2
      		if [ -e $SILENT ]
	    	then
	        	SILENT=1
 	    	fi

        	if [ ! -z "${SILENT##*[!0-9]*}" ]
        	then
	    		shift
	    	else
	    		SILENT=1
	    	fi
	    	;;

		# ***********************************************

		-v)
	    	displayVersion
	    	exit 0
        	;;

		--help)
	    	displayHelp
	    	exit 0
        	;;

		-h)
	    	displayHelp
	    	exit 0
        	;;

    	*)
    		ERRORS=${ERRORS}+1
           	lmsConioDisplay "Invalid argument: $1"
        	;;

   	esac
   	shift

done

# *******************************************************

if [ ${ERRORS} -ne 0 ]
then
	exit 1
fi

if [ ${#CLIPARAMETERS[@]} -ne 0 ]
then
	showChangedParameters
fi

if [ $SILENT -ne 0 ]
then
	lmsScriptDisplayName
fi

checkRequiredFields

lmsConioDebug "main" "***********************************************"

# *******************************************************
# *******************************************************
#
#    main script logic begins here
#
# *******************************************************
# *******************************************************

createGroups
addUserToGroups

createShareAddress
createShareCredentials

# *******************************************************
#
#    if arrived here, the script completed successfully
#
# *******************************************************
lmsConioDisplay "Successfully completed."

exit 0
