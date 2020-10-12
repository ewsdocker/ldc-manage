#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLmsDynArray.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage dynaArray
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
#					0.0.2 - 06-03-2016
#					0.0.2 - 09-02-2016
#					0.1.0 - 01-06-2017.
#					0.1.1 - 01-23-2017.
#					0.1.2 - 02-10-2017.
#					0.1.3 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsDynArray"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.3"					# script version

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

# *****************************************************************************
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
# *****************************************************************************
function testLmsRunTests()
{
	local arrayName="${1}"

	lmstst_next=""
	lmstst_error=0
	lmstst_number=0

	for lmstst_next in "${lmstst_vector[@]}"
	do
		lmsConioDebug $LINENO "DynaNodeInfo" "testLmsRunTests ================================================="
		lmsConioDebug $LINENO "DynaNodeInfo" "testLmsRunTests ----- next test = '${lmstst_next}'"

		case ${lmstst_next} in

			new)
				lmstst_name="lmsDynnNew"
				testLmsDynnNew ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			rset)
				lmstst_name="lmsDynnReset"
				testLmsDynnReset ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			valid)
				lmstst_name="lmsDynnValid"
				testLmsDynnValid ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			next)
				lmstst_name="lmsDynnNext"
				testLmsDynnNext ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			key)
				lmstst_name="lmsDynnKey"
				testLmsDynnKey ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			map)
				lmstst_name="lmsDynnMap"
				testLmsDynnMap ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			destruct)
				lmstst_name="lmsDynnDestruct"
				testLmsDynnDestruct ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			iterate)
				lmstst_name="dynaNodeIteration"
				testDynaNodeIteration ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			keys)
				lmstst_name="lmsDynaKeys"
				testLmsDynaKeys ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			contents)
				lmstst_name="lmsDynaGet"
				testLmsDynaGet ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=$?

				;;

			fvalue)
				lmstst_name="lmsDynaFind"
				testLmsDynaFind ${arrayName} "jay"
				[[ $? -eq 0 ]] || lmstst_error=0

				;;

			acount)
				lmstst_name="lmsDynaCount"
				testLmsDynaCount ${arrayName}
				[[ $? -eq 0 ]] || lmstst_error=0

				;;

			akexists)
				lmstst_name="lmsDynaKeyExists"
				testLmsDynaKeyExists ${arrayName} "lastname"
				[[ $? -eq 0 ]] || lmstst_error=0

				;;

			*)	lmstst_error=1
				break
				;;

		esac

		(( lmstst_number ++ ))

		[[ $lmstst_error -eq 0 ]] || 
		{
			lmsConioDebug $LINENO "DynaNodeInfo" "testLmsRunTests ERROR test = '${lmstst_next}', lmstst_error = '${lmstst_error}'"
			break
		}

		lmsConioDebug $LINENO "DynaNodeInfo" "testLmsRunTests ================================================="
	done

	lmsConioDebug $LINENO "DynaNodeInfo" "testLmsRunTests ================================================="
	return $lmstst_error
}

# *****************************************************************************
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
# *****************************************************************************
function testLmsRunVector()
{
	local arrayName="${1}"

	testBank=0
	testBanks=3

	while [[ $testBank -lt $testBanks ]]
	do
		case $testBank in

			0)	lmstst_vector=( new rset valid next key map acount akexists destruct )
				;;

			1)	lmstst_vector=( new rset acount iterate keys akexists contents fvalue )
				;;

			2)	lmstst_vector=( rset acount akexists iterate destruct )
				;;

			*)	return 1
		esac

		lmstst_success=1

		[[ $testBank -gt 0 ]] && lmsConioDisplay "    ========================" ; lmsConioDisplay ""

		testLmsRunTests ${arrayName}
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDisplay ""
			lmsConioDisplay "Test bank $testBank failed!"
			lmsConioDisplay ""

			testLmsDmpVar

			lmstst_success=0
		 }

		lmsConioDisplay ""
		lmsConioDisplay "Test bank $testBank " n
		[[ $lmstst_success -eq 0 ]] && 
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

lmscli_optDebug=0			# (d) Debug output if not 0
lmscli_optQueueErrors=0
lmscli_optLogDisplay=0

# *******************************************************

lmsScriptFileName $0
. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************
lmscli_optQueueErrors=1

[[ ${lmscli_optQueueErrors} -ne 0 ]] &&
{
	lmsErrorQInit "${lmserr_QName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmstst_errorQInitialize - Unable to create a queue named '${lmserr_QName}'"
		lmsErrorExitScript "EndInError"
	 }
}

# *******************************************************

lmstst_array="dynaTestArray"
testLmsDynaNew "$lmstst_array" "A"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsDynaNew failed!"
		[[ $lmscli_optDebug -eq 0 ]] || lmsErrorQDispPop

		lmsErrorExitScript "EndInError"
	 }

while [[ true ]]
do
	result=1
	testLmsDynaSetAt $lmstst_array "help" "help"
	[[ $? -eq 0 ]] || break

	testLmsDynaSetAt $lmstst_array "dynamic" "array"
	[[ $? -eq 0 ]] || break

	testLmsDynaSetAt $lmstst_array "static" "string"
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	lmsConioDisplay "lmsDynaSetAt failed!"
	testDumpExit
}

# *******************************************************
# *******************************************************

lmsConioDisplay "============================================="
lmsConioDisplay "                  First run"
lmsConioDisplay "============================================="

testLmsRunVector ${lmstst_array}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsRunVector failed!"
		[[ $lmscli_optDebug -eq 0 ]] || lmsErrorQDispPop

		lmsErrorExitScript "EndInError"
	 }

# *******************************************************

lmsConioDisplay ""
lmsConioDisplay "============================================="
lmsConioDisplay "                 Second run"
lmsConioDisplay "============================================="

while [[ true ]]
do
	result=1
	testLmsDynaSetAt $lmstst_array "firstname" "jay"
	[[ $? -eq 0 ]] || break

	testLmsDynaSetAt $lmstst_array "lastname" "wheeler"
	[[ $? -eq 0 ]] || break

	testLmsDynaSetAt $lmstst_array "middle" "a"
	[[ $? -eq 0 ]] || break

	testLmsDynaSetAt $lmstst_array "street" "Louise"
	[[ $? -eq 0 ]] || break

	testLmsDynaSetAt $lmstst_array "city" "ABQ"
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	lmsConioDisplay "lmsDynaSetAt failed!"
	testDumpExit
}

testLmsRunVector ${lmstst_array}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "testLmsRunVector failed!"
		[[ $lmscli_optDebug -eq 0 ]] || lmsErrorQDispPop

		lmsErrorExitScript "EndInError"
	 }

# *******************************************************

. $lmsbase_dirLib/scriptEnd.sh

