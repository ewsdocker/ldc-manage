# **************************************************************************
# **************************************************************************
#
#   ldcLog.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.0
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage ldcLog
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#
#		Version 0.0.1 - 08-31-2016.
#               0.0.2 - 09-16-2016.
#				0.1.0 - 01-16-2017.
#
# **************************************************************************
# **************************************************************************

declare    ldclib_ldcLog="0.1.0"	# version of the library

# **************************************************************************

declare -r ldclog_defaultSeparator="|"
declare	   ldclog_file=""
declare	   ldclog_isOpen=0
declare    ldclog_openType=""
declare    ldclog_separator="${ldclog_defaultSeparator}"

# *****************************************************************************
#
#	ldcLogOpen
#
#		Open a log file
#
#	parameters:
#		logName = path to the log file
#		openType = (optional) "new" "append" or "old" (default="new")
#		fieldSeparator = (optional) field separator character, default="-"
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogOpen()
{
	local logName="${1}"
	local openType=${2:-"new"}
	local separator=${3:-"${ldclog_defaultSeparator}"}

	[[ -z "${logName}" ]] && return 1

	ldclog_file="${logName}"
	
	ldclog_basename=$( basename ${ldclog_file} )
	ldclog_dirname=$( dirname ${ldclog_file} )
	mkdir -p ${ldclog_dirname}

	ldclog_openType=${openType}
	ldclog_separator=${separator}
	ldclog_isOpen=0

	if [[ ${ldclog_openType} == "new" && -f "${ldclog_file}" ]]
	then
		eval "rm -f ${ldclog_file}"
		[[ $? -eq 0 ]] || return 2
	fi

	touch "${ldclog_file}"
	[[ $? -eq 0 ]] || return 2

	ldclog_isOpen=1
	return 0
}

# *****************************************************************************
#
#	ldcLogMessage
#
#		Output a message to the program log
#
#	parameters:
#		logLine = line number
#		logCode = log code
#		logMod  = additional information to supplement the error message
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogMessage()
{
	local logLine=${1:-0}
	local logCode=${2:-"Debug"}
	local logMod="${3}"
	
	[[ ${ldclog_isOpen} -eq 0 ]] && return 1

	local logDate=$(date +%Y%m%d)
	local logTime=$(date +%H:%M:%S.%N)

	local funcOffset=1
	local funcName=${FUNCNAME[1]}

	[[ "${funcName}" == "ldcLogDebugMessage" ]] && funcOffset=2
	local scriptName=$(basename "${BASH_SOURCE[$funcOffset]}" .sh)

	local message="${ldclog_separator}${logDate}"
	message="${message}${ldclog_separator}${logTime}"
	message="${message}${ldclog_separator}${ldcscr_Name}"
	message="${message}${ldclog_separator}${scriptName}"
	message="${message}${ldclog_separator}${FUNCNAME[1]}"
	message="${message}${ldclog_separator}${logLine}"
	message="${message}${ldclog_separator}${logCode}"
	message="${message}${ldclog_separator}${logMod}"

	echo "${message}" >> "${ldclog_file}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *****************************************************************************
#
#	ldcLogDebugMessage
#
#		Output a message to the program log
#
#	parameters:
#		logLine = line number
#		logCode = log code
#		logMod  = additional information to supplement the error message
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogDebugMessage()
{
	local logLine=${1:-0}
	local logCode=${2:-"Debug"}
	local logMod="${3}"

	ldcLogMessage $logLine $logCode "${logMod}"
	return 0
}

# *****************************************************************************
#
#	ldcLogDisplay
#
#		Output a message to the program log and the console
#
#	parameters:
#		message = message to log/display
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogDisplay()
{
	local lMessage="${1}"
	local lCode="Display"

	lMessage="(${FUNCNAME[1]} @ ${BASH_LINENO[0]}): ${lMessage}"

	[[ $ldccli_optLogDisplay -eq 0 ]]  ||  ldcConioDisplay "${lMessage}"

	[[ -n "${lMessage}" ]] &&
	 {
		ldcLogMessage $LINENO ${lCode} "${lMessage}"
		[[ $? -eq 0 ]] || return 1
	 }

	return 0
}

# *****************************************************************************
#
#	ldcLogOpenType
#
#		Return the log open type
#
#	parameters:
#		none
#
#	output:
#		openType = "new" "append" "old" ""
#
#	returns:
#		0 = no errors
#		1 = no open type set
#
# *****************************************************************************
function ldcLogOpenType()
{
	if [[ ${ldclog_isOpen} -eq 0 || "new append old" =~ ${ldclog_openType} ]] 
	then
		echo ""
		return 1
	fi

	echo "${ldclog_openType}"
	return 0
}

# *****************************************************************************
#
#	ldcLogIsOpen
#
#		Return 1 if log file is open, 0 if not
#
#	parameters:
#		none
#
#	output:
#		1 = open
#		0 = not open
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogIsOpen()
{
	[[ $ldclog_isOpen -eq 0 ]] && echo "0" || echo "1"

	return 0
}

# *****************************************************************************
#
#	ldcLogClose
#
#		Close a log file
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogClose()
{
	[[ ${ldclog_isOpen} -ne 0 && "$(ldcLogOpenType)" != "old" ]] &&
	 {
		ldcLogDebugMessage $LINENO "Debug" "'${ldclog_file}'"
	 }

	ldclog_isOpen=0
	return 0
}

