#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcDynSort.sh
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

declare    ldcapp_name="testLdcDynSort"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.2"			# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $ldcbase_dirLib/testDump.sh

. $ldcbase_dirLib/dynaNodeTests.sh
. $ldcbase_dirLib/dynaArrayTests.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# ***********************************************************************************************************
#
#	testLdcDynsInit
#
#		Test ldcDynsInit function performance
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
function testLdcDynsInit()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsInit: ${1} '${2}' '${3}' '${4}' '${5}'"

	ldcDynsInit ${1} ${2} ${3} ${4} ${5}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynsInit exited with error number '$?'"
		testDumpExit "ldcdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynsSetOrder
#
#		Test ldcDynsSetOrder function performance
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
function testLdcDynsSetOrder()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsSetOrder: ${1} '${2}'"

	ldcDynsSetOrder ${1} ${2:-0}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynsSetOrder exited with error number '$?'"
		testDumpExit "ldcdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynsSetValue
#
#		Test ldcDynsSetValue function performance
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
function testLdcDynsSetValue()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsSetValue: ${1} '${2}'"

	ldcDynsSetValue ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynsSetValue exited with error number '$?'"
		testDumpExit "ldcdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynsSetNum
#
#		Test ldcDynsSetNum function performance
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
function testLdcDynsSetNum()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsSetNum: ${1} '${2}'"

	ldcDynsSetNum ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynsSetNum exited with error number '$?'"
		testDumpExit "ldcdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynsSetResort
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
function testLdcDynsSetResort()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsSetResort: ${1}"

	ldcDynsSetResort ${1}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynsSetResort exited with error number '$?'"
		testDumpExit "ldcdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynsEnable
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
function testLdcDynsEnable()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsEnable: ${1} '${2}'"

	ldcDynsEnable ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynsEnable exited with error number '$?'"
		testDumpExit "ldcdyna_ ${1}"
	 }

	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynsBubble
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
function testLdcDynsBubble()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynsBubble: ${1} '${2}'"

	ldcDynsBubble ${1} ${2}
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

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

ldcHelpInit ${ldcvar_help}

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

ldccli_optDebug=0
ldccli_optQueueErrors=0
ldccli_optLogDisplay=0

ldctst_array="testSort"

# *****************************************************************************
# *****************************************************************************
#
#		associative array sort tests (declare -A)
#
# *****************************************************************************
# *****************************************************************************

ldcConioDisplay "***********************************************"
ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay "    associative array sort tests (declare -A)"
ldcConioDisplay ""
ldcConioDisplay "***********************************************"
ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay "Creating a new test array (-A)"
ldcConioDisplay ""
testLdcDynaNew "${ldctst_array}" "A"
[[ $? -eq 0 ]] ||
 {
	ldcLogDisplay "ldcDynaNew failed."
	textDumpExit "ldcdyna_ testSort"
 }

while [[ true ]]
do
	result=1
	testLdcDynaSetAt $ldctst_array "lastname" "wheeler"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaSetAt $ldctst_array "street" "Louise"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaSetAt $ldctst_array "city" "ABQ"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaSetAt $ldctst_array "firstname" "jay"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaSetAt $ldctst_array "middle" "a"
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	ldcConioDisplay "ldcDynaSetAt failed! ($result)"
	testDumpExit "ldcdyna_ testSort"
}

ldcConioDisplay "New test array created."
ldcConioDisplay
ldcConioDisplay "***********************************************"

testLdcDynsInit $ldctst_array 0 1 0 0

testLdcDynsSetOrder $ldctst_array 0
testLdcDynsSetValue $ldctst_array 1
testLdcDynsSetNum $ldctst_array 0
testLdcDynsEnable $ldctst_array 1

testLdcDynsSetResort $ldctst_array
testLdcDynnToStr $ldctst_array

ldcConioDisplay "***********************************************"

testLdcDynsSetValue $ldctst_array 0

testLdcDynsSetResort $ldctst_array
testLdcDynnToStr $ldctst_array

