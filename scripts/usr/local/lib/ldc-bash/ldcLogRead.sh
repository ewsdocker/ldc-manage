# **************************************************************************
# **************************************************************************
#
#   ldcLogRead.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
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
#		Version 0.0.1 - 09-01-2016.
#				0.0.2 - 02-09-2017.
#
# **************************************************************************
# **************************************************************************

declare    ldclib_ldcLogRead="0.0.2"	# version of the library

# **************************************************************************

declare	   ldclog_readOpen=0
declare    ldclog_readBuffer=""
declare    ldclog_printBuffer=""

declare    ldclog_readArrayName="ldclog_readArray"
declare -r ldclog_readArrayKeys=( "date" "time" "application" "script" "function" "line" "code" "message" )
declare -r ldclog_printOrder=( "date" "time" "application" "script" "function" "line" "code" "message" )

declare    ldclog_readCallback="ldcLogReadParse"
declare    ldclog_processCallback="ldcLogReadProcess"

# *****************************************************************************
#
#	ldcLogReadOpen
#
#		Set the log name to open and check for existence
#
#	parameters:
#		fileName = (optional) name of the file to read
#
#	outputs:
#		record = log record (string)
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogReadOpen()
{
	local logName=${1:-"ldclog_file"}

	ldclog_readOpen=0

	declare -p ldclib_ldcLog 1>/dev/null 2>&1
	[[ $? -eq 0 ]] || return 1

	ldcDynaRegistered "${ldclog_readArrayName}"
	[[ $? -eq 0 ]] && ldcDynaUnset "${ldclog_readArrayName}"

	ldcLogOpen "${logName}" "old"
	[[ $? -eq 0 ]] || return 2

	ldclog_readOpen=1
	ldcDynaNew "${ldclog_readArrayName}" "A"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# *****************************************************************************
#
#	ldcLogReadProcess
#
#		Process the log message into the logFields array
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogReadProcess()
{
	local    logField=""
	local -i keyIndex=0

	ldclog_printBuffer=""

	while [ $keyIndex -lt ${#ldclog_readArrayKeys[@]} ]
	do
		key=${ldclog_readArrayKeys[$keyIndex]}

		ldcDynaGetAt "${ldclog_readArrayName}" "${key}" logField
		[[ $? -eq 0 ]] || return 1

		case $keyIndex in

			0)
				printf -v ldclog_printBuffer "%s(%s)" "${ldclog_printBuffer}" "${logField}"
				;;

			1)
				printf -v ldclog_printBuffer "%s %s:\n" "${ldclog_printBuffer}" "${logField}"
				;;

			*)
				printf -v ldclog_printBuffer "%s    %s" "${ldclog_printBuffer}" "${key}"

				let blanks=12-${#key}
				[[ ${blanks} -gt 0 ]]
				 {
					printf -v ldclog_printBuffer "%s%*s" "${ldclog_printBuffer}" ${blanks}
				 }

				printf -v ldclog_printBuffer "%s: %s\n" "${ldclog_printBuffer}" "${logField}"
				;;
		esac

		(( keyIndex++ ))
	done

	[[ -n "${ldclog_printBuffer}" ]] && ldcConioDisplay "${ldclog_printBuffer}"

	return 0
}

# *****************************************************************************
#
#	ldcLogReadParse
#
#		Parse the log message into the logFields array
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogReadParse()
{
	local -i keyCount=${#ldclog_readArrayKeys[@]}

	local separator=${ldclog_readBuffer:0:1}
	ldclog_readBuffer="${ldclog_readBuffer:1}"

	ldclog_msgFields=()

	ldcStrExplode "${ldclog_readBuffer}" "$separator" ldclog_msgFields
	[[ $? -eq 0 ]] || return 1

	local -i fieldCount=${#ldclog_msgFields[@]}

	local -i keyIndex=0
	local -i msgLength=0

	while [ ${keyIndex} -lt ${keyCount} ]
	do

		ldcDynaSetAt ${ldclog_readArrayName} ${ldclog_readArrayKeys[$keyIndex]} "${ldclog_msgFields[$keyIndex]}"
		[[ $? -eq 0 ]] || return 2
		
		msgLength+=${#ldclog_msgFields[${keyIndex}]}

		(( msgLength++ ))
		(( keyIndex++ ))
	done
	
	local    msgBuffer
	printf -v msgBuffer "\n"

	[[ ${fieldCount} -gt ${keyCount} ]] &&
	 {
		key=${keyCount}-1
		ldcDynaGetAt "${ldclog_readArrayName}" "${ldclog_readArrayKeys[$key]}" msgBuffer
		[[ $? -eq 0 ]] || return 3

		msgBuffer="${msgBuffer}-${ldclog_readBuffer:$msgLength}"

		ldcDynaSetAt "${ldclog_readArrayName}" "${ldclog_readArrayKeys[$key]}" "${msgBuffer}"
		[[ $? -eq 0 ]] || return 4
	 }

	eval ${ldclog_processCallback}
	[[ $? -eq 0 ]] || return 5

	return 0
}

# *****************************************************************************
#
#	ldcLogRead
#
#		Read the next message from log file and return as a string
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		1 = file-not-open or eof-detected
#		2 = read-error
#
# *****************************************************************************
function ldcLogRead()
{
	[[ ${ldclog_readOpen} -ne 0 ]] || return 1

	exec 3<"${ldclog_file}"
	[[ $? -eq 0 ]] || return 2

	while  read -u3 ldclog_readBuffer
	do
		eval ${ldclog_readCallback}
		[[ $? -eq 0 ]] || return 3
	done

	ldclog_readOpen=0

	return 0
}

# *****************************************************************************
#
#	ldcLogReadCallback
#
#		Set the log read parse callback function name
#
#	parameters:
#		readCallback = name of the read callback function
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogReadCallback()
{
	ldclog_readCallback=${1:-"ldcLogReadParse"}
	[[ -z "${ldclog_readCallback}" ]] && return 1
	return 0
}

# *****************************************************************************
#
#	ldcLogReadCallbackP
#
#		Set the log read process callback function name
#
#	parameters:
#		readCallback = name of the read callback function
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogReadCallbackP()
{
	ldclog_processCallback=${1:-"ldcLogReadProcess"}
	[[ -z "${ldclog_processCallback}" ]] && return 1
	return 0
}

# *****************************************************************************
#
#	ldcLogReadClose
#
#		Close the read log file
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function ldcLogReadClose()
{
	ldclog_readOpen=0
	ldcLogClose

	return 0
}

