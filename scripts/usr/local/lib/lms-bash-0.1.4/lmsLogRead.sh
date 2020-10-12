# **************************************************************************
# **************************************************************************
#
#   lmsLogRead.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
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
#		Version 0.0.1 - 09-01-2016.
#				0.0.2 - 02-09-2017.
#
# **************************************************************************
# **************************************************************************

declare    lmslib_lmsLogRead="0.0.2"	# version of the library

# **************************************************************************

declare	   lmslog_readOpen=0
declare    lmslog_readBuffer=""
declare    lmslog_printBuffer=""

declare    lmslog_readArrayName="lmslog_readArray"
declare -r lmslog_readArrayKeys=( "date" "time" "application" "script" "function" "line" "code" "message" )
declare -r lmslog_printOrder=( "date" "time" "application" "script" "function" "line" "code" "message" )

declare    lmslog_readCallback="lmsLogReadParse"
declare    lmslog_processCallback="lmsLogReadProcess"

# *****************************************************************************
#
#	lmsLogReadOpen
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
function lmsLogReadOpen()
{
	local logName=${1:-"lmslog_file"}

	lmslog_readOpen=0

	declare -p lmslib_lmsLog 1>/dev/null 2>&1
	[[ $? -eq 0 ]] || return 1

	lmsDynaRegistered "${lmslog_readArrayName}"
	[[ $? -eq 0 ]] && lmsDynaUnset "${lmslog_readArrayName}"

	lmsLogOpen "${logName}" "old"
	[[ $? -eq 0 ]] || return 2

	lmslog_readOpen=1
	lmsDynaNew "${lmslog_readArrayName}" "A"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# *****************************************************************************
#
#	lmsLogReadProcess
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
function lmsLogReadProcess()
{
	local    logField=""
	local -i keyIndex=0

	lmslog_printBuffer=""

	while [ $keyIndex -lt ${#lmslog_readArrayKeys[@]} ]
	do
		key=${lmslog_readArrayKeys[$keyIndex]}

		lmsDynaGetAt "${lmslog_readArrayName}" "${key}" logField
		[[ $? -eq 0 ]] || return 1

		case $keyIndex in

			0)
				printf -v lmslog_printBuffer "%s(%s)" "${lmslog_printBuffer}" "${logField}"
				;;

			1)
				printf -v lmslog_printBuffer "%s %s:\n" "${lmslog_printBuffer}" "${logField}"
				;;

			*)
				printf -v lmslog_printBuffer "%s    %s" "${lmslog_printBuffer}" "${key}"

				let blanks=12-${#key}
				[[ ${blanks} -gt 0 ]]
				 {
					printf -v lmslog_printBuffer "%s%*s" "${lmslog_printBuffer}" ${blanks}
				 }

				printf -v lmslog_printBuffer "%s: %s\n" "${lmslog_printBuffer}" "${logField}"
				;;
		esac

		(( keyIndex++ ))
	done

	[[ -n "${lmslog_printBuffer}" ]] && lmsConioDisplay "${lmslog_printBuffer}"

	return 0
}

# *****************************************************************************
#
#	lmsLogReadParse
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
function lmsLogReadParse()
{
	local -i keyCount=${#lmslog_readArrayKeys[@]}

	local separator=${lmslog_readBuffer:0:1}
	lmslog_readBuffer="${lmslog_readBuffer:1}"

	lmslog_msgFields=()

	lmsStrExplode "${lmslog_readBuffer}" "$separator" lmslog_msgFields
	[[ $? -eq 0 ]] || return 1

	local -i fieldCount=${#lmslog_msgFields[@]}

	local -i keyIndex=0
	local -i msgLength=0

	while [ ${keyIndex} -lt ${keyCount} ]
	do

		lmsDynaSetAt ${lmslog_readArrayName} ${lmslog_readArrayKeys[$keyIndex]} "${lmslog_msgFields[$keyIndex]}"
		[[ $? -eq 0 ]] || return 2
		
		msgLength+=${#lmslog_msgFields[${keyIndex}]}

		(( msgLength++ ))
		(( keyIndex++ ))
	done
	
	local    msgBuffer
	printf -v msgBuffer "\n"

	[[ ${fieldCount} -gt ${keyCount} ]] &&
	 {
		key=${keyCount}-1
		lmsDynaGetAt "${lmslog_readArrayName}" "${lmslog_readArrayKeys[$key]}" msgBuffer
		[[ $? -eq 0 ]] || return 3

		msgBuffer="${msgBuffer}-${lmslog_readBuffer:$msgLength}"

		lmsDynaSetAt "${lmslog_readArrayName}" "${lmslog_readArrayKeys[$key]}" "${msgBuffer}"
		[[ $? -eq 0 ]] || return 4
	 }

	eval ${lmslog_processCallback}
	[[ $? -eq 0 ]] || return 5

	return 0
}

# *****************************************************************************
#
#	lmsLogRead
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
function lmsLogRead()
{
	[[ ${lmslog_readOpen} -ne 0 ]] || return 1

	exec 3<"${lmslog_file}"
	[[ $? -eq 0 ]] || return 2

	while  read -u3 lmslog_readBuffer
	do
		eval ${lmslog_readCallback}
		[[ $? -eq 0 ]] || return 3
	done

	lmslog_readOpen=0

	return 0
}

# *****************************************************************************
#
#	lmsLogReadCallback
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
function lmsLogReadCallback()
{
	lmslog_readCallback=${1:-"lmsLogReadParse"}
	[[ -z "${lmslog_readCallback}" ]] && return 1
	return 0
}

# *****************************************************************************
#
#	lmsLogReadCallbackP
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
function lmsLogReadCallbackP()
{
	lmslog_processCallback=${1:-"lmsLogReadProcess"}
	[[ -z "${lmslog_processCallback}" ]] && return 1
	return 0
}

# *****************************************************************************
#
#	lmsLogReadClose
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
function lmsLogReadClose()
{
	lmslog_readOpen=0
	lmsLogClose

	return 0
}

