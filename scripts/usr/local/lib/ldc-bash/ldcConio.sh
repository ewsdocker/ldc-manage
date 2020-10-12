# *****************************************************************************
# *****************************************************************************
#
#   ldcConio.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcConio
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/ldc-bash.
#
#   ewsdocker/ldc-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/ldc-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/ldc-bash.  If not, see 
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

declare -r ldclib_ldcConio="0.1.1"	# version of ldcscr_Name library

# *********************************************************************************
#
#    ldcConioDisplay
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
function ldcConioDisplay()
{
	local message="${1}"
	local noEnter="${2}"

	while [[ true ]]
	do
		[[ ${ldccli_optSilent} -ne 0 && ${ldccli_optOverride} -eq 0 ]] && break

		if [[ $# -ne 2 ]] 
    	then
   			echo "${message}"
        	break
    	else
  			[[ "${noEnter}" == "e" ]] && echo -ne "${message}" || echo -n "${message}"
        	break
	    fi
	done

	[[ ${ldccli_optOverride} -ne 0  &&  ${ldccli_optNoReset} -eq 0 ]] && ldccli_optOverride=0
	return 0
}

# **************************************************************************
#
#    ldcConioDebug
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
function ldcConioDebug()
{
	local errLine=${1:-0}
	local errCode=${2:-0}
	local errMod=${3:-""}

	local funcOffset=1
	local funcName=${FUNCNAME[1]}

	[[ "${funcName}" == "ldcConioDebugExit" || "${funcName}" == "ldcLogDebugMessage" || "${funcName}" == "ldcConioDebugL" ]] && funcOffset=2

	local ldcscr_Name=$(basename "${BASH_SOURCE[$funcOffset]}" .sh)
	
	[[ ${ldccli_optDebug} -ne 0 ]] &&
	 {
		echo -n "${ldcclr_Bold}${ldcclr_Blue}""${ldcscr_Name} "
		echo    "${ldcclr_DarkGrey}""(${FUNCNAME[funcOffset]} @ ${errLine})"

		echo -n "    ${ldcclr_Red}""${errCode} = ${errMod}"

		echo "${ldcclr_NoColor}"
	 }

	[[ ${ldccli_optQueueErrors} -eq 1  &&  ${ldcerr_QInitialized} -eq 1 ]] &&
	 {
		ldcErrorQWrite $ldcerr_QName ${errLine} "${errCode}"  "${errMod}"
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
#    ldcConioDebugL
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
function ldcConioDebugL()
{
	ldcConioDebug ${BASH_LINENO[0]} ${1} "${2}"
	return $?
}

# **************************************************************************
#
#    ldcConioDebugExit
#
#      print debug message, if allowed, then exit the application script
#
#	parameters:
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#		ldcDmpVar = non-zero to print ALL bash variables and their values
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function ldcConioDebugExit()
{
	local errLine=${1:-0}
	local errCode=${2:-0}
	local errMod=${3:-""}
	local errDump=${4:-0}
	
	[[ ${errDump} -eq 0 ]] || ldcDmpVar

	ldcConioDebug ${errLine} "${errCode}" "${errMod}"
	ldcErrorExitScript "Exit"
}

# **************************************************************************
#
#    ldcConioDisplayTrimmed
#
#		ldcStrTrim leading and trailing blanks and display
#
#	parameters:
#		string = the string to ldcStrTrim
#		name = the display name of the string
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function ldcConioDisplayTrimmed()
{
	ldcStrTrim "${1}" ldcstr_Trimmed

	[[ ! -z "${ldcstr_Trimmed}" ]] &&  ldcConioDisplay "$2: '${ldcstr_Trimmed}'"

}

# **************************************************************************
#
#    ldcConioPrompt
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
function ldcConioPrompt()
{
	local result=0

	ldccli_optOverride=1
    ldcConioDisplay "$1: " "-n"

    if [[ -z "${2}" ]]
    then
    	read
    	result=$?
    else
    	read -s
		result=$?

		ldccli_optOverride=1
    	ldcConioDisplay " "
    fi

    return $result
}

# **************************************************************************
#
#    ldcConioPromptReply
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
function ldcConioPromptReply()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	ldcConioPrompt "${1}" ${3}
	[[ $? -eq 0 ]] || return 2

	ldcDeclareStr ${2} "${REPLY}"
	[[ $? -eq 0 ]] || return 3

    return 0
}

