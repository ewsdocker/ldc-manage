#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   lmsInstallDirs.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsInstall
#
# ***************************************************************************************************
#
#	Copyright © 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# ***************************************************************************************************
#
#			Version 0.0.1 - 03-02-2017.
#
# ***************************************************************************************************
# ***************************************************************************************************

declare    lmsapp_name="lmsInstallDirs"
declare    lmscli_optRelease="0.1.1"

declare    lmsscr_Version="0.0.1"					# script version

# **********************************************************************

lmscli_optRoot="/usr/local"

lmscli_optBash="${lmscli_optRoot}/share/LMS/Bash/${lmscli_optRelease}"
lmscli_optEtc="${lmscli_optRoot}/etc/LMS/Bash/${lmscli_optRelease}"
lmscli_optLib="${lmscli_optRoot}/lib/LMS/Bash/${lmscli_optRelease}"

# **********************************************************************

lmscli_optVar="/var/local"

lmsbase_dirAppLog="${lmscli_optVar}/log/LMS/Bash/${lmscli_optRelease}"
dirAppBkup="${lmscli_optVar}/backup/LMS/Bash/${lmscli_optRelease}"
dirAppTmp="${lmscli_optVar}/temp/LMS"

# **********************************************************************
# **********************************************************************
#
#		Functions
#
# **********************************************************************
# **********************************************************************

# **********************************************************************
#
#	isInstalled
#
#		Return 0 if the directory /var/local/log/LMS/Bash exists
#			   1 if not
#
#	parameters:
#		none
#
#	returns:
#		0 = directory exists
#		non-zero = error code
#
# **********************************************************************
function isInstalled()
{
	[[ -d "/var/local/log/LMS/Bash" ]] && return 0
	
	return 1
}

# **********************************************************************
#
#	displayHelp
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# **********************************************************************
displayHelp()
{
	[[ -z "${lmsapp_helpBuffer}" ]] &&
	 {
		lmsHelpToStrV lmsapp_helpBuffer
		[[ $? -eq 0 ]] || return 1
	 }

	lmsConioDisplay "${lmsapp_helpBuffer}"
}

# **********************************************************************
#
#	processOptions
#
#		Process command line parameters
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# **********************************************************************
function processCliOptions()
{
	
	return 0
}

# *****************************************************************************
#
#	tarName
#
#		create a tar-file name for the specified group
#
#	parameters:
#		group = name of the group to create name for
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function tarName()
{
	lmsapp_tarName="${dirAppBkup}/${1}-$(date '+%F').tar.gz"
}

# **********************************************************************
#
#	makeDir
#
#		Create the requested directory
#
#	parameters:
#		dir = absolute path to the directory to create
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# **********************************************************************
function makeDir()
{
	local makDir="${1}"

	`sudo mkdir -p "${makDir}"`
	[[ $? -eq 0 ]] || return 1

	return 0
}

# **********************************************************************
#
#	installDirs
#
#		Create the directories requird for the installation of LMS/Bash libraries
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# **********************************************************************
function installDirs()
{
	isInstalled
	[[ $? -eq 0 ]] && return 0

	# ******************************************************************

	makeDir "${lmsbase_dirAppLog}"
	[[ $? -eq 0 ]] || return 1

	makeDir "${dirAppBkup}"
	[[ $? -eq 0 ]] || return 2

	makeDir "${dirAppTemp}"
	[[ $? -eq 0 ]] || return 3

	# ******************************************************************

	makeDir "${lmscli_optBash}"
	[[ $? -eq 0 ]] || return 4

	makeDir "${lmscli_optEtc}"
	[[ $? -eq 0 ]] || return 5

	makeDir "${lmscli_optLib}"
	[[ $? -eq 0 ]] || return 6

	# ******************************************************************

	return 0
}

# **********************************************************************
# **********************************************************************
#
#	Main program STARTS here
#
# **********************************************************************
# **********************************************************************
lmsScriptFileName "${0}"

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# **********************************************************************
# **********************************************************************
#
#		Run the tests starting here
#
# **********************************************************************
# **********************************************************************
lmscli_optDebug=1
[[ -z "${lmscli_command}" ]] &&
{
	displayHelp
	lmsErrorExitScript "None"
}

case "${lmscli_command}" in

	"install")
		installDirs
		[[ $? -eq 0 ]] ||
		 {
			lmsapp_result=$?
			lmsConioDebugL "InstallError" "Installation failed: ${lmsapp_result}."
		 }
		;;

	"help")
		displayHelp
		;;

	*)	
		lmsConioDisplay "Unknown option: '${lmscli_command}'."
		;;
esac

#lmsDmpVar "lmsapp_ lmscli_"

# **********************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# **********************************************************************

