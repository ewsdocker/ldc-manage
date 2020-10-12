#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLmsDynSort.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage tests
#
# *****************************************************************************
#
#	Copyright © 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 02-01-2017.
#					0.0.2 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsDynSort"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.2"			# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $lmsbase_dirLib/testDump.sh

. $lmsbase_dirLib/dynaNodeTests.sh
. $lmsbase_dirLib/dynaArrayTests.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# ***********************************************************************************************************
#
#	testLmsDynsInit
#
#		Test lmsDynsInit function performance
#
#	Parameters:
#		name = dynamic array name to be sorted
#		type = 0 for bubble sort, 1 for ....
#		key = 0 to sort data, 1 to sort keys
#		order = 0 for ascending, 1 for descending
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsInit()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsInit: ${1} '${2}' '${3}' '${4}' '${5}'"

	lmsDynsInit ${1} ${2} ${3} ${4} ${5}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynsInit exited with error number '$?'"
		testDumpExit "lmsdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynsSetOrder
#
#		Test lmsDynsSetOrder function performance
#
#	Parameters:
#		name = dynamic array name to be sorted
#		order = sort order value: 0 = ascending, 1 = descending
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsSetOrder()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsSetOrder: ${1} '${2}'"

	lmsDynsSetOrder ${1} ${2:-0}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynsSetOrder exited with error number '$?'"
		testDumpExit "lmsdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynsSetValue
#
#		Test lmsDynsSetValue function performance
#
#	Parameters:
#		name = dynamic array name to be sorted
#		key = 0 ==> sort by data value, 1 = sort by data key
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsSetValue()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsSetValue: ${1} '${2}'"

	lmsDynsSetValue ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynsSetValue exited with error number '$?'"
		testDumpExit "lmsdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynsSetNum
#
#		Test lmsDynsSetNum function performance
#
#	Parameters:
#		name = dynamic array name to be sorted
#		key = 0 ==> sort by data value, 1 = sort by data key
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsSetNum()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsSetNum: ${1} '${2}'"

	lmsDynsSetNum ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynsSetNum exited with error number '$?'"
		testDumpExit "lmsdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynsSetResort
#
#		Dynamic array in-place sort enable function
#
#	Parameters:
#		name = dynamic array name to be sorted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsSetResort()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsSetResort: ${1}"

	lmsDynsSetResort ${1}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynsSetResort exited with error number '$?'"
		testDumpExit "lmsdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynsEnable
#
#		Dynamic array in-place sort enable function
#
#	Parameters:
#		name = dynamic array name to be sorted
#		enable = (optional) 1 to enable, 0 to disable (default = 1)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsEnable()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsEnable: ${1} '${2}'"

	lmsDynsEnable ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynsEnable exited with error number '$?'"
		testDumpExit "lmsdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynsBubble
#
#		Dynamic array in-place bubble sort 
#
#	Parameters:
#		name = dynamic array name to be sorted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function testLmsDynsBubble()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynsBubble: ${1} '${2}'"

	lmsDynsBubble ${1} ${2}
	[[ $? -eq 0 ]] || return 2

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

lmsHelpInit ${lmsvar_help}

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

lmscli_optDebug=0
lmscli_optQueueErrors=0
lmscli_optLogDisplay=0

lmstst_array="testSort"

# *****************************************************************************
# *****************************************************************************
#
#		associative array sort tests (declare -A)
#
# *****************************************************************************
# *****************************************************************************

lmsConioDisplay "***********************************************"
lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay "    associative array sort tests (declare -A)"
lmsConioDisplay ""
lmsConioDisplay "***********************************************"
lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay "Creating a new test array (-A)"
lmsConioDisplay ""
testLmsDynaNew "${lmstst_array}" "A"
[[ $? -eq 0 ]] ||
 {
	lmsLogDisplay "lmsDynaNew failed."
	textDumpExit "lmsdyna_ testSort"
 }

while [[ true ]]
do
	result=1
	testLmsDynaSetAt $lmstst_array "lastname" "wheeler"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaSetAt $lmstst_array "street" "Louise"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaSetAt $lmstst_array "city" "ABQ"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaSetAt $lmstst_array "firstname" "jay"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaSetAt $lmstst_array "middle" "a"
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	lmsConioDisplay "lmsDynaSetAt failed! ($result)"
	testDumpExit "lmsdyna_ testSort"
}

lmsConioDisplay "New test array created."
lmsConioDisplay
lmsConioDisplay "***********************************************"

