#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   	testLmsStack.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage tests
#
# ***************************************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# ***************************************************************************************************
#
#		Version 0.0.1 - 03-07-2016.
#				0.0.2 - 03-24-2016.
#				0.0.3 - 06-27-2016.
#				0.1.0 - 01-14-2017.
#				0.1.1 - 01-24-2017.
#				0.1.2 - 02-23-2017.
#
# ***************************************************************************************************
# ***************************************************************************************************

declare    lmsapp_name="testLmsStack"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh
. $lmsbase_dirLib/lmsDomTS.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.2"					# script version

declare    lmstst_stackName="lmstst_nameStack"
declare    lmstst_stackUid=""
declare    lmstst_lookupUid=""

declare    lmstst_stackBuffer=""
declare    lmstst_result=0
declare    lmstst_stackSize=0

declare -a lmstst_names=( global production configuration database )

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

# *****************************************************************************
#
#	testLmsStackCreate
#
#		Test the lmsStackCreate functionality
#
#	parameters:
#		sName = the name of the stack to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackCreate()
{
	local sName="${1}"
	
	lmsConioDisplay
	lmsConioDisplay "testLmsStackCreate '${sName}'"

	lmsStackCreate "${sName}" lmstst_stackUid
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackCreate - Unable to create a stack named '${lmstst_stackName}'"
		return 1
	 }

	lmstst_stackName=$sName
	lmsConioDisplay "testLmsStackCreate name = '${lmstst_stackName}', Uid = '${lmstst_stackUid}'"

	return 0
}

# *****************************************************************************
#
#	testLmsStackDestroy
#
#		Test the lmsStackDestroy functionality
#
#	parameters:
#		sName = the name of the stack to destroy
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackDestroy()
{
	local sName="${1}"
	
	lmsConioDisplay
	lmsConioDisplay "testLmsStackDestroy '${sName}'"

	lmsStackDestroy "${sName}" lmstst_stackUid
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackDestroy - Unable to create a stack named '${lmstst_stackName}'"
		return 1
	 }

	lmsConioDisplay "testLmsStackDestroy name = '${lmstst_stackName}' has been deleted."

	return 0
}

# *****************************************************************************
#
#	testLmsStackLookup
#
#		Test the lmsStackLookup functionality
#
#	parameters:
#		sName = the name of the stack to lookup
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackLookup()
{
	local sName="${1}"
	local tUid

	lmsConioDisplay
	lmsConioDisplay "testLmsStackLookup '${sName}'"

	lmsStackLookup "${sName}" tUid
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackLookup - Could not find the stack named '${lmstst_stackName}'"
		return 1
	 }

	lmstst_stackName=$sName
	lmsConioDisplay "testLmsStackLookup name = '${sName}', Uid = '${tUid}'"

	lmsDeclareStr ${2} "${tUid}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackToString - lmsDeclareStr failed."
		return 1
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsStackSize
#
# 		Get the size of a stack
#
#	parameters:
#		stackName = the name of the stack to use
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function testLmsStackSize()
{
	lmsConioDisplay
	lmsConioDisplay "testLmsStackSize '${1}'"

	local sName="${1}"

	lmsStackSize "${sName}" lmstst_stackSize
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackSize - Unable to get the stack size"
		return 1
	 }

	lmsConioDisplay "lmsStackSize = $lmstst_stackSize"
	return 0
}

# *****************************************************************************
#
#	testLmsStackWrite
#
#		Test the lmsStackWrite functionality
#
#	parameters:
#		sName = the name of the stack to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackWrite()
{
	local sName="${1}"
	lmstst_data="${2}"

	lmsConioDisplay
	lmsConioDisplay "testLmsStackWrite '${sName}', data = '${lmstst_data}'"

	lmsStackWrite "${sName}" "${lmstst_data}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackWrite - Unable to write test data to the stack"
		return 1
	 }

	return 0
}

# *****************************************************************************
#
#	testLmsStackRead
#
#		Test the lmsStackRead functionality
#
#	parameters:
#		sName = the name of the stack to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackRead()
{
	local sName="${1}"

	lmsConioDisplay
	lmsConioDisplay "testLmsStackRead '${sName}'"

	lmsStackRead "${sName}" lmstst_stackBuffer
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackRead - Unable to read test data from the stack"
		return 1
	 }

	return 0
}

