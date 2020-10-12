# ******************************************************************************
# ******************************************************************************
#
#   ldcError.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage errorFunctions
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
#			Version 0.0.1 - 02-22-2016.
#			        0.1.0 - 05-30-2016.
#					0.1.1 - 06-08-2016.
#					0.1.2 - 06-26-2016.
#					0.2.0 - 01-11-2017.
#					0.2.1 - 02-09-2017.
#					0.2.2 - 08-27-2018.
#
# ******************************************************************************
# ******************************************************************************

declare -r ldclib_errorFunctions="0.2.2"	# version of library

# ******************************************************************************
#
#	Required global declarations
#
# ******************************************************************************

declare    ldcerr_arrayName			# name of the error name array
declare    ldcerr_name				# key into the $ldcerr_arrayName arrays

declare    ldcerr_codesName         # name of the error codes array
declare -A ldcerr_codes				# array names as index, value as index into $ldcerr_arrayName
declare -A ldcerr_keys				# array of names to keys

declare -i ldcerr_count				# count of error codes
declare -i ldcerr_number			# error number
declare    ldcerr_message    		# error message
declare    ldcerr_queryResult		# query result buffer (string)
declare    ldcerr_query				# error code or error name to look up
declare    ldcerr_buffer			# format buffer
declare    ldcerr_msgBuffer			# multi-message format buffer
declare    ldcerr_formatBuffer		# format code
declare    ldcerr_xmlVars			# path to the xml error file

declare    ldcerr_messagesLoaded=0	# 1 = error messages have been loaded into ldcerr_messages
declare -A ldcerr_messages			# associative array of error messages by message name

declare -i ldcerr_result=0		# result error code value

