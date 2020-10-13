#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLdcDynNode.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.3
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
#		Version 0.0.1 - 08-26-2016.
#				0.1.0 - 12-17-2016.
#				0.2.0 - 01-09-2017.
#				0.2.1 - 01-23-2017.
#				0.2.2 - 02-10-2017.
#				0.2.3 - 02-23-2017.
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

ldcscr_Version="0.2.3"					# script version

# *****************************************************************************

declare -a ldctst_vector=( )

ldctst_success=1

ldctst_error=0
ldctst_number=0

ldctst_name=""
ldctst_next=""

ldctst_valid=0

ldctst_value=0
ldctst_key=0

ldctst_find=""
ldctst_keys=""

ldctst_current=0
ldctst_count=0

ldctst_array=""

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

. $ldcbase_dirLib/dynaArrayTests.sh
. $ldcbase_dirLib/dynaNodeTests.sh

# **************************************************************************
#
#    testLdcRunTests
#
#      Run tests from the current test vector
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# **************************************************************************
function testLdcRunTests()
{
	local arrayName="${1}"

	testNext=""
	testError=0
	testNumber=0

	for testNext in "${testVector[@]}"
	do
		case ${testNext} in

			new)
				testName="ldcDynnNew"
				testLdcDynnNew ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			rset)
				testName="ldcDynnReset"
				testLdcDynnReset ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			valid)
				testName="ldcDynnValid"
				testLdcDynnValid ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			next)
				testName="ldcDynnNext"
				testLdcDynnNext ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			key)
				testName="ldcDynnKey"
				testLdcDynnKey ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			map)
				testName="ldcDynnMap"
				testLdcDynnMap ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			destruct)
				testName="ldcDynnDestruct"
				testLdcDynnDestruct ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			iterate)
				testName="dynaNodeIteration"
				testDynaNodeIteration ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			*)	testError=1
				break
				;;

		esac

		(( testNumber ++ ))

		[[ $testError -eq 0 ]] || break
	done

	return $testError
}

# **************************************************************************
#
#    testLdcRunVector
#
#      Run tests from the test vectors
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# **************************************************************************
function testLdcRunVector()
{
	local arrayName="${1}"

	testBank=0
	testBanks=3

	while [[ $testBank -lt $testBanks ]]
	do
		case $testBank in

			0)	testVector=( new rset valid next key map destruct )
				;;

			1)	testVector=( new rset iterate )
				;;

			2)	testVector=( rset iterate destruct )
				;;

			*)	return 1
		esac

		testSuccess=1

		[[ $testBank -gt 0 ]] && ldcConioDisplay "    ========================" ; ldcConioDisplay ""

		testLdcRunTests ${arrayName}
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDisplay ""
			ldcConioDisplay "Test bank $testBank failed!"
			ldcConioDisplay ""

			declare -p | grep "dyna"
			echo ""
			declare -p | grep test
			echo ""

			testSuccess=0
		 }

		ldcConioDisplay ""
		ldcConioDisplay "Test bank $testBank " n
		[[ $testSuccess -eq 0 ]] && 
		 {
			ldcConioDisplay "aborted with errors."
			return 1
		 }

		ldcConioDisplay "completed test successfully."
		ldcConioDisplay ""

		(( testBank++ ))
	done

	return 0
}

# *******************************************************
# *******************************************************
#
#		Start main program below here
#
# *******************************************************
# *******************************************************

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *******************************************************
# *******************************************************

declare -A dynaTestArray=( [help]=help [dynamic]=array [static]=string )
declare -A ldcdyna_arrays=( [dynaTestArray]=0 )

declare -a testVector=( )

declare    testArray="dynaTestArray"

# *******************************************************
# *******************************************************

ldcConioDisplay "============================================="
ldcConioDisplay "                  First run"
ldcConioDisplay "============================================="

testLdcRunVector ${testArray}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcRunVector failed!"
		[[ $ldccli_optDebug -eq 0 ]] || ldcErrorQDispPop

		testLdcDmpVar ${testArray}
		ldcErrorExitScript "EndInError"
	 }

# *******************************************************

ldcConioDisplay ""
ldcConioDisplay "============================================="
ldcConioDisplay "                 Second run"
ldcConioDisplay "============================================="

dynaTestArray=( [firstname]="jay" [lastname]="wheeler" [middle]="a" [street]="Louise" [city]="ABQ" )

testLdcRunVector ${testArray}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcRunVector failed!"
		[[ $ldccli_optDebug -eq 0 ]] || ldcErrorQDispPop

		testLdcDmpVar ${testArray}
		ldcErrorExitScript "EndInError"
	 }

# *******************************************************

. $ldcbase_dirLib/scriptEnd.sh