# *****************************************************************************
#
#	testLmsStackReadQueue
#
#		Test the lmsStackReadQueue functionality
#
#	parameters:
#		sName = the name of the stack to create
#		readData = the location to store the read result
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackReadQueue()
{
	local sName="${1}"

	lmsConioDisplay
	lmsConioDisplay "testLmsStackReadQueue '${sName}'"

	lmstst_stackBuffer=""
	lmsStackReadQueue "${sName}" lmstst_stackBuffer
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackReadQueue - Unable to read test data from the queue"
		return 1
	 }

	lmsConioDisplay "$lmstst_stackBuffer"
	return 0
}

# *****************************************************************************
#
#	testLmsStackPeek
#
#		Test the stackPeah functionality
#
#	parameters:
#		sName = the name of the stac
#		sOffset = the stack offset
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackPeek()
{
	local sName="${1}"
	local sOffset=${2:-0}

	lmsConioDisplay
	lmsConioDisplay "testLmsStackPeek '${sName}' @ '${sOffset}'"

	lmstst_head=0
	lmsStackPeek "${sName}" lmstst_value $sOffset
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackPeek - failed for offset ${sOffset}"
		return 1
	 }

	lmsConioDisplay "testLmsStackPeek @ '${sOffset}' = '${lmstst_value}'"

	return 0
}

# *****************************************************************************
#
#	testLmsStackPeekQueue
#
#		Test the stackPeakQueue functionality
#
#	parameters:
#		sName = the name of the stac
#		sOffset = the stack offset
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackPeekQueue()
{
	local sName="${1}"
	local sOffset=${2:-0}

	lmsConioDisplay
	lmsConioDisplay "testLmsStackPeekQueue '${sName}' @ '${sOffset}'"

	lmstst_head=0
	lmsStackPeekQueue "${sName}" lmstst_result $sOffset
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackPeekQueue - failed for offset ${sOffset} (${lmstst_result})"
		return 1
	 }

	lmsConioDisplay "testLmsStackPeekQueue @ '${sOffset}' = '${lmstst_result}'"

	return 0
}

# *****************************************************************************
#
#	testLmsStackPointer
#
#		Test the stackTail functionality
#
#	parameters:
#		sName = the name of the stack to create
#		sOffset = the stack tail offset
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackPointer()
{
	local sName="${1}"
	local sOffset=${2:-0}

	lmsConioDisplay
	lmsConioDisplay "testLmsStackPointer '${sName}'"

	lmstst_head=0
	lmsStackPointer "${sName}" $sOffset lmstst_head
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackPointer - unable to compute the stack Pointer for offset ${sOffset}"
		return 1
	 }

	lmsConioDisplay "testLmsStackPointer with offset '${Offset}' = '${lmstst_head}'"

	return 0
}

# *****************************************************************************
#
#	testLmsStackPointerQueue
#
#		Test the lmsStackPointerQueue functionality
#
#	parameters:
#		sName = the name of the stack to create
#		qOffset = the stack queue offset
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackPointerQueue()
{
	local sName="${1}"
	local qOffset=${2:-0}

	lmsConioDisplay
	lmsConioDisplay "testLmsStackPointerQueue '${sName}'"

	lmstst_tail=0
	lmsStackPointerQueue "${sName}" $qOffset lmstst_tail
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackPointerQueue - unable to compute the queue pointer"
		return 1
	 }

	lmsConioDisplay "testLmsStackPointerQueue with offset '${qOffset}' = '${lmstst_tail}'"

	return 0
}

# *****************************************************************************
#
#	testLmsStackToString
#
#		Test the lmsStackToString functionality
#
#	parameters:
#		sName = the name of the stack to create
#		sType = the type of output 0 ==> unformatted, 1 ==> formatted
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsStackToString()
{
	local sName="${1}"
	local sStyle=${2:-0}
	
	lmsConioDisplay "testLmsStackToString '${sName}'"

	lmstst_stackBuffer=""
	lmsStackToString "${sName}" lmstst_stackBuffer ${sStype}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsStackToString - lmsStackToString failed."
		return 1
	 }

	lmsConioDisplay "testLmsStackToString:"
	lmsConioDisplay "    '$lmstst_stackBuffer'"
	return 0
}

