# *****************************************************************************
# *****************************************************************************
#
#	ldcErrorQ.sh
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

declare -r ldclib_errorQueueFunctions="0.1.3"	# version of ldcscr_Name library

# *****************************************************************************

declare    ldcerr_QName="errorQueueStack"

declare    ldcerr_QBuffer=""
declare    ldcerr_QTimestamp=""
declare    ldcerr_QDateTime=""

declare    ldcerr_QScript=""
declare    ldcerr_QFunction=""
declare -i ldcerr_QLine=0

declare    ldcerr_QError=0

declare    ldcerr_QErrorDesc=""

# *****************************************************************************
#
#	ldcErrorQInit
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
function ldcErrorQInit()
{
	ldcerr_QName=${1:-"$ldcerr_QName"}
	ldcerr_QInitialized=0

	ldcStackExists ${ldcerr_QName}
	[[ $? -eq 0 ]] ||
	 {
		local errQVarUid=""
		ldcStackCreate ${ldcerr_QName} errQVarUid
		[[ $? -eq 0 ]] || return 1
	 }

	ldcerr_QInitialized=1
	return 0
}

# *****************************************************************************
#
#	ldcErrorQWrite
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
ldcErrorQWrite()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local qName=${1}
	local errLine=${2}
	local errCode=${3}
	local errMod=${4:-""}

	local digits=""

	local ldcscr_Name=$(basename "${BASH_SOURCE[1]}" .sh)
	local funcName=${FUNCNAME[1]}

	[[ "${funcName}" == "ldcConioDebug" ]] && funcName=${FUNCNAME[2]}

	printf -v digits "10#%05u" $errLine
	printf -v ldctst_buffer "%s:%s:%s:10#%05u:%s:%s" $(date +%s) "$ldcscr_Name" ${funcName} $errLine "$errCode" "$errMod"

	ldcErrorQExists $qName
	[[ $? -eq 0 ]] || return 1

	ldcStackWrite ${qName} "${ldctst_buffer}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *****************************************************************************
#
#	ldcErrorQWriteX
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
#		non-zero = ldcErrorQWrite result
#
# *****************************************************************************
ldcErrorQWriteX()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" || $ldccli_optDebug -eq 0 ]] && return 0

	ldcErrorQWrite ${1} ${2} ${3} ${4:-""}
	return $?
}

# *****************************************************************************
#
#	ldcErrorQRead
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
ldcErrorQRead()
{
	[[ -z "${1}" || -z "${2}" ]] && return 0
	local qName=${1}

	ldcStackRead ${qName} ldctst_buffer
	[[ $? -eq 0 ]] || return $?

	ldcErrorQParse "${qName}" "${ldctst_buffer}" ${2}
	[[ $? -eq 0 ]] || return $?

	return 0
}

# *****************************************************************************
#
#	ldcErrorQPeek
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
ldcErrorQPeek()
{
	[[ -z "${1}" || -z "${2}" ]] && 
	{
		ldcerr_result=1
		return 1
	}

	local qName=${1}
	local qOffset=${3:-0}
	local message

	ldcerr_result=0

	ldcStackPeekQueue ${qName} message ${qOffset}
	[[ $? -eq 0 ]] || 
	{
		ldcerr_result=$?
		return 2
	}

	ldcErrorQParse ${qName} "${message}" ldctst_buffer
	[[ $? -eq 0 ]] || 
	 {
		ldcerr_result=$?
		return 3
	 }

	ldcDeclareStr ${2} "${ldctst_buffer}"

	return 0
}

# *****************************************************************************
#
#	ldcErrorQParse
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
ldcErrorQParse()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local qName=${1}
	local qData=${2}
#	local qBuffer="${3}"
	local qSeparator=${4:-":"}

	local -a qArray=()

	ldcerr_QBuffer="${qData}"

	ldcStrExplode "${qData}" "$qSeparator" qArray

	ldcerr_QTimestamp=${qArray[0]}
	ldcerr_QDateTime=$(date -d @${ldcerr_QTimestamp} "+%T %m-%d-%Y")

	[[ ${#qArray[@]} -gt 0 ]] || return 2

	ldcerr_QScript=${qArray[1]}
	ldcerr_QFunction=${qArray[2]}
	ldcerr_QLine=${qArray[3]}

	ldcerr_QError=${qArray[4]}
	ldcerr_QErrorMod=${qArray[5]}

	ldcErrorLookupName "${ldcerr_QError}"
	[[ $? -eq 0 ]] || return 3

	ldcerr_QErrorDesc="$ldcerr_message"
	ldcDeclareStr ${3} "${ldcerr_QErrorDesc}"

	return 0
}

# *****************************************************************************
#
#	ldcErrorQErrors
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
ldcErrorQErrors()
{
	[[ -z "${1}" || -z "${2}" ]] && 
	{
		return 1
	}

	ldcStackSize "${qName}" ${2}
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
#	ldcErrorQGetError
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
function ldcErrorQGetError()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	ldcErrorQErrors ${1} ldctst_stackSize
	[[ $? -eq 0 ]] || return 2

	if [[ ${ldctst_stackSize} -eq 0 ]]
	then
		ldcDeclareStr "No errors recorded." ${2}
	else
		ldcDeclareStr "($errQueueErrorFunction) $errQueueErrorMessage" ${2}
	fi
	
	return $?
}

# *****************************************************************************
#
#	ldcErrorQResetV
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
function ldcErrorQResetV()
{
	[[ -z "${1}" ]] && return 1

	ldcerr_QBuffer=""
	ldcerr_QTimestamp=""
	ldcerr_QDateTime=""

	ldcerr_QFunction=""
	ldcerr_QLine=0

	ldcerr_QError=Unknown
	ldcerr_QErrorMod=""
	ldcerr_QErrorDesc=""
	
	return 0
}

# *****************************************************************************
#
#	ldcErrorQExists
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
function ldcErrorQExists()
{
	[[ -z "${1}" ]] && return 1

	local qName=${1}
	local errQUid

	ldcStackExists ${qName} errQUid
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *****************************************************************************
#
#	ldcErrorQReset
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
ldcErrorQReset()
{
	[[ -z "${1}" ]] && return 1

	local qName=${1}
	local -i errCount

	ldcErrorQResetV $qName

	ldcErrorQExists $qName
	[[ $? -eq 0 ]] || return 1

	eval "let stackHead_${ldc_stackUid}=0"
	eval "let stackTail_${ldc_stackUid}=0"

	ldcErrorQErrors $qName errCount
	[[ $? -eq 0 ]] || return 2
	
	[[ ${errCount} -eq 0 ]] || return 3

	return 0
}

