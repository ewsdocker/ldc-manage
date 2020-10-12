#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsUtils.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.4
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
#				0.0.2 - 12-17-2016.
#				0.0.3 - 02-08-2017.
#				0.0.4 - 02-23-2017.
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

lmsscr_Version="0.0.4"					# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $lmsbase_dirLib/testDump.sh
. $lmsbase_dirLib/testUtilities.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *****************************************************************************
#
#	testTrim
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
testTrim()
{
	declare -g string="  a string with   enclosed  blanks  "
	declare -g result=""

	lmsConioDisplay "Trimming string =${string}="

	lmsStrTrim "${string}" result

	lmsConioDisplay "result  =${result}="
	lmsConioDisplay "lmsstr_Trimmed =${lmsstr_Trimmed}="

	result=""
	lmsStrTrim "${string}" string

	lmsConioDisplay "result  =${string}="
	lmsConioDisplay "lmsstr_Trimmed =${lmsstr_Trimmed}="

	result=""
	lmsStrTrim "${string}"

	lmsConioDisplay "result  =${string}="
	lmsConioDisplay "lmsstr_Trimmed =${lmsstr_Trimmed}="
}

# *****************************************************************************
#
#	testUnique
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
testUnquote()
{
	declare string="\"a string enclosed in quotes\""
	result=""

	lmsConioDisplay ""
	lmsConioDisplay "Unquoting string '${string}'"

	lmsStrUnquote "${string}" result

	lmsConioDisplay "result  =${result}="
	lmsConioDisplay "lmsstr_Unquoted =${lmsstr_Unquoted}="

	lmsConioDisplay ""
	lmsStrUnquote "${string}" string

	lmsConioDisplay "string  =${string}="
	lmsConioDisplay "lmsstr_Unquoted =${lmsstr_Unquoted}="
}

# *****************************************************************************
#
#	testSplitFields
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
testSplitFields()
{
	declare string="netuser=\"netshare\""
	key=""
	value=""

	lmsConioDisplay ""
	lmsConioDisplay "spliting string '${string}'"

	lmsStrSplit "${string}" key value "="

	lmsConioDisplay "key:   ${key}"
	lmsConioDisplay "value: '${value}'"

	lmsConioDisplay ""

	key=""
	value=""

	string="netuser/\"netshare\""

	lmsConioDisplay ""
	lmsConioDisplay "spliting string '${string}'"

	lmsStrSplit "${string}" key value "/"

	lmsConioDisplay "key:   ${key}"
	lmsConioDisplay "value: '${value}'"

	lmsConioDisplay ""

}

# *****************************************************************************
#
#	testOsInfo
#
#	parameters:
#		arrayName = name of the array to create with the results
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
testOsInfo()
{
	local arrayName="${1}"

	lmsUtilOsInfo "$arrayName"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "UtilityError" "OsInfo failed for array '$arrayName'."
		return 1
	 }

	local count

	lmsDynaCount "$arrayName" count
	[[ $count -eq 0 ]] &&
	 {
		lmsConioDisplay "os parsed array is empty"
    	lmsConioDebug $LINENO "UtilityError" "os parsed array is empty"
    	return 1
	 }

	local list
	lmsDynaKeys "$arrayName" list
	[[ $? -eq 0 ]] || return 1

	lmssrt_array=( "${list} " )
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "UtilityError" "lmsDynaKeys unable to get keys for array '$arrayName'."
		return 1
	 }

	lmsSortArrayBubble

	local maxKeyLength=2
	for name in "${lmssrt_array[@]}"
	do
		[[ ${#name} -gt ${maxKeyLength} ]] && maxKeyLength=${#name}
	done

	lmsConioDisplay "OS Info:"
	lmsConioDisplay ""

	local spaceCount
	local spaces

	for name in "${lmssrt_array[@]}"
	do
		lmsDynaGetAt "$arrayName" "${name}" value
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "UtilityError" "lmsDynaGetAt failed at key: $name."
			return 1
		 }

		nameSize=${#name}
		let spaces=$maxKeyLength-$nameSize+1

		spaceCount=0

		while [ $spaceCount -lt $spaces ]
		do
			name="${name} "
			let spaceCount+=1
		done

		lmsConioDisplay "    ${name} = ${value}"
	done

	lmsConioDisplay ""

	return 0
}

function testOsType()
{
	local arrayName="${1}"

	lmsUtilOsType "$arrayName" "osType"
	[[ $? -eq 0 ]] || return 1

	lmsConioDisplay "OS Type: ${osType}"
	lmsConioDisplay ""

	return 0
}

function testtestLmsWMParse()
{
	local arrayName="${1}"
	local wmInfo="${2}"

	lmsUtilWMParse "${arrayName}" "${wmInfo}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "Debug" "Unable to parse wminfo: '$wmInfo'."
		return 1
	 }

	lmsDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "lmsDynnReset '${arrayName}' failed."
		return 2
	 }

	lmsDynnValid "${arrayName}" lmserr_result
	[[ $? -eq 0 ]] || return 1

	while [[ ${lmserr_result} -eq 0 ]]
	do
		lmsDynnMap "${arrayName}" wmIndex
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "Failed to get current key."
			return 3
		 }

		lmsDynnGet "${arrayName}" wmInfo
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "Unable to fetch next record."
			return 4
		 }

		echo "$wmIndex: $wmInfo"

		lmsDynnNext "${arrayName}"
		lmsDynnValid "${arrayName}" lmserr_result
		[[ $? -eq 0 ]] || return 1
	done

	echo " "

	return 0
}

function testWmList()
{
	local arrayName="${1}"

	lmsUtilWMList "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "Debug" "Unable to get WM List."
		return 1
	 }

	lmsDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "lmsDynnReset '${arrayName}' failed."
		return 2
	 }

	lmsDynnValid "${arrayName}" lmserr_result
	[[ $? -eq 0 ]] || return 1

	while [[ ${lmserr_result} -eq 0 ]]
	do
		lmsDynnCurrent "${arrayName}" wmIndex
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "Failed to get current key."
			return 3
		 }

		lmsDynnGet "${arrayName}" wmInfo
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "Unable to fetch next record."
			return 4
		 }

		echo "$wmIndex: $wmInfo"

		testtestLmsWMParse "${arrayName}_p" "$wmInfo"

		lmsDynnNext "${arrayName}"
		lmsDynnValid "${arrayName}" lmserr_result
		[[ $? -eq 0 ]] || return 1
	done

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

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

testTrim

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

testUnquote

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

testSplitFields

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

testOsInfo "osInfo"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

testOsType "osType"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

#testWmList "wmTestList"

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************