# *****************************************************************************
#
#	testLmsEmptyQueue
#
#		Empty the queue structure by reading from the queue head
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsEmptyQueue()
{
	local readResult=""

	lmsStackSize ${sName} lmstst_stackSize
	while [ $lmstst_stackSize -gt 0 ]
	do
		lmsConioDisplay ""
		lmsConioDisplay "Queue size: $lmstst_stackSize"
		lmsConioDisplay "  Reading queue tail: "

		lmsStackReadQueue ${sName} lmstst_result
		if [ $? -ne 0 ]
		then
			if [ $? -eq 1 ]
			then
				lmsConioDisplay "unable to read the queue tail"
			else
				lmsConioDisplay "empty queue"
			fi

			break
		fi

		lmsConioDisplay "${lmstst_result}"

		lmsConioDisplay ""

		lmstst_stackBuffer=""
		lmsStackToString ${sName} lmstst_stackBuffer ${1:-0}
		lmsConioDisplay "  ${lmstst_stackBuffer}"

		let lmstst_stackSize-=1
	done
}

# *****************************************************************************
#
#	testLmsEmptyStack
#
#		Empty the stack by 'popping' the stack
#
#	parameters:
#		sName = the stack to pop
#		sType = 0=stack, 1=queue
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsEmptyStack()
{
	lmsConioDisplay
	lmsConioDisplay "lmsEmptyStack '${1}' '${2}'"
	
	local sName=${1}
	local sType=${2:-0}
	local lType="stack"
	local sBuffer=""

	[[ $sType -eq 0 ]] || lType="queue"

	testLmsStackSize ${sName}
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "The ${lType} '${sName}' is empty."
		return 0
	}

	while [[ $lmstst_stackSize -gt 0 ]]
	do
		lmsConioDisplay ""

		lmsConioDisplay "${sName} size: $lmstst_stackSize"
		lmsConioDisplay "  Popping stack: " -n

		if [[ ${sType} -eq 0 ]]
		then
			testLmsStackRead ${sName}
			lmstst_result=$?
		else
			testLmsStackReadQueue ${sName}
			lmstst_result=$?
		fi

		[[ $lmstst_result -eq 0 ]] ||
		 {
			[[ $lmstst_result -eq 1 ]] && lmsConioDisplay "unable to pop the stack" || lmsConioDisplay "empty stack"
			break
		 }

		lmsConioDisplay "Read result:"
		lmsConioDisplay "    '${lmstst_stackBuffer}'"

		lmsConioDisplay ""
		lBuffer=""

		testLmsStackToString ${sName} sBuffer ${1:-0}
		lmsConioDisplay "${sBuffer}"

		(( lmstst_stackSize-- ))
	done
	
	return 0
}

# *****************************************************************************
#
#	testLmsBuildStack
#
#		Add the contents of the test array to the test stack
#
#	parameters:
#		sName = name of the stack to test
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsBuildStack()
{
	local sName="${1}"

	local sData=""
	local lBuffer=""

	lmsConioDisplay
	lmsConioDisplay "testLmsBuildStack '${sName}'"

	for sData in "${lmstst_names[@]}"
	do
		lmsConioDisplay "Adding '$sData'"

		testLmsStackWrite "${sName}" "${sData}"
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDisplay "Unknown stack ${sName}"
			return 1
		 }

		lmsConioDisplay "   '$sData' added"
#		testLmsStackToString ${sName} 0

		lmsConioDisplay "-----------------------"
	done
	
	lmsConioDisplay "testLmsBuildStack:"
	testLmsStackToString ${sName} 0
	
	return $?
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main script below here
#
# *****************************************************************************
# *****************************************************************************

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests
#
# *****************************************************************************
# *****************************************************************************

lmscli_optDebug=0
lmscli_optLogDisplay=0

# *****************************************************************************

lmsConioDisplay "========================================================================"
lmsConioDisplay ""