ldcConioDisplay "***********************************************"

testLdcDynaUnset $ldctst_array

# *****************************************************************************
# *****************************************************************************
#
#		sequential array sort tests (declare -a) - numeric values
#
# *****************************************************************************
# *****************************************************************************

ldcConioDisplay ""
ldcConioDisplay "***********************************************"
ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay "    sequential array sort tests (declare -a)"
ldcConioDisplay "               numeric values"
ldcConioDisplay ""
ldcConioDisplay "***********************************************"
ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay "Creating new test array (-a)"
ldcConioDisplay ""

testLdcDynaNew "${ldctst_array}" "a"
[[ $? -eq 0 ]] ||
 {
	ldcLogDisplay "ldcDynaNew failed."
	textDumpExit "ldcdyna_ testSort"
 }

while [[ true ]]
do
	result=1
	testLdcDynaAdd $ldctst_array 15
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 2
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 9
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 1
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 3
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 25
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 17
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 8
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 99
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 4
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 32
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 65
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 28
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 0
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	ldcConioDisplay "ldcDynaSetAt failed! ($result)"
	testDumpExit "ldcdyna_ testSort"
}

ldcConioDisplay "New sort array ccreated."

ldcConioDisplay "***********************************************"

testLdcDynsInit $ldctst_array 0 1 0 1

testLdcDynsSetValue $ldctst_array 0
testLdcDynsSetNum $ldctst_array 1
testLdcDynsEnable $ldctst_array 1

testLdcDynsSetResort $ldctst_array
testLdcDynnToStr $ldctst_array

ldcConioDisplay "***********************************************"

testLdcDynsSetValue $ldctst_array 1
testLdcDynsSetNum $ldctst_array 0

testLdcDynsSetResort $ldctst_array
testLdcDynnToStr $ldctst_array

ldcConioDisplay "***********************************************"

testLdcDynaUnset $ldctst_array

# *****************************************************************************
# *****************************************************************************
#
#		sequential array sort tests (declare -a) - alpha-numeric values
#
# *****************************************************************************
# *****************************************************************************

ldcConioDisplay ""
ldcConioDisplay "***********************************************"
ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay "    sequential array sort tests (declare -a)"
ldcConioDisplay "           alpha-numeric values"
ldcConioDisplay ""
ldcConioDisplay "***********************************************"
ldcConioDisplay "***********************************************"
ldcConioDisplay ""
ldcConioDisplay "Creating new test array (-a)"
ldcConioDisplay ""

testLdcDynaNew "${ldctst_array}" "a"
[[ $? -eq 0 ]] ||
 {
	ldcLogDisplay "ldcDynaNew failed."
	textDumpExit "ldcdyna_ testSort"
 }

while [[ true ]]
do
	result=1
	testLdcDynaAdd $ldctst_array 15
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array "Mary"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array "Jock"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array "Knick"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 3
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 25
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array "Blue"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array "Striped"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array "Nylon"
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 4
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 32
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 65
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 28
	[[ $? -eq 0 ]] || break

	(( result++ ))
	testLdcDynaAdd $ldctst_array 0
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	ldcConioDisplay "ldcDynaSetAt failed! ($result)"
	testDumpExit "ldcdyna_ testSort"
}

ldcConioDisplay "New sort array ccreated."

ldcConioDisplay "***********************************************"

testLdcDynsInit $ldctst_array 0 1 0 1

testLdcDynsSetValue $ldctst_array 0
testLdcDynsSetNum $ldctst_array 1
testLdcDynsEnable $ldctst_array 1

testLdcDynsSetResort $ldctst_array
testLdcDynnToStr $ldctst_array

ldcConioDisplay "***********************************************"

testLdcDynsSetNum $ldctst_array 0
testLdcDynsSetValue $ldctst_array 1

testLdcDynsSetResort $ldctst_array
testLdcDynnToStr $ldctst_array

ldcConioDisplay "***********************************************"

testLdcDynaUnset $ldctst_array

ldccli_optLogDisplay=0
ldccli_optDebug=0

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
