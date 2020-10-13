#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   ldcInstallDirs.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage ldcInstall
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

declare    ldcapp_name="ldcInstallDirs"
declare    ldccli_optRelease="0.1.1"

declare    ldcscr_Version="0.0.1"					# script version

# **********************************************************************

ldccli_optRoot="/usr/local"

ldccli_optBash="${ldccli_optRoot}/share/ldc/Bash/${ldccli_optRelease}"
ldccli_optEtc="${ldccli_optRoot}/etc/ldc/Bash/${ldccli_optRelease}"
ldccli_optLib="${ldccli_optRoot}/lib/ldc/Bash/${ldccli_optRelease}"

# **********************************************************************

ldccli_optVar="/var/local"

ldcbase_dirAppLog="${ldccli_optVar}/log/ldc/Bash/${ldccli_optRelease}"
dirAppBkup="${ldccli_optVar}/backup/ldc/Bash/${ldccli_optRelease}"
dirAppTmp="${ldccli_optVar}/temp/ldc"

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
#		Return 0 if the directory /var/local/log/ldc/Bash exists
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
	[[ -d "/var/local/log/ldc/Bash" ]] && return 0
	
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
	[[ -z "${ldcapp_helpBuffer}" ]] &&
	 {
		ldcHelpToStrV ldcapp_helpBuffer
		[[ $? -eq 0 ]] || return 1
	 }

	ldcConioDisplay "${ldcapp_helpBuffer}"
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
	ldcapp_tarName="${dirAppBkup}/${1}-$(date '+%F').tar.gz"
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
#		Create the directories requird for the installation of ldc/Bash libraries
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

	makeDir "${ldcbase_dirAppLog}"
	[[ $? -eq 0 ]] || return 1

	makeDir "${dirAppBkup}"
	[[ $? -eq 0 ]] || return 2

	makeDir "${dirAppTemp}"
	[[ $? -eq 0 ]] || return 3

	# ******************************************************************

	makeDir "${ldccli_optBash}"
	[[ $? -eq 0 ]] || return 4

	makeDir "${ldccli_optEtc}"
	[[ $? -eq 0 ]] || return 5

	makeDir "${ldccli_optLib}"
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
ldcScriptFileName "${0}"

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# **********************************************************************
# **********************************************************************
#
#		Run the tests starting here
#
# **********************************************************************
# **********************************************************************
ldccli_optDebug=1
[[ -z "${ldccli_command}" ]] &&
{
	displayHelp
	ldcErrorExitScript "None"
}

case "${ldccli_command}" in

	"install")
		installDirs
		[[ $? -eq 0 ]] ||
		 {
			ldcapp_result=$?
			ldcConioDebugL "InstallError" "Installation failed: ${ldcapp_result}."
		 }
		;;

	"help")
		displayHelp
		;;

	*)	
		ldcConioDisplay "Unknown option: '${ldccli_command}'."
		;;
esac

#ldcDmpVar "ldcapp_ ldccli_"

# **********************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# **********************************************************************