testLmsDynsInit $lmstst_array 0 1 0 0

testLmsDynsSetOrder $lmstst_array 0
testLmsDynsSetValue $lmstst_array 1
testLmsDynsSetNum $lmstst_array 0
testLmsDynsEnable $lmstst_array 1

testLmsDynsSetResort $lmstst_array
testLmsDynnToStr $lmstst_array

lmsConioDisplay "***********************************************"

testLmsDynsSetValue $lmstst_array 0

testLmsDynsSetResort $lmstst_array
testLmsDynnToStr $lmstst_array

lmsConioDisplay "***********************************************"

testLmsDynaUnset $lmstst_array

# *****************************************************************************
# *****************************************************************************
#
#		sequential array sort tests (declare -a) - numeric values
#
# *****************************************************************************
# *****************************************************************************

lmsConioDisplay ""
lmsConioDisplay "***********************************************"
lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay "    sequential array sort tests (declare -a)"
lmsConioDisplay "               numeric values"
lmsConioDisplay ""
lmsConioDisplay "***********************************************"
lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay "Creating new test array (-a)"
lmsConioDisplay ""

testLmsDynaNew "${lmstst_array}" "a"
[[ $? -eq 0 ]] ||
 {
	lmsLogDisplay "lmsDynaNew failed."
	textDumpExit "lmsdyna_ testSort"
 }

while [[ true ]]
do
	result=1
	testLmsDynaAdd $lmstst_array 15
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 2
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 9
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 1
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 3
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 25
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 17
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 8
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 99
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 4
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 32
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 65
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 28
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 0
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	lmsConioDisplay "lmsDynaSetAt failed! ($result)"
	testDumpExit "lmsdyna_ testSort"
}

lmsConioDisplay "New sort array ccreated."

lmsConioDisplay "***********************************************"

testLmsDynsInit $lmstst_array 0 1 0 1

testLmsDynsSetValue $lmstst_array 0
testLmsDynsSetNum $lmstst_array 1
testLmsDynsEnable $lmstst_array 1

testLmsDynsSetResort $lmstst_array
testLmsDynnToStr $lmstst_array

lmsConioDisplay "***********************************************"

testLmsDynsSetValue $lmstst_array 1
testLmsDynsSetNum $lmstst_array 0

testLmsDynsSetResort $lmstst_array
testLmsDynnToStr $lmstst_array

lmsConioDisplay "***********************************************"

testLmsDynaUnset $lmstst_array

# *****************************************************************************
# *****************************************************************************
#
#		sequential array sort tests (declare -a) - alpha-numeric values
#
# *****************************************************************************
# *****************************************************************************

lmsConioDisplay ""
lmsConioDisplay "***********************************************"
lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay "    sequential array sort tests (declare -a)"
lmsConioDisplay "           alpha-numeric values"
lmsConioDisplay ""
lmsConioDisplay "***********************************************"
lmsConioDisplay "***********************************************"
lmsConioDisplay ""
lmsConioDisplay "Creating new test array (-a)"
lmsConioDisplay ""

testLmsDynaNew "${lmstst_array}" "a"
[[ $? -eq 0 ]] ||
 {
	lmsLogDisplay "lmsDynaNew failed."
	textDumpExit "lmsdyna_ testSort"
 }

while [[ true ]]
do
	result=1
	testLmsDynaAdd $lmstst_array 15
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array "Mary"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array "Jock"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array "Knick"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 3
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 25
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array "Blue"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array "Striped"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array "Nylon"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 4
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 32
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 65
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 28
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLmsDynaAdd $lmstst_array 0
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	lmsConioDisplay "lmsDynaSetAt failed! ($result)"
	testDumpExit "lmsdyna_ testSort"
}

lmsConioDisplay "New sort array ccreated."

lmsConioDisplay "***********************************************"

testLmsDynsInit $lmstst_array 0 1 0 1

testLmsDynsSetValue $lmstst_array 0
testLmsDynsSetNum $lmstst_array 1
testLmsDynsEnable $lmstst_array 1

testLmsDynsSetResort $lmstst_array
testLmsDynnToStr $lmstst_array

lmsConioDisplay "***********************************************"

testLmsDynsSetNum $lmstst_array 0
testLmsDynsSetValue $lmstst_array 1

testLmsDynsSetResort $lmstst_array
testLmsDynnToStr $lmstst_array

lmsConioDisplay "***********************************************"

testLmsDynaUnset $lmstst_array

lmscli_optLogDisplay=0
lmscli_optDebug=0

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
