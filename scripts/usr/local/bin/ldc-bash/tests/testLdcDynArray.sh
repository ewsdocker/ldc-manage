#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLdcDynArray.sh
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

declare    ldcapp_name="testLdcDynArray"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.3"					# script version

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

# *****************************************************************************
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
# *****************************************************************************
function testLdcRunTests()
{
	local arrayName="${1}"

	ldctst_next=""
	ldctst_error=0
	ldctst_number=0

	for ldctst_next in "${ldctst_vector[@]}"
	do
		ldcConioDebug $LINENO "DynaNodeInfo" "testLdcRunTests ================================================="
		ldcConioDebug $LINENO "DynaNodeInfo" "testLdcRunTests ----- next test = '${ldctst_next}'"

		case ${ldctst_next} in

			new)
				ldctst_name="ldcDynnNew"
				testLdcDynnNew ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			rset)
				ldctst_name="ldcDynnReset"
				testLdcDynnReset ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			valid)
				ldctst_name="ldcDynnValid"
				testLdcDynnValid ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			next)
				ldctst_name="ldcDynnNext"
				testLdcDynnNext ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			key)
				ldctst_name="ldcDynnKey"
				testLdcDynnKey ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			map)
				ldctst_name="ldcDynnMap"
				testLdcDynnMap ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			destruct)
				ldctst_name="ldcDynnDestruct"
				testLdcDynnDestruct ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			iterate)
				ldctst_name="dynaNodeIteration"
				testDynaNodeIteration ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			keys)
				ldctst_name="ldcDynaKeys"
				testLdcDynaKeys ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			contents)
				ldctst_name="ldcDynaGet"
				testLdcDynaGet ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=$?

				;;

			fvalue)
				ldctst_name="ldcDynaFind"
				testLdcDynaFind ${arrayName} "jay"
				[[ $? -eq 0 ]] || ldctst_error=0

				;;

			acount)
				ldctst_name="ldcDynaCount"
				testLdcDynaCount ${arrayName}
				[[ $? -eq 0 ]] || ldctst_error=0

				;;

			akexists)
				ldctst_name="ldcDynaKeyExists"
				testLdcDynaKeyExists ${arrayName} "lastname"
				[[ $? -eq 0 ]] || ldctst_error=0

				;;

			*)	ldctst_error=1
				break
				;;

		esac

		(( ldctst_number ++ ))

		[[ $ldctst_error -eq 0 ]] || 
		{
			ldcConioDebug $LINENO "DynaNodeInfo" "testLdcRunTests ERROR test = '${ldctst_next}', ldctst_error = '${ldctst_error}'"
			break
		}

		ldcConioDebug $LINENO "DynaNodeInfo" "testLdcRunTests ================================================="
	done

	ldcConioDebug $LINENO "DynaNodeInfo" "testLdcRunTests ================================================="
	return $ldctst_error
}

# *****************************************************************************
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
# *****************************************************************************
function testLdcRunVector()
{
	local arrayName="${1}"

	testBank=0
	testBanks=3

	while [[ $testBank -lt $testBanks ]]
	do
		case $testBank in

			0)	ldctst_vector=( new rset valid next key map acount akexists destruct )
				;;

			1)	ldctst_vector=( new rset acount iterate keys akexists contents fvalue )
				;;

			2)	ldctst_vector=( rset acount akexists iterate destruct )
				;;

			*)	return 1
		esac

		ldctst_success=1

		[[ $testBank -gt 0 ]] && ldcConioDisplay "    ========================" ; ldcConioDisplay ""

		testLdcRunTests ${arrayName}
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDisplay ""
			ldcConioDisplay "Test bank $testBank failed!"
			ldcConioDisplay ""

			testLdcDmpVar

			ldctst_success=0
		 }

		ldcConioDisplay ""
		ldcConioDisplay "Test bank $testBank " n
		[[ $ldctst_success -eq 0 ]] && 
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

ldccli_optDebug=0			# (d) Debug output if not 0
ldccli_optQueueErrors=0
ldccli_optLogDisplay=0

# *******************************************************

ldcScriptFileName $0
. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************
ldccli_optQueueErrors=1

[[ ${ldccli_optQueueErrors} -ne 0 ]] &&
{
	ldcErrorQInit "${ldcerr_QName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldctst_errorQInitialize - Unable to create a queue named '${ldcerr_QName}'"
		ldcErrorExitScript "EndInError"
	 }
}

# *******************************************************

ldctst_array="dynaTestArray"
testLdcDynaNew "$ldctst_array" "A"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "ldcDynaNew failed!"
		[[ $ldccli_optDebug -eq 0 ]] || ldcErrorQDispPop

		ldcErrorExitScript "EndInError"
	 }

while [[ true ]]
do
	result=1
	testLdcDynaSetAt $ldctst_array "help" "help"
	[[ $? -eq 0 ]] || break

	testLdcDynaSetAt $ldctst_array "dynamic" "array"
	[[ $? -eq 0 ]] || break

	testLdcDynaSetAt $ldctst_array "static" "string"
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	ldcConioDisplay "ldcDynaSetAt failed!"
	testDumpExit
}

# *******************************************************
# *******************************************************

ldcConioDisplay "============================================="
ldcConioDisplay "                  First run"
ldcConioDisplay "============================================="

testLdcRunVector ${ldctst_array}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcRunVector failed!"
		[[ $ldccli_optDebug -eq 0 ]] || ldcErrorQDispPop

		ldcErrorExitScript "EndInError"
	 }

# *******************************************************

ldcConioDisplay ""
ldcConioDisplay "============================================="
ldcConioDisplay "                 Second run"
ldcConioDisplay "============================================="

while [[ true ]]
do
	result=1
	testLdcDynaSetAt $ldctst_array "firstname" "jay"
	[[ $? -eq 0 ]] || break

	testLdcDynaSetAt $ldctst_array "lastname" "wheeler"
	[[ $? -eq 0 ]] || break

	testLdcDynaSetAt $ldctst_array "middle" "a"
	[[ $? -eq 0 ]] || break

	testLdcDynaSetAt $ldctst_array "street" "Louise"
	[[ $? -eq 0 ]] || break

	testLdcDynaSetAt $ldctst_array "city" "ABQ"
	[[ $? -eq 0 ]] || break

	result=0
	break
done

[[ $result -eq 0 ]] ||
{
	ldcConioDisplay "ldcDynaSetAt failed!"
	testDumpExit
}

testLdcRunVector ${ldctst_array}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "testLdcRunVector failed!"
		[[ $ldccli_optDebug -eq 0 ]] || ldcErrorQDispPop

		ldcErrorExitScript "EndInError"
	 }

# *******************************************************

. $ldcbase_dirLib/scriptEnd.sh

