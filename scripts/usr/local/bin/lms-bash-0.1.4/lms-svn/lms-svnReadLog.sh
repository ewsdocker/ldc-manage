# *****************************************************************************
# *****************************************************************************
#
#		lms-svnReadLog.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package svnMakeRepo
# @subpackage svnReadLog
#
# *****************************************************************************
#
#	Copyright © 2016. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#		Version 0.0.1 - 09-01-2016.
#
# *****************************************************************************
# *****************************************************************************

declare    lmslib_svnReadLog="0.0.1"	# version of the library

# **************************************************************************

# *****************************************************************************
#
#	svnReadlmsLogOpen
#
#		Set the log name to open and check for existence
#
#	parameters:
#		fileName = name of the file to read
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function svnReadlmsLogOpen()
{
	local logName=${1:-"$lmscli_optLogFile"}

	lmssvn_readOpen=0

	[[ -z "${logName}" ]] &&
	 {
		lmsConioDebug $LINENO "LogError" "Missing log file name"
		return 1
	 }
	
	lmssvn_readFileName=$logName

	touch ${lmssvn_readFileName}
	[[ $? -eq 0 ]] ||
	 {
		return 2
	 }
	
	dynArrayIsRegistered "${lmssvn_readArrayName}"
	[[ $? -ne 0 ]] &&
	 {
		lmsDynaUnset "${lmssvn_readArrayName}"
	 }

	dynArrayNew "${lmssvn_readArrayName}" "A"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "LogError" "Unable to create dynamic array '${lmssvn_readArrayName}'"
		return 3
	 }

	lmssvn_readOpen=1

	return 0
}

# *****************************************************************************
#
#	svnReadLogProcess
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
function svnReadLogProcess()
{
	local    logField=""
	local -i keyIndex=0

	lmssvn_printBuffer=""

	while [ $keyIndex -lt ${#lmssvn_readArrayKeys[@]} ]
	do
		key=${lmssvn_readArrayKeys[$keyIndex]}

		lmsDynaGetAt "${lmssvn_readArrayName}" "${key}" logField
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "LogError" "Unable to get key '${key}' from '${lmssvn_readArrayName}'"
			return 1
		 }

		case $keyIndex in

			0)
				printf -v lmssvn_printBuffer "%s(%s)" "${lmssvn_printBuffer}" "${logField}"
				;;

			1)
				printf -v lmssvn_printBuffer "%s %s:\n" "${lmssvn_printBuffer}" "${logField}"
				;;

			*)
				printf -v lmssvn_printBuffer "%s    %s" "${lmssvn_printBuffer}" "${key}"

				let blanks=10-${#key}
				[[ ${blanks} -gt 0 ]]
				 {
					printf -v lmssvn_printBuffer "%s%*s" "${lmssvn_printBuffer}" ${blanks}
				 }

				printf -v lmssvn_printBuffer "%s: %s\n" "${lmssvn_printBuffer}" "${logField}"
				;;
		esac

		keyIndex+=1
	done

	lmsConioDisplay "${lmssvn_printBuffer}"

	return 0
}

# *****************************************************************************
#
#	svnReadLogParse
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
function svnReadLogParse()
{
	local -i keyCount=${#lmssvn_readArrayKeys[@]}

	lmsStrExplode "${lmssvn_readBuffer}" "-"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "LogError" "Unable to parse '${lmssvn_readBuffer}}'"
		return 1
	 }

	local -i explodedCount=${#lmsstr_Exploded[@]}
	local -i keyIndex=0
	local -i msgLength=0

	while [ ${keyIndex} -lt ${keyCount} ]
	do

		lmsDynaSetAt ${lmssvn_readArrayName} ${lmssvn_readArrayKeys[$keyIndex]} "${lmsstr_Exploded[${keyIndex}]}"
		[[ $? -eq 0 ]] ||
		{
			lmsConioDebug $LINENO "LogError" "Unable to add key '$key' to '${lmssvn_readArrayName}'"
			return 2
		}
		
		msgLength+=${#lmsstr_Exploded[${keyIndex}]}
		msgLength+=1

		keyIndex+=1
	done
	
	local    msgBuffer
	printf -v msgBuffer "\n"

	[[ ${explodedCount} -gt ${keyCount} ]] &&
	 {
		let key=$keyCount-1

		lmsDynaGetAt "${lmssvn_readArrayName}" "${lmssvn_readArrayKeys[$key]}" msgBuffer
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "LogError" "lmsDynaGetAt failed."
			return 3
		 }

		msgBuffer="${msgBuffer}-${lmssvn_readBuffer:$msgLength}"

		lmsDynaSetAt "${lmssvn_readArrayName}" "${lmssvn_readArrayKeys[$key]}" "${msgBuffer}"
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "LogError" "lmsDynaSetAt failed."
			return 4
		 }
	 }

	eval "${lmssvn_processCallback}"
	return 0
}

# *****************************************************************************
#
#	svnReadLogNext
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
function svnReadLogNext()
{
	[[ -z ${lmssvn_readOpen} ]] &&   # never initialized, or eof
	 {
		lmsConioDebug $LINENO "LogError" "Log file is not open for reading!"
		return 1
	 }

	exec 3<"${lmssvn_logName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "LogError" "Unable to open '${lmssvn_logName}'"
		return 1
	 }

	while  read -u3 lmssvn_readBuffer
	do
		eval ${lmssvn_readCallback}
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "LogError" "readcallback failed on '${lmssvn_readBuffer}'"
			return 2
		 }

	done

	lmssvn_readOpen=0

	return 0
}

# *****************************************************************************
#
#	svnReadLogSetCallback
#
#		Set the log read callback function name
#
#	parameters:
#		readCallback = name of the read callback function
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function svnReadLogSetCallback()
{
	lmssvn_readCallback="${1}"

	[[ -z "${lmssvn_readCallback}" ]] &&
	{
		lmsConioDebug $LINENO "LogError" "Log read callback is empty"
		return 1
	}
	
	return 0
}

# *****************************************************************************
#
#	svnReadLogSetProcess
#
#		Set the log read callback function name
#
#	parameters:
#		readCallback = name of the read callback function
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function svnReadLogSetProcess()
{
	lmssvn_processCallback="${1}"

	[[ -z "${lmssvn_processCallback}" ]] &&
	{
		lmsConioDebug $LINENO "LogError" "Log read process callback is empty"
		return 1
	}

	return 0
}

# *****************************************************************************
#
#	svnReadlmsLogClose
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
function svnReadlmsLogClose()
{
	lmssvn_readOpen=0
	lmsLogClose

	return 0
}

# *****************************************************************************
# *****************************************************************************
#
#			End
#
# *****************************************************************************
# *****************************************************************************

