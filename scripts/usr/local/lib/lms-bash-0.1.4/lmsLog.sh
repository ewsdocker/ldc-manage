# **************************************************************************
# **************************************************************************
#
#   lmsLog.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.0
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsLog
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

declare    lmslib_lmsLog="0.1.0"	# version of the library

# **************************************************************************

declare -r lmslog_defaultSeparator="|"
declare	   lmslog_file=""
declare	   lmslog_isOpen=0
declare    lmslog_openType=""
declare    lmslog_separator="${lmslog_defaultSeparator}"

# *****************************************************************************
#
#	lmsLogOpen
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
function lmsLogOpen()
{
	local logName="${1}"
	local openType=${2:-"new"}
	local separator=${3:-"${lmslog_defaultSeparator}"}

	[[ -z "${logName}" ]] && return 1

	lmslog_file="${logName}"
	
	lmslog_basename=$( basename ${lmslog_file} )
	lmslog_dirname=$( dirname ${lmslog_file} )
	mkdir -p ${lmslog_dirname}

	lmslog_openType=${openType}
	lmslog_separator=${separator}
	lmslog_isOpen=0

	if [[ ${lmslog_openType} == "new" && -f "${lmslog_file}" ]]
	then
		eval "rm -f ${lmslog_file}"
		[[ $? -eq 0 ]] || return 2
	fi

	touch "${lmslog_file}"
	[[ $? -eq 0 ]] || return 2

	lmslog_isOpen=1
	return 0
}

# *****************************************************************************
#
#	lmsLogMessage
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
function lmsLogMessage()
{
	local logLine=${1:-0}
	local logCode=${2:-"Debug"}
	local logMod="${3}"
	
	[[ ${lmslog_isOpen} -eq 0 ]] && return 1

	local logDate=$(date +%Y%m%d)
	local logTime=$(date +%H:%M:%S.%N)

	local funcOffset=1
	local funcName=${FUNCNAME[1]}

	[[ "${funcName}" == "lmsLogDebugMessage" ]] && funcOffset=2
	local scriptName=$(basename "${BASH_SOURCE[$funcOffset]}" .sh)

	local message="${lmslog_separator}${logDate}"
	message="${message}${lmslog_separator}${logTime}"
	message="${message}${lmslog_separator}${lmsscr_Name}"
	message="${message}${lmslog_separator}${scriptName}"
	message="${message}${lmslog_separator}${FUNCNAME[1]}"
	message="${message}${lmslog_separator}${logLine}"
	message="${message}${lmslog_separator}${logCode}"
	message="${message}${lmslog_separator}${logMod}"

	echo "${message}" >> "${lmslog_file}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *****************************************************************************
#
#	lmsLogDebugMessage
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
function lmsLogDebugMessage()
{
	local logLine=${1:-0}
	local logCode=${2:-"Debug"}
	local logMod="${3}"

	lmsLogMessage $logLine $logCode "${logMod}"
	return 0
}

# *****************************************************************************
#
#	lmsLogDisplay
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
function lmsLogDisplay()
{
	local lMessage="${1}"
	local lCode="Display"

	lMessage="(${FUNCNAME[1]} @ ${BASH_LINENO[0]}): ${lMessage}"

	[[ $lmscli_optLogDisplay -eq 0 ]]  ||  lmsConioDisplay "${lMessage}"

	[[ -n "${lMessage}" ]] &&
	 {
		lmsLogMessage $LINENO ${lCode} "${lMessage}"
		[[ $? -eq 0 ]] || return 1
	 }

	return 0
}

# *****************************************************************************
#
#	lmsLogOpenType
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
function lmsLogOpenType()
{
	if [[ ${lmslog_isOpen} -eq 0 || "new append old" =~ ${lmslog_openType} ]] 
	then
		echo ""
		return 1
	fi

	echo "${lmslog_openType}"
	return 0
}

# *****************************************************************************
#
#	lmsLogIsOpen
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
function lmsLogIsOpen()
{
	[[ $lmslog_isOpen -eq 0 ]] && echo "0" || echo "1"

	return 0
}

# *****************************************************************************
#
#	lmsLogClose
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
function lmsLogClose()
{
	[[ ${lmslog_isOpen} -ne 0 && "$(lmsLogOpenType)" != "old" ]] &&
	 {
		lmsLogDebugMessage $LINENO "Debug" "'${lmslog_file}'"
	 }

	lmslog_isOpen=0
	return 0
}

