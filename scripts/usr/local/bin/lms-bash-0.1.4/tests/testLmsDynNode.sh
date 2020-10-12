#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLmsDynNode.sh
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

declare    lmsapp_name="testLmsDynNode"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.2.3"					# script version

# *****************************************************************************

declare -a lmstst_vector=( )

lmstst_success=1

lmstst_error=0
lmstst_number=0

lmstst_name=""
lmstst_next=""

lmstst_valid=0

lmstst_value=0
lmstst_key=0

lmstst_find=""
lmstst_keys=""

lmstst_current=0
lmstst_count=0

lmstst_array=""

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

. $lmsbase_dirLib/dynaArrayTests.sh
. $lmsbase_dirLib/dynaNodeTests.sh

# **************************************************************************
#
#    testLmsRunTests
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
function testLmsRunTests()
{
	local arrayName="${1}"

	testNext=""
	testError=0
	testNumber=0

	for testNext in "${testVector[@]}"
	do
		case ${testNext} in

			new)
				testName="lmsDynnNew"
				testLmsDynnNew ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			rset)
				testName="lmsDynnReset"
				testLmsDynnReset ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			valid)
				testName="lmsDynnValid"
				testLmsDynnValid ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			next)
				testName="lmsDynnNext"
				testLmsDynnNext ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			key)
				testName="lmsDynnKey"
				testLmsDynnKey ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			map)
				testName="lmsDynnMap"
				testLmsDynnMap ${testArray}
				[[ $? -eq 0 ]] || testError=$?

				;;

			destruct)
				testName="lmsDynnDestruct"
				testLmsDynnDestruct ${testArray}
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
#    testLmsRunVector
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
function testLmsRunVector()
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

		[[ $testBank -gt 0 ]] && lmsConioDisplay "    ========================" ; lmsConioDisplay ""

		testLmsRunTests ${arrayName}
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDisplay ""
			lmsConioDisplay "Test bank $testBank failed!"
			lmsConioDisplay ""

			declare -p | grep "dyna"
			echo ""
			declare -p | grep test
			echo ""

			testSuccess=0
		 }

		lmsConioDisplay ""
		lmsConioDisplay "Test bank $testBank " n
		[[ $testSuccess -eq 0 ]] && 
		 {
			lmsConioDisplay "aborted with errors."
			return 1
		 }

		lmsConioDisplay "completed test successfully."
		lmsConioDisplay ""

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

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *******************************************************
# *******************************************************

declare -A dynaTestArray=( [help]=help [dynamic]=array [static]=string )
declare -A lmsdyna_arrays=( [dynaTestArray]=0 )

declare -a testVector=( )

declare    testArray="dynaTestArray"

# *******************************************************
# *******************************************************

lmsConioDisplay "============================================="
lmsConioDisplay "                  First run"
lmsConioDisplay "============================================="

testLmsRunVector ${testArray}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsRunVector failed!"
		[[ $lmscli_optDebug -eq 0 ]] || lmsErrorQDispPop

		testLmsDmpVar ${testArray}
		lmsErrorExitScript "EndInError"
	 }

# *******************************************************

lmsConioDisplay ""
lmsConioDisplay "============================================="
lmsConioDisplay "                 Second run"
lmsConioDisplay "============================================="

dynaTestArray=( [firstname]="jay" [lastname]="wheeler" [middle]="a" [street]="Louise" [city]="ABQ" )

testLmsRunVector ${testArray}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsRunVector failed!"
		[[ $lmscli_optDebug -eq 0 ]] || lmsErrorQDispPop

		testLmsDmpVar ${testArray}
		lmsErrorExitScript "EndInError"
	 }

# *******************************************************

. $lmsbase_dirLib/scriptEnd.sh

