#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLmsConio.sh
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
#			Version 0.0.1 - 01-29-2017.
#					0.0.2 - 02-23-2017.
#					0.0.3 - 09-05-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsConio"

# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh

source $lmsbase_dirAppLib/cliOptions.sh
source $lmsbase_dirAppLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.3"						# script version

declare    lmsapp_declare="${lmsbase_dirEtc}/testDeclarations.xml"  # script declarations

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $lmsbase_dirTestLib/testDump.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *********************************************************************************
#
#    testLmsConioDisplay
#
#      print message, if allowed
#
#	parameters:
#		message = a string to be printed
#		noEnter = if present, no end-of-line will be output
#
# *********************************************************************************
function testLmsConioDisplay()
{
	local message="${1}"
	
	echo "testLmsConioDisplay '${message}'"
	echo "----------------"

	lmsConioDisplay "${message}" ${2}
	[[ $? -eq 0 ]] ||
	{
		lmstst_result=$?
		return 1
	}

	return 0
}

# **************************************************************************
#
#    testLmsConioDebug
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
function testLmsConioDebug()
{
	local errorLine="${1}"
	local errorCode="${2}"
	local errorMod="${3}"

	echo "testLmsConioDebug: '${errorLine}' '${errorCode}' '${errorMod}'"
	echo "--------------"

	lmstst_result=0
	lmsConioDebug "${errorLine}" "${errorCode}" "${errorMod}"
	[[ $? -eq 0 ]] || 
	{
		lmstst_result=$?
		return 1
	}

	return 0
}

# **************************************************************************
#
#    testLmsConioDebugExit
#
#      print debug message, if allowed
#
#	parameters:
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#		lmsDmpVar = non-zero to print ALL bash variables and their values
#
#	Returns:
#		DOES NOT RETURN
#
# **************************************************************************
function testLmsConioDebugExit()
{
	local errorLine={$1}
	local errorCode=${2}
	local errorMod="${3}"
	local errorDump=${4:-0}
	
	echo "testLmsConioDebugExit: '${errorLine}' '${errorCode}' '${errorMod}' '${errorDump}'"
	echo "------------------"

	lmstst_result=0
	lmsConioDebugExit ${errorLine} ${errorCode} "${errorMod}"
}

# **************************************************************************
#
#    testLmsConioDisplayTrimmed
#
#		lmsStrTrim leading and trailing blanks and display
#
#	parameters:
#		string = the string to lmsStrTrim
#		name = the display name of the string
#	returns:
#		places the result in the global variable: lmsstr_Trimmed
#
# **************************************************************************
function testLmsConioDisplayTrimmed()
{
	echo "testLmsConioDisplayTrimmed: '${1}' '${2}'"
	echo "-----------------------"

	lmstst_result=0
	lmsConioDisplayTrimmed "${1}" "${2}"
	[[ $? -eq 0 ]] ||
	{
		lmstst_result=$?
		return 1
	}

	return 0
}

# **************************************************************************
#
#    testLmsConioPrompt
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
function testLmsConioPrompt()
{
	echo "testLmsConioPrompt: '${1}' '${2}'"
	echo "---------------"

	lmsConioPrompt "${1}" ${2}
	[[ $? -eq 0 ]] ||
	{
		lmstst_error=$?
		return 1
	}

	echo "Input: '${REPLY}'"
	return 0
}

# **************************************************************************
#
#    testLmsConioPromptReply
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
function testLmsConioPromptReply()
{
	echo "testLmsConioPromptReply: '${1}' '${2}'"
	echo "--------------------"

	lmsConioPromptReply "${1}" lmstst_reply ${2}
	[[ $? -eq 0 ]] ||
	 {
		lmstst_error=$?
		return 1
	 }

	echo "Reply: '${lmstst_reply}'"

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

source $lmsbase_dirAppLib/openLog.sh
source $lmsbase_dirAppLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

echo "setting optSilent = 1"
lmscli_optSilent=1

testLmsConioDisplay "Starting conio tests. - only happens when not silent"
echo ""

# *****************************************************************************

echo "setting optSilent = 0"
lmscli_optSilent=0

testLmsConioDisplay "Starting conio tests. - only happens when not silent"
echo ""

# *****************************************************************************

testLmsConioDebug $LINENO "Debug" "Debug output test - only happens when debug option set"
echo ""

# *****************************************************************************

lmscli_optDebug=1

testLmsConioDebug $LINENO "Debug" "Debug output test - only happens when debug option set"
echo ""

# *****************************************************************************

testLmsConioDisplayTrimmed "         string to     be    trimmed       " "TestString" 
echo ""

# *****************************************************************************

testLmsConioPrompt "Enter a resonse to display"
echo ""

# *****************************************************************************

testLmsConioPromptReply "Enter a resonse to display"
echo ""

# *****************************************************************************

source $lmsbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
