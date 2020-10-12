# *****************************************************************************
# *****************************************************************************
#
#	lmsErrorQ.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage errorQueueFunctions
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
#			Version 0.0.1 - 03-14-2016.
#					0.0.2 - 03-24-2016.
#					0.0.3 - 06-27-2016.
#					0.1.0 - 01-10-2017.
#					0.1.1 - 01-25-2017.
#					0.1.2 - 02-09-2017.
#					0.1.3 - 09-06-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r lmslib_errorQueueFunctions="0.1.3"	# version of lmsscr_Name library

# *****************************************************************************

declare    lmserr_QName="errorQueueStack"

declare    lmserr_QBuffer=""
declare    lmserr_QTimestamp=""
declare    lmserr_QDateTime=""

declare    lmserr_QScript=""
declare    lmserr_QFunction=""
declare -i lmserr_QLine=0

declare    lmserr_QError=0

declare    lmserr_QErrorDesc=""

# *****************************************************************************
#
#	lmsErrorQInit
#
#		Initialize the errorQueue system
#
#	Parameters:
#		errorQueueName = internal name of the queue
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function lmsErrorQInit()
{
	lmserr_QName=${1:-"$lmserr_QName"}
	lmserr_QInitialized=0

	lmsStackExists ${lmserr_QName}
	[[ $? -eq 0 ]] ||
	 {
		local errQVarUid=""
		lmsStackCreate ${lmserr_QName} errQVarUid
		[[ $? -eq 0 ]] || return 1
	 }

	lmserr_QInitialized=1
	return 0
}

# *****************************************************************************
#
#	lmsErrorQWrite
#
#		Add error information to the Error Queue
#
#	Parameters:
#		qName = queue name
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
lmsErrorQWrite()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local qName=${1}
	local errLine=${2}
	local errCode=${3}
	local errMod=${4:-""}

	local digits=""

	local lmsscr_Name=$(basename "${BASH_SOURCE[1]}" .sh)
	local funcName=${FUNCNAME[1]}

	[[ "${funcName}" == "lmsConioDebug" ]] && funcName=${FUNCNAME[2]}

	printf -v digits "10#%05u" $errLine
	printf -v lmstst_buffer "%s:%s:%s:10#%05u:%s:%s" $(date +%s) "$lmsscr_Name" ${funcName} $errLine "$errCode" "$errMod"

	lmsErrorQExists $qName
	[[ $? -eq 0 ]] || return 1

	lmsStackWrite ${qName} "${lmstst_buffer}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *****************************************************************************
#
#	lmsErrorQWriteX
#
#		Conditionally add error information to the Error Queue
#
#	Parameters:
#		qName = queue name
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	Returns
#		0 = no error
#		non-zero = lmsErrorQWrite result
#
# *****************************************************************************
lmsErrorQWriteX()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" || $lmscli_optDebug -eq 0 ]] && return 0

	lmsErrorQWrite ${1} ${2} ${3} ${4:-""}
	return $?
}

# *****************************************************************************
#
#	lmsErrorQRead
#
#		remove the tail item from the Error Queue and return it
#
#	Parameters:
#		qName = queue name
#		qData = queue read return buffer
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
lmsErrorQRead()
{
	[[ -z "${1}" || -z "${2}" ]] && return 0
	local qName=${1}

	lmsStackRead ${qName} lmstst_buffer
	[[ $? -eq 0 ]] || return $?

	lmsErrorQParse "${qName}" "${lmstst_buffer}" ${2}
	[[ $? -eq 0 ]] || return $?

	return 0
}

# *****************************************************************************
#
#	lmsErrorQPeek
#
#		Read the indicated item from the Error Queue and return it
#
#	Parameters:
#		qName = name of the error queue
#		qData = queue read return buffer
#		qOffset = (optional) queue read index (default = 0)
#
#	Returns:
#		0 = no error, data returned in buffer and errQVar variables
#		1 = parameter error
#		2 = queue is empty
#		3 = queue parse error
#
# *****************************************************************************
lmsErrorQPeek()
{
	[[ -z "${1}" || -z "${2}" ]] && 
	{
		lmserr_result=1
		return 1
	}

	local qName=${1}
	local qOffset=${3:-0}
	local message

	lmserr_result=0

	lmsStackPeekQueue ${qName} message ${qOffset}
	[[ $? -eq 0 ]] || 
	{
		lmserr_result=$?
		return 2
	}

	lmsErrorQParse ${qName} "${message}" lmstst_buffer
	[[ $? -eq 0 ]] || 
	 {
		lmserr_result=$?
		return 3
	 }

	lmsDeclareStr ${2} "${lmstst_buffer}"

	return 0
}

