#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   lmsInstall.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage lmsInstall
#
# ***************************************************************************************************
#
#	Copyright © 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/lms-bash.
#
#   ewsdocker/lms-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/lms-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/lms-bash.  If not, see 
#   <http://www.gnu.org/licenses/>.
#
# ***************************************************************************************************
#
#			Version 0.0.1 - 02-25-2017.
#					0.0.2 - 08-28-2018.
#
# ***************************************************************************************************
# ***************************************************************************************************

declare    lmsapp_name="lmsInstall"
declare    lmslib_bashRelease="0.1.4"

declare -i lmscli_optProduction=0

# ***************************************************************************************************

source testlib/installDirs.sh

# ***************************************************************************************************

source testlib/stdLibs.sh
source testlib/cliOptions.sh
source testlib/commonVars.sh

# ***************************************************************************************************

lmsscr_Version="0.0.2"					# script version

lmsapp_declare="$lmsbase_dirEtc/lmsInstallDcl.xml"
lmsvar_help="$lmsbase_dirEtc/lmsInstallHelp.xml"

lmsapp_bashInstalled=0

# ***************************************************************************************************
# ***************************************************************************************************
#
#		External Functions
#
# ***************************************************************************************************
# ***************************************************************************************************


# ***************************************************************************************************
# ***************************************************************************************************
#
#		Runtime Functions
#
# ***************************************************************************************************
# ***************************************************************************************************

# ***************************************************************************************************
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
# ***************************************************************************************************
function isInstalled()
{
	[[ -d "/var/local/log/LMS/Bash" ]] && return 0
	
	return 1
}

# ***************************************************************************************************
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
# *****************************************************************************
displayHelp()
{
return 0
	[[ -z "${lmsapp_helpBuffer}" ]] &&
	 {
		lmsHelpToStrV lmsapp_helpBuffer
		[[ $? -eq 0 ]] || return 1
	 }

	lmsConioDisplay "${lmsapp_helpBuffer}"
}

# ***************************************************************************************************
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
# ***************************************************************************************************
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

# *****************************************************************************
#
#	extractTgz
#
#	parameters:
#		source = location of tar.gz file(s)
#		destination = location to extract the source to
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function extractTgz()
{
	local lDst="${1}"
	local lSrc="${2}"

	local lDir="${PWD}"

	cd "${lDst}" >/dev/null 2>&1
	[[ $? -eq 0 ]] || 
	{
		lmsConioDebugL "CDError" "CD to '${lDst}' failed."
		return 1
	}

	echo `tar xf "${lSrc}"` >/dev/null 2>&1
	[[ $? -eq 0 ]] || 
	{
		lmsConioDebugL "TarError" "'tar' of '${lSrc}' failed."
		return 2
	}

	cd "${lDir}" >/dev/null 2>&1

	return 0
}

# *****************************************************************************
#
#	extractSource
#
#		extract backup of all source files from tar.gz
#			to the proper folders
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function extractSource()
{
	[[ ${lmscli_optProduction} -eq 0 ]] &&
	 {
		lmsConioDebugL "ExtractError" "Extract (extract) may only be run in production mode."
		lmsErrorExitScript "ExtractError"
	 }

	tarName "bkp"
	extractTgz "${dirAppTemp}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 2

	tarName "src"
	extractTgz "${lmsbase_dirAppSrc}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 3

	tarName "lib"
	extractTgz "${lmsbase_dirLib}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 4

	tarName "etc"
	extractTgz "${lmsbase_dirEtc}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 5

	tarName "tst"
	extractTgz "${dirBash}/test" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 6

	return 0
}

# *****************************************************************************
#
#	createTgz
#
#	parameters:
#		source = location do backup
#		destination = location to place the tar.gz file
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function createTgz()
{
	local lSrc="${1}"
	local lDst="${2}"

	local lDir="${PWD}"

	cd "${lSrc}" >/dev/null 2>&1
	[[ $? -eq 0 ]] || 
	{
		lmsConioDebugL "CDError" "CD to '${lSrc}' failed."
		return 1
	}

	echo `tar czf "${lDst}" *` >/dev/null 2>&1
	[[ $? -eq 0 ]] || 
	{
		lmsConioDebugL "TarError" "'tar' of '${lDst}' failed."
		return 2
	}

	cd "${lDir}" >/dev/null 2>&1

	return 0
}

# *****************************************************************************
#
#	backupSource
#
#		create backup of all source files a tar.gz in
#			backup directory
#		OVERWRITEs existing files with the same name
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function backupSource()
{
	tarName "src"
	createTgz "${lmsbase_dirAppSrc}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 1

	tarName "lib"
	createTgz "${lmsbase_dirLib}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 2

	tarName "etc"
	createTgz "${lmsbase_dirEtc}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 3

	tarName "tst"
	createTgz "${dirBash}/test" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 4
	
	tarName "bkp"
	createTgz "${dirAppBkup}" "${lmsapp_tarName}"
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***************************************************************************************************
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
# ***************************************************************************************************
function makeDir()
{
	`sudo mkdir -p /var/local/log/LMS/Bash`
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***************************************************************************************************
#
#	installDirs
#
#		Create the directories required for the installation of LMS/Bash system
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# ***************************************************************************************************
function installDirs()
{
	#[[ ${lmscli_optProduction} -eq 0 ]] &&
	# {
	#	lmsConioDebugL "InstallError" "Install may only be run in production mode."
	#	lmsErrorExitScript "InstallError"
	# }

	isInstalled
	[[ $? -eq 0 ]] && return 0
	
	`mkdir -p /var/local/log/LMS/Bash/${lmslib_bashRelease}`
	`mkdir -p /var/local/backup/LMS/Bash/${lmslib_bashRelease}`

	`mkdir -p /usr/local/share/LMS/Bash/${lmslib_bashRelease}`
	`mkdir -p /usr/local/etc/LMS/Bash/${lmslib_bashRelease}`
	`mkdir -p /usr/local/lib/LMS/Bash/${lmslib_bashRelease}`
	
	return 0
}

# *****************************************************************************
# *****************************************************************************
#
#	Main program STARTS here
#
# *****************************************************************************
# *****************************************************************************

lmsScriptFileName "${0}"

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

processCliOptions
[[ $? -eq 0 ]] ||
{
	lmsapp_result=$?
	lmsConioDebugL "CliError" "Unable to process cli options: $?"
	lmsErrorExitScript "CliError"
}

[[ -z "${lmscli_command}" ]] &&
{
#	displayHelp
	lmsErrorExitScript "None"
}

case "${lmscli_command}" in

	"backup")
		backupSource
		[[ $? -eq 0 ]] ||
		 {
			lmsapp_result=$?
			lmsConioDebugL "BackupError" "Backup source failed: ${lmsapp_result}."
		 }
		;;

	"install")
		installDirs
		[[ $? -eq 0 ]] ||
		 {
			lmsapp_result=$?
			lmsConioDebugL "InstallError" "Installation failed: ${lmsapp_result}."
		 }
		;;

	"extract")
		extractSource
		[[ $? -eq 0 ]] ||
		 {
			lmsapp_result=$?
			lmsConioDebugL "ExtractError" "Source extraction failed: ${lmsapp_result}."
		 }
		;;

	"help")
echo "HELP"
#		displayHelp
		;;

	*)	
		lmsConioDisplay "Unknown option: '${lmscli_command}'."
		;;
esac

#lmsDmpVar "lmsapp_ lmscli_"

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************

