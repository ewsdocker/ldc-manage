# ******************************************************************************
# ******************************************************************************
#
#   lmsError.sh
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

declare -r lmslib_errorFunctions="0.2.2"	# version of library

# ******************************************************************************
#
#	Required global declarations
#
# ******************************************************************************

declare    lmserr_arrayName			# name of the error name array
declare    lmserr_name				# key into the $lmserr_arrayName arrays

declare    lmserr_codesName         # name of the error codes array
declare -A lmserr_codes				# array names as index, value as index into $lmserr_arrayName
declare -A lmserr_keys				# array of names to keys

declare -i lmserr_count				# count of error codes
declare -i lmserr_number			# error number
declare    lmserr_message    		# error message
declare    lmserr_queryResult		# query result buffer (string)
declare    lmserr_query				# error code or error name to look up
declare    lmserr_buffer			# format buffer
declare    lmserr_msgBuffer			# multi-message format buffer
declare    lmserr_formatBuffer		# format code
declare    lmserr_xmlVars			# path to the xml error file

declare    lmserr_messagesLoaded=0	# 1 = error messages have been loaded into lmserr_messages
declare -A lmserr_messages			# associative array of error messages by message name

declare -i lmserr_result=0		# result error code value

declare -i lmserr_QInitialized=0	# Error queue has been initialized

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#   lmsErrorClearQuery
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
function lmsErrorClearQuery()
{
	lmserr_queryResult=""
	lmserr_number=0
	lmserr_name=""
	lmserr_message=""

	lmsXMLParseInit ${lmserr_arrayName} ${lmserr_xmlVars}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#    lmsErrorInitialize
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
function lmsErrorInitialize()
{
	lmserr_arrayName=${1}
	lmserr_xmlVars=${2}
	lmserr_codesName=${3:-"lmsErrorCodes"}

	set -o pipefail

	lmsErrorClearQuery

	lmsXMLParseToArray "//lms/ErrorMsgs/ErrorCode/@name" "${lmserr_arrayName}" 0
	[[ $? -eq 0 ]] || return 1

	lmsXMLParseToCmnd "count(//lms/ErrorMsgs/ErrorCode)"
	[[ $? -eq 0 ]] || return 2
	
	lmserr_count=$lmsxmp_CommandResult

	lmsDynnReset "${lmserr_arrayName}"
	[[ $? -eq 0 ]] || return 3

	lmsDynnReload "${lmserr_arrayName}"
	[[ $? -eq 0 ]] || return 4

	lmsDynnValid "${lmserr_arrayName}" lmsdyna_valid

	while [[ ${lmsdyna_valid} -eq 1 ]]
	do
		lmsDynn_GetElement
		[[ $? -eq 0 ]] || return 5

		lmserr_codes[$lmsdyna_key]=${lmsdyna_value}
		lmserr_keys[$lmsdyna_value]=$lmsdyna_key

		lmsDynnNext "${lmserr_arrayName}"
		lmsDynn_Valid
		lmsdyna_valid=$?
	done

	return 0
}


# ******************************************************************************
#
#	lmsErrorValidName
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
function lmsErrorValidName()
{
	local name=${1}
	[[ -z "${name}" ]] && return 1

	local list
	lmsDynaGet "${lmserr_arrayName}" list
	[[ $? -eq 0 ]] || return 2

	[[ " ${list} " =~ "${name}" ]] || return 3

	return 0
}

# ******************************************************************************
#
#	lmsErrorValidNumber
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
function lmsErrorValidNumber()
{
	[[ ${1} -lt 0  ]] && return 1
	[[ ${1} -le ${lmserr_count} ]] && return 0
	return 2
}

# ******************************************************************************
#
#	lmsErrorGetMessage
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
function lmsErrorGetMessage()
{
	local xpCName=${1}
	local xpCResult=0

	if [[ ${lmserr_messagesLoaded} -ne 0 ]]
	then
		lmserr_key=${lmserr_keys["${xpCName}"]}
		lmserr_message=${lmserr_messages["${xpCName}"]}
	else
		lmsXMLParseToCmnd "string(//lms/ErrorMsgs/ErrorCode[@name=\"${xpCName}\"]/message)"
		[[ $? -eq 0 ]] || return 1

		lmserr_message=${lmsxmp_CommandResult}

		[[ -z "${lmsxmp_CommandResult}" ]]  &&  return 2
	fi

	lmserr_name=${xpCName}
	return 0
}

# ******************************************************************************
#
#	lmsErrorMsgFromName
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
function lmsErrorMsgFromName()
{
	local msgName=${1}

	lmsErrorGetMessage ${msgName}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#	lmsErrorMsgFromNumber
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
function lmsErrorGetMessageFromNumber()
{
	local number=$1

	lmsErrorValidNumber $number
	[[ $? -eq 0 ]] || return 1

	local msgName
	
	lmsDynaGetAt ${lmserr_arrayName} ${number} msgName
	[[ $? -eq 0 ]] || return 2

	lmsErrorMsgFromName ${msgName}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	lmsErrorLookupNumber
#
#	Lookup error code number and convert to error name
#		in global variable lmserr_name
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
function lmsErrorLookupNumber()
{
	[[ -z "${1}" ]] && return 1

	local errNumber=${1}

	lmsErrorClearQuery

	lmsErrorGetMessageFromNumber $errNumber
	[[ $? -eq 0 ]] || return 2

	lmsDynaGetAt ${lmserr_arrayName} ${errNumber} lmserr_name
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	lmsErrorLookupName
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
function lmsErrorLookupName()
{
	lmsErrorClearQuery

	local name=${1}
	local value=""

	lmserr_name=${name}

	lmsDynnReset ${lmserr_arrayName}
	[[ $? -eq 0 ]] || return 1

	lmsDynnReload ${lmserr_arrayName}
	[[ $? -eq 0 ]] || return 2

	lmserr_result=1
	while [[ $lmsdyna_valid -eq 1 ]]
	do
		lmsDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			lmserr_result=$?
			break
		 }

		[[ "${lmsdyna_value}" == "${name}" ]] &&
		 {
			lmserr_number=${lmsdyna_index}

			lmsErrorMsgFromName ${name}
			lmserr_result=$?
			break
		 }

		lmsDynnNext ${lmserr_arrayName}
	done

	return $lmserr_result
}

# ******************************************************************************
#
#	lmsErrorLookupMsgs
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
function lmsErrorLookupMsgs()
{
	local forceLoad=${1:-0}
	local first=1

	[[ ${lmserr_messagesLoaded} -eq 1 && ${forceLoad} -ne 1 ]] && return 0

	lmserr_messagesLoaded=0

	lmsDynnReset ${lmserr_arrayName}
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
		return ${lmserr_result}
	 }

	lmsDynnReload ${lmserr_arrayName}
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
		return ${lmserr_result}
	 }

	lmserr_messages=()
	lmserr_result=1

	while [[ ${lmsdyna_valid} -eq 1 ]]
	do
		lmserr_result=0

		lmsDynn_GetElement
		[[ $? -eq 0 ]] ||
		{
			lmserr_result=$?
			[[ $lmsdyna_valid -eq 0 ]] && lmserr_result=0
			break
		}

		lmserr_name=${lmsdyna_value}

		lmsErrorGetMessage ${lmserr_name}
		[[ $? -eq 0 ]] ||
		 {
			lmserr_result=$?
			break
		 }

		lmserr_messages["${lmserr_name}"]=${lmserr_message}
		
		lmsDynnNext ${lmserr_arrayName}
		[[ $? -eq 0 ]] ||
		 {
			lmserr_result=$?
			break
		 }
	done

	[[ $lmserr_result -eq 0 ]] || lmserr_messagesLoaded=1
	return $lmserr_result
}

# ******************************************************************************
#
#	lmsErrorQResult_Name
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
function lmsErrorQResult_Name
{
	local format=$1

	if [ $format -eq 0 ]
	then
		printf -v lmserr_queryResult "%s:%s:%s\n" "${lmserr_name}" "${lmserr_number}" "${lmserr_message}"
	else
		printf -v lmserr_queryResult "%s "'('"% u"')'" \"%s\"\n" "$lmserr_name" "$lmserr_number" "${lmserr_message}"
	fi

	return 0
}

# ******************************************************************************
#
#	lmsErrorQResult_Number
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
function lmsErrorQResult_Number
{
	local format=$1

	if [ $format -eq 0 ]
	then
		printf -v lmserr_queryResult "%s:%s:%s\n" "${lmserr_number}" "${lmserr_name}" "${lmserr_message}"
	else
		printf -v lmserr_queryResult '('"% u"')'" %s - \"%s\"\n" ${lmserr_number} "${lmserr_name}" "${lmserr_message}"
	fi

	return 0
}

# ******************************************************************************
#
#	lmsErrorCodeList
#
#		returns a listing of all error codes according
#		to the lmserr_formatBuffer
#
#	parameters:
#		order = 0 => order by ErrorCode (number)
#			  = 1 => order by ErrorName (name)
#		format = 0 => unformatted
#			   = 1 => formatted (columns)
#		dest = 0 => output to buffer (lmserr_buffer)
#			 = 1 => output to console, copy to buffer
#
#	returns:
#		result = integer error code, -1 if not found
#
# ******************************************************************************
function lmsErrorCodeList()
{
	local order=${1:-0}			# 0 = order by number, 1 = order by name
	local format=${2:-0}		# 0 = unformatted, 1 = formatted
	local dest=${3:-0}			# 0 = output to buffer, 1 = output to console

	lmserr_buffer=""

	if [ ${lmserr_messagesLoaded} -ne 1 ]
	then
		lmsErrorLookupMsgs
		[[ $? -eq 0 ]] ||
		{
			lmserr_result=$?
			return ${lmserr_result}
		}
	fi

	if [ ${order} -eq 0 ]
	then
		lmsErrorCodeList_Number $format $dest
		[[ $? -eq 0 ]] || 
		{
			lmserr_result=$?
			return ${lmserr_result}
		}
	else
		lmsErrorCodeList_Name $format $dest
		[[ $? -eq 0 ]] || 
		 {
			lmserr_result=$?
			return ${lmserr_result}
		 }
	fi

	return 0
}

# ******************************************************************************
#
#	lmsErrorCodeList_Number
#
#		returns a listing of all error codes according
#		to the lmserr_formatBuffer
#
#	parameters:
#		lmserr_formatBuffer = formatting type + destination
#
#	returns:
#		result = integer error code, -1 if not found
#
# ******************************************************************************
function lmsErrorCodeList_Number()
{
	local format=$1
	local dest=$2

	local -i loopCount=0
	local -ir maxLoops=${lmserr_count}+1
	local digits

	lmserr_msgBuffer=""

	for lmserr_number in ${!lmsErrors[@]}
	do
		lmserr_name=${lmserr_codes[${lmserr_number}]}
		
		lmserr_message=${lmserr_messages["${lmserr_name}"]}

		lmsErrorQResult_Number $format

		lmserr_msgBuffer="${lmserr_msgBuffer}${lmserr_queryResult}"

		(( loopCount++ ))

		[[ $loopCount -lt $maxLoops ]] || break
	done

	[[ $dest -eq 0 ]] &&
	 {
		lmscli_optOverride=1
		lmsConioDisplay "$lmserr_msgBuffer"
	 }

	lmserr_buffer=$lmserr_msgBuffer

	return 0
}


# ******************************************************************************
#
#	lmsErrorCodeList_Name
#
#		returns a listing of all error codes in Error Code Name order
#
#	parameters:
#
#	returns:
#		result = integer error code, -1 if not found
#
# ******************************************************************************
function lmsErrorCodeList_Name()
{
	local format=$1
	local dest=$2

	local -i loopCount=0
	local -ir maxLoops=$lmserr_count+1

	lmssrt_array=( ${lmsErrors[@]} )
	lmsSortArrayBubble

	lmserr_msgBuffer=""

	for lmserr_name in "${lmssrt_array[@]}"
	do

		lmserr_message=${lmserr_messages["${lmserr_name}"]}
		lmserr_number=${lmserr_keys["${lmserr_name}"]}

		lmsErrorQResult_Name $format
		if [ $? -ne 0 ]
		then
			return $?
		fi

		lmserr_msgBuffer="$lmserr_msgBuffer$lmserr_queryResult"

		(( loopCount++ ))

		[[ $loopCount -lt $maxLoops ]] || break
	done

	lmserr_buffer=$lmserr_msgBuffer

	[[ $dest -eq 0 ]] &&
	 {
		lmscli_optOverride=1
		lmsConioDisplay "$lmserr_msgBuffer"
	 }

	return 0
}

# ******************************************************************************
#
#	lmsErrorQuery
#
#		Query the error codes.
#			The result of the look up is placed in
#				lmserr_number, lmserr_name, and lmserr_message
#
#	parameters:
#		lmserr_query = Error-Code-Name or Error-Code-Number
#		format = 0 => unformatted
#			   = 1 => formatted
#
#	returns:
#		(integer) result = 0 if no error
#						 = 1 if unable to complete the query
#
# ******************************************************************************
function lmsErrorQuery()
{
	lmserr_query=$1
	local format

	[[ -z "$2" ]] && format=0 || format=$2

	lmsStrIsInteger $lmserr_query

	if [ $? -eq 0 ]				# numeric value
	then
		lmsErrorValidNumber $lmserr_query
		[[ $? -eq 0 ]] || return $?
		
		lmsErrorLookupNumber ${lmserr_query}
		[[ $? -lt 0 ]] && return $?

		lmsErrorQResult_Number $format
		[[ $? -eq 0 ]] || return $?

		lmserr_buffer="$lmserr_queryResult"
	else
		lmsErrorLookupName ${lmserr_query}
		[[ $? -lt 0 ]] && return $?
	
		lmsErrorQResult_Name $format

		lmserr_buffer="$lmserr_queryResult"
	fi

	if [ $? -ne 0 ]
	then
		lmsErrorLookupName "Unknown"
		[[ $? -lt 0 ]] && return $?

		lmsErrorQResult_Name $format
		[[ $? -eq 0 ]] || return $?

		lmserr_buffer="$lmserr_queryResult"
		return 1
	fi

	return 0
}

# ******************************************************************************
#
#    lmsErrorExitScript
#
#		exit with the error code associated with the error name
#
#	parameters:
#		Error-Name = Error name to get exit code from
#
# ******************************************************************************
function lmsErrorExitScript()
{
	local errorName=${1}

	declare -p "lmslib_errorQueueFunctions" > /dev/null 2>&1
	[[ $? -eq 0 ]] || # exists
	 {
		declare -p "lmslib_lmsErrorQDisp" > /dev/null 2>&1
		[[ $? -eq 0 ]] && # does not exist
		 {
			return 0		# cannot display - module missing
		 }
	 }

	lmsConioDisplay ""

	[[ $lmserr_QInitialized ]] && lmsErrorQDispPop 1

	lmscli_optOverride=1

	lmsErrorLookupName $errorName
	if [ $? -lt 0 ]
	then
		lmsConioDisplay "$(tput bold ; tput setaf 4) Exit status: '${errorName}' unknown. $(tput sgr0)"
		exit 255
	fi

	lmsConioDisplay "**************************************"
	lmsConioDisplay ""
	lmsConioDisplay "$(tput bold) Exit status: $lmserr_number = $lmserr_message $(tput sgr0)"
	lmsConioDisplay ""
	lmsConioDisplay "**************************************"

	exit $lmserr_number
}

