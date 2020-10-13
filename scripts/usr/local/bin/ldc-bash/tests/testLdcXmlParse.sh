#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcXMLParse
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

declare    ldcapp_name="testLdcDynNode"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.1.2"					# script version

declare    ldcapp_errors="$ldcbase_dirEtc/errorCodes.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $ldcbase_dirLib/testDump.sh

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

	ldcDynaCount "$dataArray" fieldCount
	[[ $? -eq 0 ]] || return $?

	while [[ $key -lt ${fieldCount} ]]
	do
		ldcDynaGetAt "$dataArray" $key field
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

		echo ${ldcclr_Red}$msg${ldcclr_NoColor}
		(( key++ ))
	done

	echo ${ldcclr_NoColor}
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

	ldcXMLParseToArray ${query} "${name}" ${raw}
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		ldcConioDebug $LINENO "XmlError"  "ldcXMLParseToArray failed: ${query}"
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

	ldcXMLParseInit ${xmlName} ${xmlFile}
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		ldcConioDebug $LINENO "XmlError"  "ldcXMLParseInit failed: $?"
		return $testResult
	 }

	testProcessQueryToArray ${xpQuery} "${xmlName}" 0
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		ldcConioDebug $LINENO "XmlError"  "testProcessQueryToArray failed: ${query}"
		return $testResult
	 }

	testOutputArray "${xmlName}" 1
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		ldcConioDebug $LINENO "XmlError"  "testOutputArray failed: ${query}"
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

	ldcXMLParseToCmnd ${xpCCommand}
	[[ $? -eq 0 ]] ||
	 {
		testResult=$?
		ldcConioDebug $LINENO "XmlError"  "testParseCommand failed: ${xpCCommand}"
		return $testResult
	 }

	ldcConioDisplay "The set described by '${xpCCommand}' is: ${ldcxmp_CommandResult}"
	ldcConioDisplay ""
	ldcConioDisplay "*******************************************"

	return 0
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

#
#		ldcapp_errors tests
#
ldcConioDisplay ""
testParse "parseErrorCodes" "${ldcapp_errors}" "//ldc/ErrorMsgs/ErrorCode/@name"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParse failed"
 }

ldcConioDisplay "*******************************************"

#
#		help tests
#

testParse "help" "${ldcbase_dirEtc}/helpTest.xml" "//ldc/help/options/var/@name"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParse failed"
}

ldcConioDisplay "*******************************************"

testParseCommand "count(//ldc/help/labels/label)"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParseCommand failed"
 }

#
#		more ldcXMLParseInit
#

ldcXMLParseInit "errortest" "${ldcapp_errors}"
if [ $? -ne 0 ]
then
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "ldcXMLParseInit ${ldcapp_errors} failed: $?"
fi

xpCName="ldcStackWrite"
testParseCommand "string(//ldc/ErrorMsgs/ErrorCode[@name=\"${xpCName}\"]/message)"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParseCommand failed"
 }

ldcConioDisplay ""

xpCName="NSGenUid"
testParseCommand "string(//ldc/ErrorMsgs/ErrorCode[@name=\"${xpCName}\"]/message)"
[[ $? -eq 0 ]] ||
 {
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParseCommand failed"
 }

# *******************************************************

ldcXPathSelect "help"
if [ $? -ne 0 ]
then
	testResult=$?
	ldcConioDebugExit $LINENO "XPathError"  "ldcXPathSelect shellHelp.xml failed: $?"
fi

xpCName="fetch"
testParseCommand "string(//ldc/help/options/var[@name=\"${xpCName}\"]/use)"
if [ $? -ne 0 ]
then
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParseCommand shellHelp.xml failed: $?"
fi

xpCName="batch"
testParseCommand "string(//ldc/help/options/var[@name=\"${xpCName}\"]/use)"
if [ $? -ne 0 ]
then
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "testParseCommand shellHelp.xml failed: $?"
fi

# *******************************************************

ldcXPathSelect "ErrorCodes"
if [ $? -ne 0 ]
then
	testResult=$?
	ldcConioDebugExit $LINENO "XmlError"  "ldcXMLParseInit shellHelp.xml failed: $?"
fi

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
