#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   	testLdcStack.sh
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

declare    ldcapp_name="testLdcStack"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh
. $ldcbase_dirLib/ldcDomTS.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.2"					# script version

declare    ldctst_stackName="ldctst_nameStack"
declare    ldctst_stackUid=""
declare    ldctst_lookupUid=""

declare    ldctst_stackBuffer=""
declare    ldctst_result=0
declare    ldctst_stackSize=0

declare -a ldctst_names=( global production configuration database )

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

# *****************************************************************************
#
#	testLdcStackCreate
#
#		Test the ldcStackCreate functionality
#
#	parameters:
#		sName = the name of the stack to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcStackCreate()
{
	local sName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcStackCreate '${sName}'"

	ldcStackCreate "${sName}" ldctst_stackUid
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackCreate - Unable to create a stack named '${ldctst_stackName}'"
		return 1
	 }

	ldctst_stackName=$sName
	ldcConioDisplay "testLdcStackCreate name = '${ldctst_stackName}', Uid = '${ldctst_stackUid}'"

	return 0
}

# *****************************************************************************
#
#	testLdcStackDestroy
#
#		Test the ldcStackDestroy functionality
#
#	parameters:
#		sName = the name of the stack to destroy
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcStackDestroy()
{
	local sName="${1}"
	
	ldcConioDisplay
	ldcConioDisplay "testLdcStackDestroy '${sName}'"

	ldcStackDestroy "${sName}" ldctst_stackUid
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackDestroy - Unable to create a stack named '${ldctst_stackName}'"
		return 1
	 }

	ldcConioDisplay "testLdcStackDestroy name = '${ldctst_stackName}' has been deleted."

	return 0
}

# *****************************************************************************
#
#	testLdcStackLookup
#
#		Test the ldcStackLookup functionality
#
#	parameters:
#		sName = the name of the stack to lookup
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcStackLookup()
{
	local sName="${1}"
	local tUid

	ldcConioDisplay
	ldcConioDisplay "testLdcStackLookup '${sName}'"

	ldcStackLookup "${sName}" tUid
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackLookup - Could not find the stack named '${ldctst_stackName}'"
		return 1
	 }

	ldctst_stackName=$sName
	ldcConioDisplay "testLdcStackLookup name = '${sName}', Uid = '${tUid}'"

	ldcDeclareStr ${2} "${tUid}"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackToString - ldcDeclareStr failed."
		return 1
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcStackSize
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
function testLdcStackSize()
{
	ldcConioDisplay
	ldcConioDisplay "testLdcStackSize '${1}'"

	local sName="${1}"

	ldcStackSize "${sName}" ldctst_stackSize
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackSize - Unable to get the stack size"
		return 1
	 }

	ldcConioDisplay "ldcStackSize = $ldctst_stackSize"
	return 0
}

# *****************************************************************************
#
#	testLdcStackWrite
#
#		Test the ldcStackWrite functionality
#
#	parameters:
#		sName = the name of the stack to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcStackWrite()
{
	local sName="${1}"
	ldctst_data="${2}"

	ldcConioDisplay
	ldcConioDisplay "testLdcStackWrite '${sName}', data = '${ldctst_data}'"

	ldcStackWrite "${sName}" "${ldctst_data}"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackWrite - Unable to write test data to the stack"
		return 1
	 }

	return 0
}

# *****************************************************************************
#
#	testLdcStackRead
#
#		Test the ldcStackRead functionality
#
#	parameters:
#		sName = the name of the stack to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcStackRead()
{
	local sName="${1}"

	ldcConioDisplay
	ldcConioDisplay "testLdcStackRead '${sName}'"

	ldcStackRead "${sName}" ldctst_stackBuffer
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackRead - Unable to read test data from the stack"
		return 1
	 }

	return 0
}

# *****************************************************************************
#
#	testLdcStackReadQueue
#
#		Test the ldcStackReadQueue functionality
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
function testLdcStackReadQueue()
{
	local sName="${1}"

	ldcConioDisplay
	ldcConioDisplay "testLdcStackReadQueue '${sName}'"

	ldctst_stackBuffer=""
	ldcStackReadQueue "${sName}" ldctst_stackBuffer
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackReadQueue - Unable to read test data from the queue"
		return 1
	 }

	ldcConioDisplay "$ldctst_stackBuffer"
	return 0
}

# *****************************************************************************
#
#	testLdcStackPeek
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
function testLdcStackPeek()
{
	local sName="${1}"
	local sOffset=${2:-0}

	ldcConioDisplay
	ldcConioDisplay "testLdcStackPeek '${sName}' @ '${sOffset}'"

	ldctst_head=0
	ldcStackPeek "${sName}" ldctst_value $sOffset
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackPeek - failed for offset ${sOffset}"
		return 1
	 }

	ldcConioDisplay "testLdcStackPeek @ '${sOffset}' = '${ldctst_value}'"

	return 0
}

