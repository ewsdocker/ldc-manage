#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcSortArray.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1
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
#			Version 0.0.1 - 03-14-2016.
#					0.1.0 - 01-30-2017.
#					0.1.1 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcSortArray"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh
. $ldcbase_dirLib/ldcSortArray.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.1"			# script version

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
#	testSortedList
#
# *****************************************************************************
testSortedList()
{
	ldcConioDisplay ""
	ldcConioDisplay "testSortedList: ${1}"

	local    valueList="${1}"

	local -i key=0
	local    msg=""
	local    field=""

	for field in ${valueList}
	do
		printf -v msg "   (% 3u) %s" $key "$field"
		ldcConioDisplay "$msg"

		(( key++ ))
	done
}

# *****************************************************************************
#
#	testBubbleSort
#
#	parameters:
#		sortList = list of values to be sorted
#		sortedList = location to place the sorted values
#
#	return:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function testBubbleSort()
{
	ldcConioDisplay ""
	ldcConioDisplay "testBubbleSort: ${1}"

	ldcsrt_array=()

	local -a sortArray=( ${1} )
	ldcSortArrayBubble $( echo "${sortArray[@]}" | sed 's/\</ /g' )
	
	ldcsrt_sortedList="${ldcsrt_array[@]}"
	ldcDeclareStr ${2} "${ldcsrt_sortedList}"

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

#ldcHelpInit ${ldcvar_help}

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

ldccli_optDebug=0
ldccli_optQueueErrors=1

# *****************************************************************************

ldcConioDisplay ""
ldcConioDisplay " NEW BUBBLE SORT: Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"
ldcConioDisplay ""

#ldcsrt_array=()
ldctst_sortList="Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"

testBubbleSort "$ldctst_sortList" ldctst_buffer
testSortedList "${ldctst_buffer}"

# *****************************************************************************

ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay " NEW BUBBLE SORT: Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"
ldcConioDisplay ""

#ldcsrt_array=()
ldctst_sortList="Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"

testBubbleSort "$ldctst_sortList" ldctst_buffer
testSortedList "${ldctst_buffer}"

# *****************************************************************************

ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay " NEW BUBBLE SORT: a c \"z y\" 3 5"
ldcConioDisplay ""

#ldcsrt_array=()
ldctst_sortList="a c \"z y\" b 3 5"

testBubbleSort "$ldctst_sortList" ldctst_buffer
testSortedList "${ldctst_buffer}"

# *****************************************************************************

ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay " NEW BUBBLE SORT: (22 34 9 5 98 3 8 12)"
ldcConioDisplay ""

#ldcsrt_array=()
ldctst_sortList="22 34 9 5 98 3 8 12"

testBubbleSort "$ldctst_sortList" ldctst_buffer
testSortedList "${ldctst_buffer}"

# *****************************************************************************

ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay " NEW BUBBLE SORT: 22 34 09 05 98 03 08 12"
ldcConioDisplay ""

#ldcsrt_array=()
ldctst_sortList="22 34 09 05 98 03 08 12"

testBubbleSort "$ldctst_sortList" ldctst_buffer
testSortedList "${ldctst_buffer}"

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
