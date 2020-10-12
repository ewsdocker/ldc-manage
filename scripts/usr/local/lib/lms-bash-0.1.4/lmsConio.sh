# *****************************************************************************
# *****************************************************************************
#
#   lmsConio.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage lmsConio
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
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
# *****************************************************************************
#
#			Version 0.0.1 - 02-23-2016.
#					0.0.2 - 09-06-2016.
#					0.1.0 - 01-29-2017.
#					0.1.1 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r lmslib_lmsConio="0.1.1"	# version of lmsscr_Name library

# *********************************************************************************
#
#    lmsConioDisplay
#
#       print message, if allowed
#
#	parameters:
#		message = a string to be printed
#		noEnter = if present, no end-of-line will be output
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# *********************************************************************************
function lmsConioDisplay()
{
	local message="${1}"
	local noEnter="${2}"

	while [[ true ]]
	do
		[[ ${lmscli_optSilent} -ne 0 && ${lmscli_optOverride} -eq 0 ]] && break

		if [[ $# -ne 2 ]] 
    	then
   			echo "${message}"
        	break
    	else
  			[[ "${noEnter}" == "e" ]] && echo -ne "${message}" || echo -n "${message}"
        	break
	    fi
	done

	[[ ${lmscli_optOverride} -ne 0  &&  ${lmscli_optNoReset} -eq 0 ]] && lmscli_optOverride=0
	return 0
}

# **************************************************************************
#
#    lmsConioDebug
#
#      print debug message, if allowed
#
#	parameters:
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function lmsConioDebug()
{
	local errLine=${1:-0}
	local errCode=${2:-0}
	local errMod=${3:-""}

	local funcOffset=1
	local funcName=${FUNCNAME[1]}

	[[ "${funcName}" == "lmsConioDebugExit" || "${funcName}" == "lmsLogDebugMessage" || "${funcName}" == "lmsConioDebugL" ]] && funcOffset=2

	local lmsscr_Name=$(basename "${BASH_SOURCE[$funcOffset]}" .sh)
	
	[[ ${lmscli_optDebug} -ne 0 ]] &&
	 {
		echo -n "${lmsclr_Bold}${lmsclr_Blue}""${lmsscr_Name} "
		echo    "${lmsclr_DarkGrey}""(${FUNCNAME[funcOffset]} @ ${errLine})"

		echo -n "    ${lmsclr_Red}""${errCode} = ${errMod}"

		echo "${lmsclr_NoColor}"
	 }

	[[ ${lmscli_optQueueErrors} -eq 1  &&  ${lmserr_QInitialized} -eq 1 ]] &&
	 {
		lmsErrorQWrite $lmserr_QName ${errLine} "${errCode}"  "${errMod}"
		[[ $? -eq 0 ]] ||
		 {
			echo "Unable to write to error queue: ${errLine} ${errCode} '${errMod}'"
			return 1
		 }
	 }

	return 0
}

# **************************************************************************
#
#    lmsConioDebugL
#
#      add calling line number and print debug message, if allowed
#
#	parameters:
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function lmsConioDebugL()
{
	lmsConioDebug ${BASH_LINENO[0]} ${1} "${2}"
	return $?
}

# **************************************************************************
#
#    lmsConioDebugExit
#
#      print debug message, if allowed, then exit the application script
#
#	parameters:
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#		lmsDmpVar = non-zero to print ALL bash variables and their values
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function lmsConioDebugExit()
{
	local errLine=${1:-0}
	local errCode=${2:-0}
	local errMod=${3:-""}
	local errDump=${4:-0}
	
	[[ ${errDump} -eq 0 ]] || lmsDmpVar

	lmsConioDebug ${errLine} "${errCode}" "${errMod}"
	lmsErrorExitScript "Exit"
}

# **************************************************************************
#
#    lmsConioDisplayTrimmed
#
#		lmsStrTrim leading and trailing blanks and display
#
#	parameters:
#		string = the string to lmsStrTrim
#		name = the display name of the string
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function lmsConioDisplayTrimmed()
{
	lmsStrTrim "${1}" lmsstr_Trimmed

	[[ ! -z "${lmsstr_Trimmed}" ]] &&  lmsConioDisplay "$2: '${lmsstr_Trimmed}'"

}

# **************************************************************************
#
#    lmsConioPrompt
#
#		Output a prompt for input and return it
#
#	parameters:
#		prompt = the message to print
#		noEcho = do not echo the input as it is typed
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function lmsConioPrompt()
{
	local result=0

	lmscli_optOverride=1
    lmsConioDisplay "$1: " "-n"

    if [[ -z "${2}" ]]
    then
    	read
    	result=$?
    else
    	read -s
		result=$?

		lmscli_optOverride=1
    	lmsConioDisplay " "
    fi

    return $result
}

# **************************************************************************
#
#    lmsConioPromptReply
#
#		Output a prompt for input and return in specified global variable
#
#	parameters:
#		prompt = the message to print
#		reply = the input from the console
#		noEcho = do not echo the input as it is typed
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function lmsConioPromptReply()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsConioPrompt "${1}" ${3}
	[[ $? -eq 0 ]] || return 2

	lmsDeclareStr ${2} "${REPLY}"
	[[ $? -eq 0 ]] || return 3

    return 0
}

