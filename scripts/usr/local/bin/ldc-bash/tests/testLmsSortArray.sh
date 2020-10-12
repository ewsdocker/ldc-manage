#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLmsSortArray.sh
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

declare    lmsapp_name="testLmsSortArray"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh
. $lmsbase_dirLib/lmsSortArray.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.1"			# script version

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
#	testSortedList
#
# *****************************************************************************
testSortedList()
{
	lmsConioDisplay ""
	lmsConioDisplay "testSortedList: ${1}"

	local    valueList="${1}"

	local -i key=0
	local    msg=""
	local    field=""

	for field in ${valueList}
	do
		printf -v msg "   (% 3u) %s" $key "$field"
		lmsConioDisplay "$msg"

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
	lmsConioDisplay ""
	lmsConioDisplay "testBubbleSort: ${1}"

	lmssrt_array=()

	local -a sortArray=( ${1} )
	lmsSortArrayBubble $( echo "${sortArray[@]}" | sed 's/\</ /g' )
	
	lmssrt_sortedList="${lmssrt_array[@]}"
	lmsDeclareStr ${2} "${lmssrt_sortedList}"

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

#lmsHelpInit ${lmsvar_help}

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

lmscli_optDebug=0
lmscli_optQueueErrors=1

# *****************************************************************************

lmsConioDisplay ""
lmsConioDisplay " NEW BUBBLE SORT: Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"
lmsConioDisplay ""

#lmssrt_array=()
lmstst_sortList="Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"

testBubbleSort "$lmstst_sortList" lmstst_buffer
testSortedList "${lmstst_buffer}"

# *****************************************************************************

lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay " NEW BUBBLE SORT: Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"
lmsConioDisplay ""

#lmssrt_array=()
lmstst_sortList="Error_NotRoot Error_WriteError Error_None Error_SharePass Error_CreateFolder Error_ChmodFailed Error_NoPass Error_ChownFailed Error_EndOfTest Error_ParamErrors Error_NonGroup Error_TouchFailed Error_ShareUser Error_Unknown"

testBubbleSort "$lmstst_sortList" lmstst_buffer
testSortedList "${lmstst_buffer}"

# *****************************************************************************

lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay " NEW BUBBLE SORT: a c \"z y\" 3 5"
lmsConioDisplay ""

#lmssrt_array=()
lmstst_sortList="a c \"z y\" b 3 5"

testBubbleSort "$lmstst_sortList" lmstst_buffer
testSortedList "${lmstst_buffer}"

# *****************************************************************************

lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay " NEW BUBBLE SORT: (22 34 9 5 98 3 8 12)"
lmsConioDisplay ""

#lmssrt_array=()
lmstst_sortList="22 34 9 5 98 3 8 12"

testBubbleSort "$lmstst_sortList" lmstst_buffer
testSortedList "${lmstst_buffer}"

# *****************************************************************************

lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay " NEW BUBBLE SORT: 22 34 09 05 98 03 08 12"
lmsConioDisplay ""

#lmssrt_array=()
lmstst_sortList="22 34 09 05 98 03 08 12"

testBubbleSort "$lmstst_sortList" lmstst_buffer
testSortedList "${lmstst_buffer}"

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