# *****************************************************************************
#
#	lmsErrorQParse
#
#		remove the tail item from the Error Queue and return it
#
#	Parameters:
#		qName = name of the error queue
#		qData = queue buffer to be parsed
#		qMessage = location to place the parsed buffer in printable format
#		qSep = (optional) field separator, default = ":"
#
#	Returns:
#		0 = no error, data returned in buffer and errQVar variables
#		1 = no error queue exists
#		2 = queue is empty
#
# *****************************************************************************
lmsErrorQParse()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local qName=${1}
	local qData=${2}
#	local qBuffer="${3}"
	local qSeparator=${4:-":"}

	local -a qArray=()

	lmserr_QBuffer="${qData}"

	lmsStrExplode "${qData}" "$qSeparator" qArray

	lmserr_QTimestamp=${qArray[0]}
	lmserr_QDateTime=$(date -d @${lmserr_QTimestamp} "+%T %m-%d-%Y")

	[[ ${#qArray[@]} -gt 0 ]] || return 2

	lmserr_QScript=${qArray[1]}
	lmserr_QFunction=${qArray[2]}
	lmserr_QLine=${qArray[3]}

	lmserr_QError=${qArray[4]}
	lmserr_QErrorMod=${qArray[5]}

	lmsErrorLookupName "${lmserr_QError}"
	[[ $? -eq 0 ]] || return 3

	lmserr_QErrorDesc="$lmserr_message"
	lmsDeclareStr ${3} "${lmserr_QErrorDesc}"

	return 0
}

# *****************************************************************************
#
#	lmsErrorQErrors
#
#		Returns the number of errors in the error queue
#
#	Parameters:
#		qName = name of the error queue
#		errorCount = location to store the number of errors
#
#	Returns 0 = no error
#			non-zero = error code
#
# *****************************************************************************
lmsErrorQErrors()
{
	[[ -z "${1}" || -z "${2}" ]] && 
	{
		return 1
	}

	lmsStackSize "${qName}" ${2}
	[[ $? -eq 0 ]] || 
	{
		return 2
	}

	return 0
}

# *****************************************************************************
#
# BAD
#
#	lmsErrorQGetError
#
#		Get the calling function and message as a printable string
#
#	Parameters:
#		qName = name of the error queue
#		message = location to store the printable message
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function lmsErrorQGetError()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsErrorQErrors ${1} lmstst_stackSize
	[[ $? -eq 0 ]] || return 2

	if [[ ${lmstst_stackSize} -eq 0 ]]
	then
		lmsDeclareStr "No errors recorded." ${2}
	else
		lmsDeclareStr "($errQueueErrorFunction) $errQueueErrorMessage" ${2}
	fi
	
	return $?
}

# *****************************************************************************
#
#	lmsErrorQResetV
#
#		Clear error queue global variables
#
#	Parameters:
#		qName = the name of the error queue
#
#	Returns:
#		0 = no error
#
# *****************************************************************************
function lmsErrorQResetV()
{
	[[ -z "${1}" ]] && return 1

	lmserr_QBuffer=""
	lmserr_QTimestamp=""
	lmserr_QDateTime=""

	lmserr_QFunction=""
	lmserr_QLine=0

	lmserr_QError=Unknown
	lmserr_QErrorMod=""
	lmserr_QErrorDesc=""
	
	return 0
}

# *****************************************************************************
#
#	lmsErrorQExists
#
#		Check that error queue exists
#
#	Parameters:
#		qName = the name of the error queue
#
#	Returns:
#		0 = exists
#		non-zero = doesn't exist
#
# *****************************************************************************
function lmsErrorQExists()
{
	[[ -z "${1}" ]] && return 1

	local qName=${1}
	local errQUid

	lmsStackExists ${qName} errQUid
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *****************************************************************************
#
#	lmsErrorQReset
#
#		Reset the error stacks
#
#	Parameters:
#		qName = the name of the error queue
#
#	Returns:
#		0 = no error
#
# *****************************************************************************
lmsErrorQReset()
{
	[[ -z "${1}" ]] && return 1

	local qName=${1}
	local -i errCount

	lmsErrorQResetV $qName

	lmsErrorQExists $qName
	[[ $? -eq 0 ]] || return 1

	eval "let stackHead_${lms_stackUid}=0"
	eval "let stackTail_${lms_stackUid}=0"

	lmsErrorQErrors $qName errCount
	[[ $? -eq 0 ]] || return 2
	
	[[ ${errCount} -eq 0 ]] || return 3

	return 0
}

