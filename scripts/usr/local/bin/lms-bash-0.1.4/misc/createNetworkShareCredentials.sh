#!/bin/bash

# *******************************************************
# *******************************************************
#
#   createNetworkShareCredentials
#
#   By Jay Wheeler, EarthWalk Software. 02-19-2016.
#	Copyright (C) 2016. EarthWalk Software
#
# *******************************************************
# *******************************************************

mountGroup="netshare"		# (g) the default network share group

shareUser="netshare"		# (nu) the default network share user (owner)
sharePass=""				# (np) the network share password (owner)

credentialName=".credentials"		# Name of the credentials file
credentialPath="/var/local"		# Path to the credentials file
credentialFile=""					# Credentials file (path + name)

# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************

declare -a groupList		# an array of groups to add users to
declare -A groupIds			# an associative array of group name => id
declare -A lmscli_shellParam	# an associative array of parameters modified by cli

declare -i lmscli_Errors		# an integer count of cli parameter errors

applicationVersion="1.0"

runUser="${user}"			# the name of the user running this script

# *******************************************************
# *******************************************************
#
#	External Functions
#
# *******************************************************
# *******************************************************

. ShellSnippets/lmsCli.sh
. ShellSnippets/applicationName.sh
. ShellSnippets/lmsError.sh
. ShellSnippets/lmsConio.sh
. ShellSnippets/setupFedoraErrorCodes.sh
. ShellSnippets/networkCredentialsHelp.sh

# *******************************************************
# *******************************************************
#
#	Functions
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#	checkGroup
#
#		check the validity of the provided group
#
#	parameters:
#		name = group to check
#		create = 1 to allow creating non-existent group
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
	groupIds[$name]="$(getent group $name | cut -d: -f3)"
	if [ $? -ne 0 ]
	then

		lmsConioDebug "checkGroup" "non-existent group: $name"
createAdminAccounts
		if [ $create -ne 0 ]
		then
			lmsConioDebug "checkGroup" "Creating non-existent group: $name"

			groupadd $name 1>/dev/null 2>&1
			checkGroup $1 0
			return 0
		fi

		lmsConioDisplay "Unable to create non-existent group: $name"
		lmsConioDebug "checkGroup" "non-existent group: $name"
		exit NonExistentGroup
	fi

	lmsConioDebug "checkGroups" "gid '${groupIds[${name}]}'"
}

# *******************************************************
#
#	createGroups
#
#		create all provided group names
#
# *******************************************************
createGroups()
{
	lmsConioDebug "createGroups" "parsing mountGroup"

	groupList=$(echo ${mountGroup} | tr "," "\n")
	lmsConioDebug "createGroups" "groups list: " $groupList

	for name in ${groupList}
	do
		checkGroup $name 1
		lmsConioDebug "createGroups" "group $name = ${groupIds[$name]}"
	done
}


# *******************************************************
#
#	createShareCredentials
#
# *******************************************************
createShareCredentials()
{
	credentialFile=$credentialPath/$mountGroup
	lmsConioDebug "createShareCredentials" "Credentials Folder = ${credentialFile}"

	stat $credentialFile 1>/dev/null 2>&1
	if [ $? -ne 0 ]
	then
		lmsConioDebug "createShareCredentials" "Creating Credentials Folder = $credentialFile"

		mkdir -p $credentialFile
		if [ $? -ne 0 ]
		then
			exitScript Error_CreateFolder
		fi

		credentialFile=$credentialFile/$credentialName

		lmsConioDebug "createShareCredentials" "Credentials File = $credentialFile"

		touch $credentialFile
		if [ $? -ne 0 ]
		then
			exitScript Error_TouchFailed
		fi

cat << EOF > $credentialFile
USERNAME=$shareUser
PASSWORD=$sharePass
EOF

		if [ $? -ne 0 ]
		then
			exitScript Error_WriteError
		fi

		lmsConioDebug "createShareCredentials" "changing file owner"

		chown root:wheel $credentialFile 1>/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			exitScript Error_ChownFailed
		fi

		lmsConioDebug "createShareCredentials" "changing file mode"

		chmod 661 $credentialFile 1>/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			exitScript Error_ChmodFailed
		fi
	fi

	lmsConioDebug "createShareCredentials" "Created file $credentialFile"
}

# *******************************************************
#
#	getSharePwd
#
#		request a login password for the network share
#
# *******************************************************
getSharePwd()
{
	lmsConioDebug "getSharePwd" "Requesting sharePass"

	lmsConioPrompt "Enter a login password for ${shareUser} on ${share}" -n
	if [ $? -ne 0 ]
	then
		exitScript Error_NoPass "Missing sharePass"
	fi

	sharePass=$REPLY
}

# *******************************************************
#
#	checkSharePwd
#
#		check that sharePass is provided, otherwise request it
#
# *******************************************************
checkSharePwd()
{
	lmsConioDebug "checkSharePwd" "checking sharePass"

	if [ -z "${sharePass}" ]
	then
		if [ "${lmscli_optBatch}" -eq "0" ]
		then
			exitScript "Error_SharePass"
		fi

		getSharePwd
	fi

	lmsConioDebug "checkSharePwd" "sharePass = '${sharePass}'"
}

# *******************************************************
#
#	checkShareUser
#
#		check that shareUser is provided
#
# *******************************************************
checkShareUser()
{
	lmsConioDebug "checkShareUser" "checking shareUser"

	if [ -z "${shareUser}" ]
	then
		lmsConioDebug "checkShareUser" "shareUser is missing."
		exitScript Error_ShareUser
	fi

	lmsConioDebug "checkShareUser" "shareUser = '${shareUser}'"
}

# *******************************************************
#
#	lmsUtilIsRoot
#
#		check for root and not user or sudoer execution
#
# *******************************************************
lmsUtilIsRoot()
{
	lmsConioDebug "lmsUtilIsUser" "Checking if running by root"

	activeUser=$( whoami )

	if [ "${activeUser}" != "root" ]
	then
		lmsConioDisplay ""
		lmsConioDisplay "	UsecreateAdminAccountsr = ${activeUser}"
		lmsConioDisplay ""
		lmsConioDisplay "		${baseName} can only be run by root."
		lmsConioDisplay ""

		exitScript Error_NotRoot
	fi

	lmsConioDebug "lmsUtilIsRoot" "User: ${activeUser}"
}

# *******************************************************
#
#	checkReuiredFields
#
# *******************************************************
checkRequiredFields()
{
	lmsUtilIsRoot

	checkShareUser
	checkSharePwd
}

# *******************************************************
# *******************************************************
#
#			MAIN BODY OF THE SCRIPT
#
# *******************************************************
# *******************************************************

initializeErrorCodes
applicationVersion="1.0"
lmscli_optDebug=1

# *******************************************************

displayApplicationName
displayHelp

# *******************************************************
#
#	if arrived here, the script completed successfully
#
# *******************************************************
lmsConioDisplay "Successfully completed."

exitScript Error_None