testLmsStackCreate "${lmstst_stackName}" lmstst_stackUid
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "Unable to create a stack named '${lmstst_stackName}'"
	testDumpExit "lmsstk lmsstku"
 }

# *****************************************************************************

lmsConioDisplay "Lookup stack '${lmstst_stackName}' = ${lmstst_stackUid}"

testLmsStackLookup "$lmstst_stackName" lmstst_lookupUid
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "Unable to get just created uid for testStack (s.b. $lmstst_stackUid)"
	testDumpExit "lmsstk lmsstku"
 }

[[ "${lmstst_lookupUid}" == "${lmstst_stackUid}" ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "created uid ($lmstst_stackUid) not the same as lkpuid ($lmstst_lookupUid)"
	testDumpExit "lmsstk lmsstku"
 }

lmsConioDisplay ""
lmsConioDisplay "Created stack UID = $lmstst_lookupUid"

# *****************************************************************************
# *****************************************************************************
#
#		Queue tests
#
# *****************************************************************************
# *****************************************************************************

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "      Queue Tests"
lmsConioDisplay ""
lmsConioDisplay "========================================================================"
lmsConioDisplay ""

lmsConioDisplay "Writing to stack head in $lmstst_stackName ($lmstst_lookupUid)"
lmsConioDisplay ""

testLmsStackWrite "${lmstst_stackName}" "Writing message number 1"
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "Unable to write message to stack."
	testDumpExit "lmsstk lmsstku"
 }

# *****************************************************************************

lmsConioDisplay "========================================================================"
lmsConioDisplay ""

lmsConioDisplay "Getting stack size - s/b 1"

testLmsStackSize $lmstst_stackName
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "Unable to get stack size."
	testDumpExit "lmsstk lmsstku"
 }

[[ $lmstst_stackSize -eq 1 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "Stack size is '${lmstst_stackSize}', but should be '1'."
	testDumpExit "lmsstk lmsstku"
 }

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "Listing stack contents:"

lmstst_stackBuffer=""
testLmsStackToString $lmstst_stackName 0
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "lmsStackToString failed."
	testDumpExit "lmsstk lmsstku"
 }

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "Adding (pushing) to the stack $lmstst_stackName ($lmstst_lookupUid)"

testLmsBuildStack $lmstst_stackName 1

testLmsStackSize $lmstst_stackName

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "                   Queue operations on a stack"
lmsConioDisplay ""
lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "Getting queue pointer (with no offset)"

testLmsStackPointerQueue $lmstst_stackName 0
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "lmsStackPointerQueue with offset '0' failed."
	testDumpExit "lmsstk lmsstku"
 }

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "Getting queue pointer (with offset)"

testLmsStackPointerQueue $lmstst_stackName 3
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "lmsStackPointerQueue with offset '3' failed."
	testDumpExit "lmsstk lmsstku"
 }

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "Listing queue content"
lmsConioDisplay ""
lmsConioDisplay "========================================================================"

testLmsStackSize $lmstst_stackName
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "lmsStackSize failed."
	testDumpExit "lmsstk"
 }

lmstst_offset=0
while [[ ${lmstst_offset} -lt ${lmstst_stackSize} ]]
do
	testLmsStackPeekQueue $lmstst_stackName ${lmstst_offset}
	[[ $? -eq 0 ]] || break

	(( lmstst_offset++ ))
done

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "Listing stack content"
lmsConioDisplay ""
lmsConioDisplay "========================================================================"

testLmsStackToString $lmstst_stackName 0
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsConioDisplay "lmsStackToString failed."
	testDumpExit "lmsstk"
 }

lmsConioDisplay "========================================================================"

testLmsEmptyStack $lmstst_stackName 0

lmsConioDisplay "========================================================================"
lmsConioDisplay ""
lmsConioDisplay "      Queue Tests"
lmsConioDisplay ""
lmsConioDisplay "========================================================================"

testLmsBuildStack $lmstst_stackName

lmsConioDisplay ""
lmsConioDisplay "========================================================================"

testLmsEmptyStack $lmstst_stackName 1

lmsConioDisplay "========================================================================"

testLmsStackDestroy $lmstst_stackName

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
