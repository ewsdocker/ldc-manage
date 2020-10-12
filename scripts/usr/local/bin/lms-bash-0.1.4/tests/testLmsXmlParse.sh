#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsXMLParse
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage tests
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
#		Version 0.0.1 - 06-02-2016.
#				0.0.2 - 06-18-2016.
#				0.1.0 - 01-29-2017.
#				0.1.1 - 02-09-2017.
#				0.1.2 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsDynNode"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

declare    lmsscr_Version="0.1.2"					# script version

declare    lmsapp_errors="$lmsbase_dirEtc/errorCodes.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $lmsbase_dirLib/testDump.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# ***************************************************************
#
#	testOutputArray
#
#	Parameters:
#		name = array name
#		format = 0 to pirnt field as is, 1 to print as integer
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ***************************************************************
function testOutputArray()
{
	local dataArray=${1}
	local format=${2:-1}

	local -i key=0
	msg=""
	local field
	local -i number

	local fieldCount

	lmsDynaCount "$dataArray" fieldCount
	[[ $? -eq 0 ]] || return $?

	while [[ $key -lt ${fieldCount} ]]
	do
		lmsDynaGetAt "$dataArray" $key field
		[[ $? -eq 0 ]] || 
		 {
			testResult=$?
			return $?
		 }
	
		if [ $format -eq 1 ]
		then
			printf -v msg "   (% 3u) %s" $key $field
		else
			number=$field
			printf -v msg "   (% 3u) % 4u" $key $number
		fi

		echo ${lmsclr_Red}$msg${lmsclr_NoColor}
		(( key++ ))
	done

	echo ${lmsclr_NoColor}
}

# *******************************************************
#
#	testProcessQueryToArray
#
#	parameter:
#		query = query to execute
#		name = name of the global array to populate
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *******************************************************
function testProcessQueryToArray()
{
	local query=${1}
	local name="${2}"
	local raw=${3:-0}

	lmsXMLParseToArray ${query} "${name}" ${raw}
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		lmsConioDebug $LINENO "XmlError"  "lmsXMLParseToArray failed: ${query}"
		return $testResult
	 }

	return 0
}

# *******************************************************
#
#	testParse
#
#	parameter:
#		name = internal file name
#		query = query to execute
#		name = name of the global array to populate
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *******************************************************
function testParse()
{
	local xmlName=${1}
	local xmlFile=${2}
	local xpQuery=${3}

	local ec=0

	lmsXMLParseInit ${xmlName} ${xmlFile}
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		lmsConioDebug $LINENO "XmlError"  "lmsXMLParseInit failed: $?"
		return $testResult
	 }

	testProcessQueryToArray ${xpQuery} "${xmlName}" 0
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		lmsConioDebug $LINENO "XmlError"  "testProcessQueryToArray failed: ${query}"
		return $testResult
	 }

	testOutputArray "${xmlName}" 1
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		lmsConioDebug $LINENO "XmlError"  "testOutputArray failed: ${query}"
		return $testResult
	 }
}

# *******************************************************
#
#	testParseCommand
#
#	parameter:
#		command = command to execute
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *******************************************************
function testParseCommand()
{
	xpCCommand=${1}
	xpCResult=0

	lmsXMLParseToCmnd ${xpCCommand}
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		lmsConioDebug $LINENO "XmlError"  "testParseCommand failed: ${xpCCommand}"
		return $testResult
	 }

	lmsConioDisplay "The set described by '${xpCCommand}' is: ${lmsxmp_CommandResult}"
	lmsConioDisplay ""
	lmsConioDisplay "*******************************************"

	return 0
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

#
#		lmsapp_errors tests
#
lmsConioDisplay ""
testParse "parseErrorCodes" "${lmsapp_errors}" "//lms/ErrorMsgs/ErrorCode/@name"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParse failed"
 }

lmsConioDisplay "*******************************************"

#
#		help tests
#

testParse "help" "${lmsbase_dirEtc}/helpTest.xml" "//lms/help/options/var/@name"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParse failed"
}

lmsConioDisplay "*******************************************"

testParseCommand "count(//lms/help/labels/label)"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParseCommand failed"
 }

#
#		more lmsXMLParseInit
#

lmsXMLParseInit "errortest" "${lmsapp_errors}"
if [ $? -ne 0 ]
then
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "lmsXMLParseInit ${lmsapp_errors} failed: $?"
fi

xpCName="lmsStackWrite"
testParseCommand "string(//lms/ErrorMsgs/ErrorCode[@name=\"${xpCName}\"]/message)"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParseCommand failed"
 }

lmsConioDisplay ""

xpCName="NSGenUid"
testParseCommand "string(//lms/ErrorMsgs/ErrorCode[@name=\"${xpCName}\"]/message)"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParseCommand failed"
 }

# *******************************************************

lmsXPathSelect "help"
if [ $? -ne 0 ]
then
	testResult=$?
	lmsConioDebugExit $LINENO "XPathError"  "lmsXPathSelect shellHelp.xml failed: $?"
fi

xpCName="fetch"
testParseCommand "string(//lms/help/options/var[@name=\"${xpCName}\"]/use)"
if [ $? -ne 0 ]
then
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParseCommand shellHelp.xml failed: $?"
fi

xpCName="batch"
testParseCommand "string(//lms/help/options/var[@name=\"${xpCName}\"]/use)"
if [ $? -ne 0 ]
then
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "testParseCommand shellHelp.xml failed: $?"
fi

# *******************************************************

lmsXPathSelect "ErrorCodes"
if [ $? -ne 0 ]
then
	testResult=$?
	lmsConioDebugExit $LINENO "XmlError"  "lmsXMLParseInit shellHelp.xml failed: $?"
fi

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