declare -i ldcerr_QInitialized=0	# Error queue has been initialized

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#   ldcErrorClearQuery
#
#		Clear the result variables
#
#	parameters:
#		none
#
#	returns:
#		0 ==> no error
#
# ******************************************************************************
function ldcErrorClearQuery()
{
	ldcerr_queryResult=""
	ldcerr_number=0
	ldcerr_name=""
	ldcerr_message=""

	ldcXMLParseInit ${ldcerr_arrayName} ${ldcerr_xmlVars}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#    ldcErrorInitialize
#
#	Read the error codes from the supplied xml file.
#
#	parameters:
#		ArrayName = internal name of the error code file
#		XmlVars = error code xml file name
#		CodesName = error codes file name
#
#	returns:
#		0 = no errors
#		non-zero = error code returned
#
# ******************************************************************************
function ldcErrorInitialize()
{
	ldcerr_arrayName=${1}
	ldcerr_xmlVars=${2}
	ldcerr_codesName=${3:-"ldcErrorCodes"}

	set -o pipefail

	ldcErrorClearQuery

	ldcXMLParseToArray "//ldc/ErrorMsgs/ErrorCode/@name" "${ldcerr_arrayName}" 0
	[[ $? -eq 0 ]] || return 1

	ldcXMLParseToCmnd "count(//ldc/ErrorMsgs/ErrorCode)"
	[[ $? -eq 0 ]] || return 2
	
	ldcerr_count=$ldcxmp_CommandResult

	ldcDynnReset "${ldcerr_arrayName}"
	[[ $? -eq 0 ]] || return 3

	ldcDynnReload "${ldcerr_arrayName}"
	[[ $? -eq 0 ]] || return 4

	ldcDynnValid "${ldcerr_arrayName}" ldcdyna_valid

	while [[ ${ldcdyna_valid} -eq 1 ]]
	do
		ldcDynn_GetElement
		[[ $? -eq 0 ]] || return 5

		ldcerr_codes[$ldcdyna_key]=${ldcdyna_value}
		ldcerr_keys[$ldcdyna_value]=$ldcdyna_key

		ldcDynnNext "${ldcerr_arrayName}"
		ldcDynn_Valid
		ldcdyna_valid=$?
	done

	return 0
}


# ******************************************************************************
#
#	ldcErrorValidName
#
#	Returns 0 if the error name is valid, 1 if not
#
#	parameters:
#		Error-Code-Name = error name
#
#	returns:
#		result = 0 if found, 1 if not found
#
# ******************************************************************************
function ldcErrorValidName()
{
	local name=${1}
	[[ -z "${name}" ]] && return 1

	local list
	ldcDynaGet "${ldcerr_arrayName}" list
	[[ $? -eq 0 ]] || return 2

	[[ " ${list} " =~ "${name}" ]] || return 3

	return 0
}

# ******************************************************************************
#
#	ldcErrorValidNumber
#
#	Return 0 if the error number is valid, otherwise return 1
#
#	parameters:
#		Error-Code-Number = error number
#
#	returns:
#		0 = valid
#		non-zero = not valid
#
# ******************************************************************************
function ldcErrorValidNumber()
{
	[[ ${1} -lt 0  ]] && return 1
	[[ ${1} -le ${ldcerr_count} ]] && return 0
	return 2
}

# ******************************************************************************
#
#	ldcErrorGetMessage
#
#	Given the error name, return the message
#
#	parameters:
#		Error-Code-Name = error name
#
#	returns:
#		result = 0 if no error
#				 1 if error
#
# ******************************************************************************
function ldcErrorGetMessage()
{
	local xpCName=${1}
	local xpCResult=0

	if [[ ${ldcerr_messagesLoaded} -ne 0 ]]
	then
		ldcerr_key=${ldcerr_keys["${xpCName}"]}
		ldcerr_message=${ldcerr_messages["${xpCName}"]}
	else
		ldcXMLParseToCmnd "string(//ldc/ErrorMsgs/ErrorCode[@name=\"${xpCName}\"]/message)"
		[[ $? -eq 0 ]] || return 1

		ldcerr_message=${ldcxmp_CommandResult}

		[[ -z "${ldcxmp_CommandResult}" ]]  &&  return 2
	fi

	ldcerr_name=${xpCName}
	return 0
}

# ******************************************************************************
#
#	ldcErrorMsgFromName
#
#	Given the error name, return the message
#
#	parameters:
#		Error-Code-Name = error name
#
#	outputs:
#		(string) Error-Code-Message = matching error name, Error_Unknown if not found
#
#	returns:
#		result = 0 if no error
#				 1 if error
#
# ******************************************************************************
function ldcErrorMsgFromName()
{
	local msgName=${1}

	ldcErrorGetMessage ${msgName}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#	ldcErrorMsgFromNumber
#
#	Given the error number, return the message
#
#	parameters:
#		Error-Code-Number = error number
#
#	outputs:
#		(string) Error-Code-Name = matching error name, Error_Unknown if not found
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcErrorGetMessageFromNumber()
{
	local number=$1

	ldcErrorValidNumber $number
	[[ $? -eq 0 ]] || return 1

	local msgName
	
	ldcDynaGetAt ${ldcerr_arrayName} ${number} msgName
	[[ $? -eq 0 ]] || return 2

	ldcErrorMsgFromName ${msgName}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	ldcErrorLookupNumber
#
#	Lookup error code number and convert to error name
#		in global variable ldcerr_name
#
#	parameters:
#		Error-Code-Number = error number
#
#	outputs:
#		(string) Error-Code-Name = matching error name, Error_Unknown if not found
#
#	returns:
#		result = 0 if no error
#				 1 if error
#
# ******************************************************************************
function ldcErrorLookupNumber()
{
	[[ -z "${1}" ]] && return 1

	local errNumber=${1}

	ldcErrorClearQuery

	ldcErrorGetMessageFromNumber $errNumber
	[[ $? -eq 0 ]] || return 2

	ldcDynaGetAt ${ldcerr_arrayName} ${errNumber} ldcerr_name
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	ldcErrorLookupName
#
#	Lookup error code name and convert to error number
#		in global variable error
#
#	parameters:
#		name = error code name
#
#	returns:
#		result = 0 if no error 
#				 non-zero --> result code
#
# ******************************************************************************
function ldcErrorLookupName()
{
	ldcErrorClearQuery

	local name=${1}
	local value=""

	ldcerr_name=${name}

	ldcDynnReset ${ldcerr_arrayName}
	[[ $? -eq 0 ]] || return 1

	ldcDynnReload ${ldcerr_arrayName}
	[[ $? -eq 0 ]] || return 2

	ldcerr_result=1
	while [[ $ldcdyna_valid -eq 1 ]]
	do
		ldcDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			ldcerr_result=$?
			break
		 }

		[[ "${ldcdyna_value}" == "${name}" ]] &&
		 {
			ldcerr_number=${ldcdyna_index}

			ldcErrorMsgFromName ${name}
			ldcerr_result=$?
			break
		 }

		ldcDynnNext ${ldcerr_arrayName}
	done

	return $ldcerr_result
}

# ******************************************************************************
#
#	ldcErrorLookupMsgs
#
#	Load all of the error messages into the message array
#
#	parameters:
#		forceLoad = 1 to force a reload of the table
#
#	returns:
#		result = 0 if no error 
#				 non-zero --> result code
#
# ******************************************************************************
function ldcErrorLookupMsgs()
{
	local forceLoad=${1:-0}
	local first=1

	[[ ${ldcerr_messagesLoaded} -eq 1 && ${forceLoad} -ne 1 ]] && return 0

	ldcerr_messagesLoaded=0

	ldcDynnReset ${ldcerr_arrayName}
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
		return ${ldcerr_result}
	 }

	ldcDynnReload ${ldcerr_arrayName}
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
		return ${ldcerr_result}
	 }

	ldcerr_messages=()
	ldcerr_result=1

	while [[ ${ldcdyna_valid} -eq 1 ]]
	do
		ldcerr_result=0

		ldcDynn_GetElement
		[[ $? -eq 0 ]] ||
		{
			ldcerr_result=$?
			[[ $ldcdyna_valid -eq 0 ]] && ldcerr_result=0
			break
		}

		ldcerr_name=${ldcdyna_value}

		ldcErrorGetMessage ${ldcerr_name}
		[[ $? -eq 0 ]] ||
		 {
			ldcerr_result=$?
			break
		 }

		ldcerr_messages["${ldcerr_name}"]=${ldcerr_message}
		
		ldcDynnNext ${ldcerr_arrayName}
		[[ $? -eq 0 ]] ||
		 {
			ldcerr_result=$?
			break
		 }
	done

	[[ $ldcerr_result -eq 0 ]] || ldcerr_messagesLoaded=1
	return $ldcerr_result
}

# ******************************************************************************
#
#	ldcErrorQResult_Name
#
#		format ErrorCode information by name
#
#	parameters:
#		format = 0 => unformatted
#			   = 1 => formatted (columns)
#
#	returns:
#		(integer) result = 0 => no error
#						 = 1 => error
#
# ******************************************************************************
function ldcErrorQResult_Name
{
	local format=$1

	if [ $format -eq 0 ]
	then
		printf -v ldcerr_queryResult "%s:%s:%s\n" "${ldcerr_name}" "${ldcerr_number}" "${ldcerr_message}"
	else
		printf -v ldcerr_queryResult "%s "'('"% u"')'" \"%s\"\n" "$ldcerr_name" "$ldcerr_number" "${ldcerr_message}"
	fi

	return 0
}

# ******************************************************************************
#
#	ldcErrorQResult_Number
#
#		format ErrorCode information by number
#
#	parameters:
#		format = 0 => unformatted
#			   = 1 => formatted (columns)
#
#	returns:
#		(integer) result = 0 => no error
#						 = 1 => error
#
# ******************************************************************************
function ldcErrorQResult_Number
{
	local format=$1

	if [ $format -eq 0 ]
	then
		printf -v ldcerr_queryResult "%s:%s:%s\n" "${ldcerr_number}" "${ldcerr_name}" "${ldcerr_message}"
	else
		printf -v ldcerr_queryResult '('"% u"')'" %s - \"%s\"\n" ${ldcerr_number} "${ldcerr_name}" "${ldcerr_message}"
	fi

	return 0
}

# ******************************************************************************
#
#	ldcErrorCodeList
#
#		returns a listing of all error codes according
#		to the ldcerr_formatBuffer
#
#	parameters:
#		order = 0 => order by ErrorCode (number)
#			  = 1 => order by ErrorName (name)
#		format = 0 => unformatted
#			   = 1 => formatted (columns)
#		dest = 0 => output to buffer (ldcerr_buffer)
#			 = 1 => output to console, copy to buffer
#
#	returns:
#		result = integer error code, -1 if not found
#
# ******************************************************************************
function ldcErrorCodeList()
{
	local order=${1:-0}			# 0 = order by number, 1 = order by name
	local format=${2:-0}		# 0 = unformatted, 1 = formatted
	local dest=${3:-0}			# 0 = output to buffer, 1 = output to console

	ldcerr_buffer=""

	if [ ${ldcerr_messagesLoaded} -ne 1 ]
	then
		ldcErrorLookupMsgs
		[[ $? -eq 0 ]] ||
		{
			ldcerr_result=$?
			return ${ldcerr_result}
		}
	fi

	if [ ${order} -eq 0 ]
	then
		ldcErrorCodeList_Number $format $dest
		[[ $? -eq 0 ]] || 
		{
			ldcerr_result=$?
			return ${ldcerr_result}
		}
	else
		ldcErrorCodeList_Name $format $dest
		[[ $? -eq 0 ]] || 
		 {
			ldcerr_result=$?
			return ${ldcerr_result}
		 }
	fi

	return 0
}

# ******************************************************************************
#
#	ldcErrorCodeList_Number
#
#		returns a listing of all error codes according
#		to the ldcerr_formatBuffer
#
#	parameters:
#		ldcerr_formatBuffer = formatting type + destination
#
#	returns:
#		result = integer error code, -1 if not found
#
# ******************************************************************************
function ldcErrorCodeList_Number()
{
	local format=$1
	local dest=$2

	local -i loopCount=0
	local -ir maxLoops=${ldcerr_count}+1
	local digits

	ldcerr_msgBuffer=""

	for ldcerr_number in ${!ldcErrors[@]}
	do
		ldcerr_name=${ldcerr_codes[${ldcerr_number}]}
		
		ldcerr_message=${ldcerr_messages["${ldcerr_name}"]}

		ldcErrorQResult_Number $format

		ldcerr_msgBuffer="${ldcerr_msgBuffer}${ldcerr_queryResult}"

		(( loopCount++ ))

		[[ $loopCount -lt $maxLoops ]] || break
	done

	[[ $dest -eq 0 ]] &&
	 {
		ldccli_optOverride=1
		ldcConioDisplay "$ldcerr_msgBuffer"
	 }

	ldcerr_buffer=$ldcerr_msgBuffer

	return 0
}


# ******************************************************************************
#
#	ldcErrorCodeList_Name
#
#		returns a listing of all error codes in Error Code Name order
#
#	parameters:
#
#	returns:
#		result = integer error code, -1 if not found
#
# ******************************************************************************
function ldcErrorCodeList_Name()
{
	local format=$1
	local dest=$2

	local -i loopCount=0
	local -ir maxLoops=$ldcerr_count+1

	ldcsrt_array=( ${ldcErrors[@]} )
	ldcSortArrayBubble

	ldcerr_msgBuffer=""

	for ldcerr_name in "${ldcsrt_array[@]}"
	do

		ldcerr_message=${ldcerr_messages["${ldcerr_name}"]}
		ldcerr_number=${ldcerr_keys["${ldcerr_name}"]}

		ldcErrorQResult_Name $format
		if [ $? -ne 0 ]
		then
			return $?
		fi

		ldcerr_msgBuffer="$ldcerr_msgBuffer$ldcerr_queryResult"

		(( loopCount++ ))

		[[ $loopCount -lt $maxLoops ]] || break
	done

	ldcerr_buffer=$ldcerr_msgBuffer

	[[ $dest -eq 0 ]] &&
	 {
		ldccli_optOverride=1
		ldcConioDisplay "$ldcerr_msgBuffer"
	 }

	return 0
}

# ******************************************************************************
#
#	ldcErrorQuery
#
#		Query the error codes.
#			The result of the look up is placed in
#				ldcerr_number, ldcerr_name, and ldcerr_message
#
#	parameters:
#		ldcerr_query = Error-Code-Name or Error-Code-Number
#		format = 0 => unformatted
#			   = 1 => formatted
#
#	returns:
#		(integer) result = 0 if no error
#						 = 1 if unable to complete the query
#
# ******************************************************************************
function ldcErrorQuery()
{
	ldcerr_query=$1
	local format

	[[ -z "$2" ]] && format=0 || format=$2

	ldcStrIsInteger $ldcerr_query

	if [ $? -eq 0 ]				# numeric value
	then
		ldcErrorValidNumber $ldcerr_query
		[[ $? -eq 0 ]] || return $?
		
		ldcErrorLookupNumber ${ldcerr_query}
		[[ $? -lt 0 ]] && return $?

		ldcErrorQResult_Number $format
		[[ $? -eq 0 ]] || return $?

		ldcerr_buffer="$ldcerr_queryResult"
	else
		ldcErrorLookupName ${ldcerr_query}
		[[ $? -lt 0 ]] && return $?
	
		ldcErrorQResult_Name $format

		ldcerr_buffer="$ldcerr_queryResult"
	fi

	if [ $? -ne 0 ]
	then
		ldcErrorLookupName "Unknown"
		[[ $? -lt 0 ]] && return $?

		ldcErrorQResult_Name $format
		[[ $? -eq 0 ]] || return $?

		ldcerr_buffer="$ldcerr_queryResult"
		return 1
	fi

	return 0
}

# ******************************************************************************
#
#    ldcErrorExitScript
#
#		exit with the error code associated with the error name
#
#	parameters:
#		Error-Name = Error name to get exit code from
#
# ******************************************************************************
function ldcErrorExitScript()
{
	local errorName=${1}

	declare -p "ldclib_errorQueueFunctions" > /dev/null 2>&1
	[[ $? -eq 0 ]] || # exists
	 {
		declare -p "ldclib_ldcErrorQDisp" > /dev/null 2>&1
		[[ $? -eq 0 ]] && # does not exist
		 {
			return 0		# cannot display - module missing
		 }
	 }

	ldcConioDisplay ""

	[[ $ldcerr_QInitialized ]] && ldcErrorQDispPop 1

	ldccli_optOverride=1

	ldcErrorLookupName $errorName
	if [ $? -lt 0 ]
	then
		ldcConioDisplay "$(tput bold ; tput setaf 4) Exit status: '${errorName}' unknown. $(tput sgr0)"
		exit 255
	fi

	ldcConioDisplay "**************************************"
	ldcConioDisplay ""
	ldcConioDisplay "$(tput bold) Exit status: $ldcerr_number = $ldcerr_message $(tput sgr0)"
	ldcConioDisplay ""
	ldcConioDisplay "**************************************"

	exit $ldcerr_number
}

