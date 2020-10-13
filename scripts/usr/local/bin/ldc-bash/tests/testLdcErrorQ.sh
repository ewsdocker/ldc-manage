#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcErrorQ.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.4
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage tests
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
#			Version 0.0.1 - 03-25-2016.
#					0.1.0 - 01-12-2017.
#					0.1.1 - 01-24-2017.
#					0.1.2 - 02-09-2017.
#					0.1.3 - 02-23-2017.
#					0.1.4 - 09-06-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcErrorQ"
declare    ldclib_bashRelease="0.1.3"

# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh

source $ldcbase_dirAppLib/cliOptions.sh
source $ldcbase_dirAppLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.4"					# script version

declare    ldctst_stackName="errorQueueStack"

declare    ldcapp_declare="$ldcbase_dirEtc/cliOptions.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $ldcbase_dirTestLib/testDump.sh
source $ldcbase_dirTestLib/testUtilities.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *****************************************************************************
#
#	testLdcErrorQInit
#
#		Test the ldcErrorQInit functionality
#
#	parameters:
#		qName = the name of the queue to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQInit()
{
	local qName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQInit '${qName}'"

	ldcErrorQInit "${qName}"
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to create a queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	ldctst_stackName=$qName

	testHighlightMessage "name = '${ldctst_stackName}'"
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQWrite
#
#		Test the ldcErrorQWrite functionality
#
#	parameters:
#		qName = the name of the queue to create
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQWrite()
{
	local qName="${1}"
	
	local qLine=${2:-"0"}
	local qCode=${3:-"0"}
	local qMod=${4:-""}
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQWrite '${qName}' = '${qLine}' '${qCode}' '${qMod}'"

	ldcErrorQWrite ${qName} "${qLine}" "${qCode}" "${qMod}"
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to write to the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' was successful." 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQWriteX
#
#		Test the ldcErrorQWriteX functionality
#
#	parameters:
#		qName = the name of the queue to create
#		lineNo = line number
#		errorCode = error code
#		modifier = additional information to supplement the error message
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQWriteX()
{
	local qName="${1}"
	
	local qLine=${2:-"0"}
	local qCode=${3:-"0"}
	local qMod=${4:-""}
	
	ldcConioDisplay "testLdcErrorQWriteX '${qName}' = '${qLine}' '${qCode}' '${qMod}'"

	ldcErrorQWriteX $qName "${qLine}" "${qCode}" "${qMod}"
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to write to the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' was successful." 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQRead
#
#		Test the ldcErrorQRead functionality
#
#	parameters:
#		qName = the name of the queue to read
#		qData = location to place the read data
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQRead()
{
	local qName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQRead '${qName}'"

	ldcErrorQRead "${qName}" ldctst_buffer
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to read from the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' = '${ldctst_buffer}'" 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQErrors
#
#		Test the ldcErrorQErrors functionality
#
#	parameters:
#		qName = the name of the queue to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQErrors()
{
	local qName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQErrors '${qName}'"

	ldcErrorQErrors $qName ldctst_stackSize
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to get the count of errors in the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' = '${ldctst_stackSize}'" 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQPeek
#
#		Test the ldcErrorQPeek functionality
#
#	parameters:
#		qName = the name of the queue to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQPeek()
{
	local qName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQPeek '${qName}'"

	ldcErrorQPeek $qName ldctst_buffer
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to peek at the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' = '${ldctst_buffer}'" 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQParse
#
#		Test the ldcErrorQParse functionality
#
#	Parameters:
#		qName = name of the error queue
#		qData = data to be parsed
#		qBuffer = queue return buffer
#		qSep = (optional) field separator, default = " "
#
#	Returns:
#		0 = no error, data returned in buffer and errQVar variables
#		1 = no error queue exists
#		2 = queue is empty
#
# *****************************************************************************
testLdcErrorQParse()
{
	local qName="${1}"
	local qData="${2}"
	local qSep=${4}
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQRead '${qName}'"

	ldcErrorQParse "${qName}" "${qData}" ${3} "${qSep}"
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Parse queue message faile for the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	return 0
}

# *****************************************************************************
#
#	testLdcErrorQGetError
#
#		Test the ldcErrorQGetError functionality
#
#	Parameters:
#		qName = name of the error queue
#		message = location to store the printable message
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcErrorQGetError()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	
	return 1
}

# *****************************************************************************
#
#	testLdcErrorQResetV
#
#		Test the ldcErrorQResetV functionality
#
#	Parameters:
#		qName = the name of the error queue
#
#	Returns:
#		0 = no error
#
# *****************************************************************************
function testLdcErrorQResetV()
{
	[[ -z "${1}" ]] && return 1
	local qName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQResetV '${qName}'"

	ldcErrorQResetV "${qName}"
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Unable to reset the error queue variables, result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' was successful" 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQExists
#
#		Test the ldcErrorQExists functionality
#
#	Parameters:
#		qName = the name of the error queue
#
#	Returns:
#		0 = exists
#		non-zero = doesn't exist
#
# *****************************************************************************
function testLdcErrorQExists()
{
	[[ -z "${1}" ]] && return 1
	local qName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQExists '${qName}'"

	ldcErrorQExists "${qName}"
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "Did not find the queue named '${qName}', result = $ldctst_result"
		return 1
	 }

	testHighlightMessage "'${qName}' was successful" 1
	return 0
}

# *****************************************************************************
#
#	testLdcErrorQReset
#
#		Test the ldcErrorQReset functionality
#
#	Parameters:
#		qName = the name of the error queue
#
#	Returns:
#		0 = no error
#
# *****************************************************************************
function testLdcErrorQReset()
{
	[[ -z "${1}" ]] && return 1
	local qName=${1}
	
	ldcConioDisplay
	ldcConioDisplay "testLdcErrorQReset '${qName}'"

	ldcErrorQReset ${1}
	return 0
}

# *****************************************************************************
#
#	testldcErrorQDispPeek
#
#		Test the ldcErrorQDispPeek functionality
#
#	parameters:
#		qName = the name of the queue to display
#		qDetail = amount of detail (0 or 1)
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testldcErrorQDispPeek()
{
	ldcConioDisplay
	ldcConioDisplay "testldcErrorQDispPeek '${1}' '${2}'"

	local qName="${1}"
	local qDetail=${2:-"1"}

	ldcErrorQDispPeek "${qName}" ${qDetail}
	[[ $? -eq 0 ]] ||
	 {
		ldctst_result=$?
		ldcConioDisplay "testErrQDisplay qName = '${ldcerr_QName}'"
		return 1
	 }

	ldcConioDisplay ""
	return 0
}

# *****************************************************************************
#
#	testldcErrorQDispPop
#
#		Test the ldcErrorQDispPop functionality
#
#	parameters:
#		qName = the name of the queue to display
#		qDetail = amount of detail (0 or 1)
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testldcErrorQDispPop()
{
	ldcConioDisplay
	ldcConioDisplay "testldcErrorQDispPop '${1}' '${2}'"

	local qName="${1}"
	local qDetail=${2:-"1"}

	ldcErrorQDispPop "${qName}" ${qDetail}

	ldcConioDisplay ""
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

ldccli_optQueueErrors=0
ldccli_optLogDisplay=0
ldccli_optDebug=0
ldccli_optSilent=0
ldccli_optQuiet=0

ldcConioDisplay "*******************************************************"

testLdcErrorQInit $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to initialize error queue. (${ldctst_result})"
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQErrors $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to get error queue size."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQWrite $ldcerr_QName $LINENO 'Debug' "QMessage 0"
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to write to error queue."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQWrite $ldcerr_QName $LINENO 'Debug' "QMessage 1"
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to write to error queue."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQPeek $ldcerr_QName ldctst_data 0
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to peek."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQErrors $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to get error queue size."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "Error STACK contains $ldctst_stackSize elements"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testldcErrorQDispPeek $ldcerr_QName 0
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to get error queue size."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testldcErrorQDispPeek $ldcerr_QName 1
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to get error queue size."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQRead $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Cannot read error stack - invalid error queue"
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQErrors $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Cannot get error count - invalid error queue"
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay "Error QUEUE contains $ldctst_stackSize elements"
ldcConioDisplay ""

ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

testldcErrorQDispPop $ldcerr_QName 0
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Peek error."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQErrors $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Cannot get error count - invalid error queue"
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay "Error QUEUE contains $ldctst_stackSize elements"
ldcConioDisplay ""

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQReset $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Queue reset failed."
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

testLdcErrorQErrors  $ldcerr_QName
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Cannot get error count - invalid error queue"
	testDumpExit "${ldcerr_QName} ldcerr_ ldcstk"
 }

ldcConioDisplay "Error QUEUE contains $ldctst_stackSize elements"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"

# *****************************************************************************

. $ldcbase_dirAppLib/scriptEnd.sh

# *****************************************************************************


