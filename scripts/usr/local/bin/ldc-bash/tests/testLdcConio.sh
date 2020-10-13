#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLdcConio.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage tests
#
# *****************************************************************************
#
#	Copyright © 2017, 2018. EarthWalk Software
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
#			Version 0.0.1 - 01-29-2017.
#					0.0.2 - 02-23-2017.
#					0.0.3 - 09-05-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcConio"

# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh

source $ldcbase_dirAppLib/cliOptions.sh
source $ldcbase_dirAppLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.3"						# script version

declare    ldcapp_declare="${ldcbase_dirEtc}/testDeclarations.xml"  # script declarations

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $ldcbase_dirTestLib/testDump.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *********************************************************************************
#
#    testLdcConioDisplay
#
#      print message, if allowed
#
#	parameters:
#		message = a string to be printed
#		noEnter = if present, no end-of-line will be output
#
# *********************************************************************************
function testLdcConioDisplay()
{
	local message="${1}"
	
	echo "testLdcConioDisplay '${message}'"
	echo "----------------"

	ldcConioDisplay "${message}" ${2}
	[[ $? -eq 0 ]] ||
	{
		ldctst_result=$?
		return 1
	}

	return 0
}

# **************************************************************************
#
#    testLdcConioDebug
#
#      print debug message, if allowed
#
#	parameters:
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	Returns
#		0 = no error
#		1 = error
#
# **************************************************************************
function testLdcConioDebug()
{
	local errorLine="${1}"
	local errorCode="${2}"
	local errorMod="${3}"

	echo "testLdcConioDebug: '${errorLine}' '${errorCode}' '${errorMod}'"
	echo "--------------"

	ldctst_result=0
	ldcConioDebug "${errorLine}" "${errorCode}" "${errorMod}"
	[[ $? -eq 0 ]] || 
	{
		ldctst_result=$?
		return 1
	}

	return 0
}

# **************************************************************************
#
#    testLdcConioDebugExit
#
#      print debug message, if allowed
#
#	parameters:
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#		ldcDmpVar = non-zero to print ALL bash variables and their values
#
#	Returns:
#		DOES NOT RETURN
#
# **************************************************************************
function testLdcConioDebugExit()
{
	local errorLine={$1}
	local errorCode=${2}
	local errorMod="${3}"
	local errorDump=${4:-0}
	
	echo "testLdcConioDebugExit: '${errorLine}' '${errorCode}' '${errorMod}' '${errorDump}'"
	echo "------------------"

	ldctst_result=0
	ldcConioDebugExit ${errorLine} ${errorCode} "${errorMod}"
}

# **************************************************************************
#
#    testLdcConioDisplayTrimmed
#
#		ldcStrTrim leading and trailing blanks and display
#
#	parameters:
#		string = the string to ldcStrTrim
#		name = the display name of the string
#	returns:
#		places the result in the global variable: ldcstr_Trimmed
#
# **************************************************************************
function testLdcConioDisplayTrimmed()
{
	echo "testLdcConioDisplayTrimmed: '${1}' '${2}'"
	echo "-----------------------"

	ldctst_result=0
	ldcConioDisplayTrimmed "${1}" "${2}"
	[[ $? -eq 0 ]] ||
	{
		ldctst_result=$?
		return 1
	}

	return 0
}

# **************************************************************************
#
#    testLdcConioPrompt
#
#		Output a prompt for input and return it
#
#	parameters:
#		prompt = the message to print
#		noEcho = do not echo the input as it is typed
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function testLdcConioPrompt()
{
	echo "testLdcConioPrompt: '${1}' '${2}'"
	echo "---------------"

	ldcConioPrompt "${1}" ${2}
	[[ $? -eq 0 ]] ||
	{
		ldctst_error=$?
		return 1
	}

	echo "Input: '${REPLY}'"
	return 0
}

# **************************************************************************
#
#    testLdcConioPromptReply
#
#		Output a prompt for input and return in specified global variable
#
#	parameters:
#		prompt = the message to print
#		reply = the input from the console
#		noEcho = do not echo the input as it is typed
#
#	returns:
#		0 = no error
#		non-zero = error number
#
# **************************************************************************
function testLdcConioPromptReply()
{
	echo "testLdcConioPromptReply: '${1}' '${2}'"
	echo "--------------------"

	ldcConioPromptReply "${1}" ldctst_reply ${2}
	[[ $? -eq 0 ]] ||
	 {
		ldctst_error=$?
		return 1
	 }

	echo "Reply: '${ldctst_reply}'"

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

source $ldcbase_dirAppLib/openLog.sh
source $ldcbase_dirAppLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

echo "setting optSilent = 1"
ldccli_optSilent=1

testLdcConioDisplay "Starting conio tests. - only happens when not silent"
echo ""

# *****************************************************************************

echo "setting optSilent = 0"
ldccli_optSilent=0

testLdcConioDisplay "Starting conio tests. - only happens when not silent"
echo ""

# *****************************************************************************

testLdcConioDebug $LINENO "Debug" "Debug output test - only happens when debug option set"
echo ""

# *****************************************************************************

ldccli_optDebug=1

testLdcConioDebug $LINENO "Debug" "Debug output test - only happens when debug option set"
echo ""

# *****************************************************************************

testLdcConioDisplayTrimmed "         string to     be    trimmed       " "TestString" 
echo ""

# *****************************************************************************

testLdcConioPrompt "Enter a resonse to display"
echo ""

# *****************************************************************************

testLdcConioPromptReply "Enter a resonse to display"
echo ""

# *****************************************************************************

source $ldcbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