# *****************************************************************************
#
#	testLdcStackPeekQueue
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
function testLdcStackPeekQueue()
{
	local sName="${1}"
	local sOffset=${2:-0}

	ldcConioDisplay
	ldcConioDisplay "testLdcStackPeekQueue '${sName}' @ '${sOffset}'"

	ldctst_head=0
	ldcStackPeekQueue "${sName}" ldctst_result $sOffset
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackPeekQueue - failed for offset ${sOffset} (${ldctst_result})"
		return 1
	 }

	ldcConioDisplay "testLdcStackPeekQueue @ '${sOffset}' = '${ldctst_result}'"

	return 0
}

# *****************************************************************************
#
#	testLdcStackPointer
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
function testLdcStackPointer()
{
	local sName="${1}"
	local sOffset=${2:-0}

	ldcConioDisplay
	ldcConioDisplay "testLdcStackPointer '${sName}'"

	ldctst_head=0
	ldcStackPointer "${sName}" $sOffset ldctst_head
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackPointer - unable to compute the stack Pointer for offset ${sOffset}"
		return 1
	 }

	ldcConioDisplay "testLdcStackPointer with offset '${Offset}' = '${ldctst_head}'"

	return 0
}

# *****************************************************************************
#
#	testLdcStackPointerQueue
#
#		Test the ldcStackPointerQueue functionality
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
function testLdcStackPointerQueue()
{
	local sName="${1}"
	local qOffset=${2:-0}

	ldcConioDisplay
	ldcConioDisplay "testLdcStackPointerQueue '${sName}'"

	ldctst_tail=0
	ldcStackPointerQueue "${sName}" $qOffset ldctst_tail
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackPointerQueue - unable to compute the queue pointer"
		return 1
	 }

	ldcConioDisplay "testLdcStackPointerQueue with offset '${qOffset}' = '${ldctst_tail}'"

	return 0
}

# *****************************************************************************
#
#	testLdcStackToString
#
#		Test the ldcStackToString functionality
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
function testLdcStackToString()
{
	local sName="${1}"
	local sStyle=${2:-0}
	
	ldcConioDisplay "testLdcStackToString '${sName}'"

	ldctst_stackBuffer=""
	ldcStackToString "${sName}" ldctst_stackBuffer ${sStype}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcStackToString - ldcStackToString failed."
		return 1
	 }

	ldcConioDisplay "testLdcStackToString:"
	ldcConioDisplay "    '$ldctst_stackBuffer'"
	return 0
}

# *****************************************************************************
#
#	testLdcEmptyQueue
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
function testLdcEmptyQueue()
{
	local readResult=""

	ldcStackSize ${sName} ldctst_stackSize
	while [ $ldctst_stackSize -gt 0 ]
	do
		ldcConioDisplay ""
		ldcConioDisplay "Queue size: $ldctst_stackSize"
		ldcConioDisplay "  Reading queue tail: "

		ldcStackReadQueue ${sName} ldctst_result
		if [ $? -ne 0 ]
		then
			if [ $? -eq 1 ]
			then
				ldcConioDisplay "unable to read the queue tail"
			else
				ldcConioDisplay "empty queue"
			fi

			break
		fi

		ldcConioDisplay "${ldctst_result}"

		ldcConioDisplay ""

		ldctst_stackBuffer=""
		ldcStackToString ${sName} ldctst_stackBuffer ${1:-0}
		ldcConioDisplay "  ${ldctst_stackBuffer}"

		let ldctst_stackSize-=1
	done
}

# *****************************************************************************
#
#	testLdcEmptyStack
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
function testLdcEmptyStack()
{
	ldcConioDisplay
	ldcConioDisplay "ldcEmptyStack '${1}' '${2}'"
	
	local sName=${1}
	local sType=${2:-0}
	local lType="stack"
	local sBuffer=""

	[[ $sType -eq 0 ]] || lType="queue"

	testLdcStackSize ${sName}
	[[ $? -eq 0 ]] ||
	{
		ldcConioDisplay "The ${lType} '${sName}' is empty."
		return 0
	}

	while [[ $ldctst_stackSize -gt 0 ]]
	do
		ldcConioDisplay ""

		ldcConioDisplay "${sName} size: $ldctst_stackSize"
		ldcConioDisplay "  Popping stack: " -n

		if [[ ${sType} -eq 0 ]]
		then
			testLdcStackRead ${sName}
			ldctst_result=$?
		else
			testLdcStackReadQueue ${sName}
			ldctst_result=$?
		fi

		[[ $ldctst_result -eq 0 ]] ||
		 {
			[[ $ldctst_result -eq 1 ]] && ldcConioDisplay "unable to pop the stack" || ldcConioDisplay "empty stack"
			break
		 }

		ldcConioDisplay "Read result:"
		ldcConioDisplay "    '${ldctst_stackBuffer}'"

		ldcConioDisplay ""
		lBuffer=""

		testLdcStackToString ${sName} sBuffer ${1:-0}
		ldcConioDisplay "${sBuffer}"

		(( ldctst_stackSize-- ))
	done
	
	return 0
}

