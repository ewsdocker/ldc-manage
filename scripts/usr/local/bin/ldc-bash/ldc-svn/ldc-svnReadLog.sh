# *****************************************************************************
# *****************************************************************************
#
#		ldc-svnReadLog.sh
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

declare    ldclib_svnReadLog="0.0.1"	# version of the library

# **************************************************************************

# *****************************************************************************
#
#	svnReadldcLogOpen
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
function svnReadldcLogOpen()
{
	local logName=${1:-"$ldccli_optLogFile"}

	ldcsvn_readOpen=0

	[[ -z "${logName}" ]] &&
	 {
		ldcConioDebug $LINENO "LogError" "Missing log file name"
		return 1
	 }
	
	ldcsvn_readFileName=$logName

	touch ${ldcsvn_readFileName}
	[[ $? -eq 0 ]] ||
	 {
		return 2
	 }
	
	dynArrayIsRegistered "${ldcsvn_readArrayName}"
	[[ $? -ne 0 ]] &&
	 {
		ldcDynaUnset "${ldcsvn_readArrayName}"
	 }

	dynArrayNew "${ldcsvn_readArrayName}" "A"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "LogError" "Unable to create dynamic array '${ldcsvn_readArrayName}'"
		return 3
	 }

	ldcsvn_readOpen=1

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

	ldcsvn_printBuffer=""

	while [ $keyIndex -lt ${#ldcsvn_readArrayKeys[@]} ]
	do
		key=${ldcsvn_readArrayKeys[$keyIndex]}

		ldcDynaGetAt "${ldcsvn_readArrayName}" "${key}" logField
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "LogError" "Unable to get key '${key}' from '${ldcsvn_readArrayName}'"
			return 1
		 }

		case $keyIndex in

			0)
				printf -v ldcsvn_printBuffer "%s(%s)" "${ldcsvn_printBuffer}" "${logField}"
				;;

			1)
				printf -v ldcsvn_printBuffer "%s %s:\n" "${ldcsvn_printBuffer}" "${logField}"
				;;

			*)
				printf -v ldcsvn_printBuffer "%s    %s" "${ldcsvn_printBuffer}" "${key}"

				let blanks=10-${#key}
				[[ ${blanks} -gt 0 ]]
				 {
					printf -v ldcsvn_printBuffer "%s%*s" "${ldcsvn_printBuffer}" ${blanks}
				 }

				printf -v ldcsvn_printBuffer "%s: %s\n" "${ldcsvn_printBuffer}" "${logField}"
				;;
		esac

		keyIndex+=1
	done

	ldcConioDisplay "${ldcsvn_printBuffer}"

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
	local -i keyCount=${#ldcsvn_readArrayKeys[@]}

	ldcStrExplode "${ldcsvn_readBuffer}" "-"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "LogError" "Unable to parse '${ldcsvn_readBuffer}}'"
		return 1
	 }

	local -i explodedCount=${#ldcstr_Exploded[@]}
	local -i keyIndex=0
	local -i msgLength=0

	while [ ${keyIndex} -lt ${keyCount} ]
	do

		ldcDynaSetAt ${ldcsvn_readArrayName} ${ldcsvn_readArrayKeys[$keyIndex]} "${ldcstr_Exploded[${keyIndex}]}"
		[[ $? -eq 0 ]] ||
		{
			ldcConioDebug $LINENO "LogError" "Unable to add key '$key' to '${ldcsvn_readArrayName}'"
			return 2
		}
		
		msgLength+=${#ldcstr_Exploded[${keyIndex}]}
		msgLength+=1

		keyIndex+=1
	done
	
	local    msgBuffer
	printf -v msgBuffer "\n"

	[[ ${explodedCount} -gt ${keyCount} ]] &&
	 {
		let key=$keyCount-1

		ldcDynaGetAt "${ldcsvn_readArrayName}" "${ldcsvn_readArrayKeys[$key]}" msgBuffer
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "LogError" "ldcDynaGetAt failed."
			return 3
		 }

		msgBuffer="${msgBuffer}-${ldcsvn_readBuffer:$msgLength}"

		ldcDynaSetAt "${ldcsvn_readArrayName}" "${ldcsvn_readArrayKeys[$key]}" "${msgBuffer}"
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "LogError" "ldcDynaSetAt failed."
			return 4
		 }
	 }

	eval "${ldcsvn_processCallback}"
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
	[[ -z ${ldcsvn_readOpen} ]] &&   # never initialized, or eof
	 {
		ldcConioDebug $LINENO "LogError" "Log file is not open for reading!"
		return 1
	 }

	exec 3<"${ldcsvn_logName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "LogError" "Unable to open '${ldcsvn_logName}'"
		return 1
	 }

	while  read -u3 ldcsvn_readBuffer
	do
		eval ${ldcsvn_readCallback}
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "LogError" "readcallback failed on '${ldcsvn_readBuffer}'"
			return 2
		 }

	done

	ldcsvn_readOpen=0

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
	ldcsvn_readCallback="${1}"

	[[ -z "${ldcsvn_readCallback}" ]] &&
	{
		ldcConioDebug $LINENO "LogError" "Log read callback is empty"
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
	ldcsvn_processCallback="${1}"

	[[ -z "${ldcsvn_processCallback}" ]] &&
	{
		ldcConioDebug $LINENO "LogError" "Log read process callback is empty"
		return 1
	}

	return 0
}

# *****************************************************************************
#
#	svnReadldcLogClose
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
function svnReadldcLogClose()
{
	ldcsvn_readOpen=0
	ldcLogClose

	return 0
}

# *****************************************************************************
# *****************************************************************************
#
#			End
#
# *****************************************************************************
# *****************************************************************************