# *****************************************************************************
#
#	testLdcBuildStack
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
function testLdcBuildStack()
{
	local sName="${1}"

	local sData=""
	local lBuffer=""

	ldcConioDisplay
	ldcConioDisplay "testLdcBuildStack '${sName}'"

	for sData in "${ldctst_names[@]}"
	do
		ldcConioDisplay "Adding '$sData'"

		testLdcStackWrite "${sName}" "${sData}"
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDisplay "Unknown stack ${sName}"
			return 1
		 }

		ldcConioDisplay "   '$sData' added"
#		testLdcStackToString ${sName} 0

		ldcConioDisplay "-----------------------"
	done
	
	ldcConioDisplay "testLdcBuildStack:"
	testLdcStackToString ${sName} 0
	
	return $?
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main script below here
#
# *****************************************************************************
# *****************************************************************************

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests
#
# *****************************************************************************
# *****************************************************************************

ldccli_optDebug=0
ldccli_optLogDisplay=0

# *****************************************************************************

ldcConioDisplay "========================================================================"
ldcConioDisplay ""

testLdcStackCreate "${ldctst_stackName}" ldctst_stackUid
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "Unable to create a stack named '${ldctst_stackName}'"
	testDumpExit "ldcstk ldcstku"
 }

# *****************************************************************************

ldcConioDisplay "Lookup stack '${ldctst_stackName}' = ${ldctst_stackUid}"

testLdcStackLookup "$ldctst_stackName" ldctst_lookupUid
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "Unable to get just created uid for testStack (s.b. $ldctst_stackUid)"
	testDumpExit "ldcstk ldcstku"
 }

[[ "${ldctst_lookupUid}" == "${ldctst_stackUid}" ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "created uid ($ldctst_stackUid) not the same as lkpuid ($ldctst_lookupUid)"
	testDumpExit "ldcstk ldcstku"
 }

ldcConioDisplay ""
ldcConioDisplay "Created stack UID = $ldctst_lookupUid"

# *****************************************************************************
# *****************************************************************************
#
#		Queue tests
#
# *****************************************************************************
# *****************************************************************************

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "      Queue Tests"
ldcConioDisplay ""
ldcConioDisplay "========================================================================"
ldcConioDisplay ""

ldcConioDisplay "Writing to stack head in $ldctst_stackName ($ldctst_lookupUid)"
ldcConioDisplay ""

testLdcStackWrite "${ldctst_stackName}" "Writing message number 1"
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "Unable to write message to stack."
	testDumpExit "ldcstk ldcstku"
 }

# *****************************************************************************

ldcConioDisplay "========================================================================"
ldcConioDisplay ""

ldcConioDisplay "Getting stack size - s/b 1"

testLdcStackSize $ldctst_stackName
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "Unable to get stack size."
	testDumpExit "ldcstk ldcstku"
 }

[[ $ldctst_stackSize -eq 1 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "Stack size is '${ldctst_stackSize}', but should be '1'."
	testDumpExit "ldcstk ldcstku"
 }

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "Listing stack contents:"

ldctst_stackBuffer=""
testLdcStackToString $ldctst_stackName 0
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "ldcStackToString failed."
	testDumpExit "ldcstk ldcstku"
 }

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "Adding (pushing) to the stack $ldctst_stackName ($ldctst_lookupUid)"

testLdcBuildStack $ldctst_stackName 1

testLdcStackSize $ldctst_stackName

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "                   Queue operations on a stack"
ldcConioDisplay ""
ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "Getting queue pointer (with no offset)"

testLdcStackPointerQueue $ldctst_stackName 0
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "ldcStackPointerQueue with offset '0' failed."
	testDumpExit "ldcstk ldcstku"
 }

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "Getting queue pointer (with offset)"

testLdcStackPointerQueue $ldctst_stackName 3
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "ldcStackPointerQueue with offset '3' failed."
	testDumpExit "ldcstk ldcstku"
 }

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "Listing queue content"
ldcConioDisplay ""
ldcConioDisplay "========================================================================"

testLdcStackSize $ldctst_stackName
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "ldcStackSize failed."
	testDumpExit "ldcstk"
 }

ldctst_offset=0
while [[ ${ldctst_offset} -lt ${ldctst_stackSize} ]]
do
	testLdcStackPeekQueue $ldctst_stackName ${ldctst_offset}
	[[ $? -eq 0 ]] || break

	(( ldctst_offset++ ))
done

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "Listing stack content"
ldcConioDisplay ""
ldcConioDisplay "========================================================================"

testLdcStackToString $ldctst_stackName 0
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcConioDisplay "ldcStackToString failed."
	testDumpExit "ldcstk"
 }

ldcConioDisplay "========================================================================"

testLdcEmptyStack $ldctst_stackName 0

ldcConioDisplay "========================================================================"
ldcConioDisplay ""
ldcConioDisplay "      Queue Tests"
ldcConioDisplay ""
ldcConioDisplay "========================================================================"

testLdcBuildStack $ldctst_stackName

ldcConioDisplay ""
ldcConioDisplay "========================================================================"

testLdcEmptyStack $ldctst_stackName 1

ldcConioDisplay "========================================================================"

testLdcStackDestroy $ldctst_stackName

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
