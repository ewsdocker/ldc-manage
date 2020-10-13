#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcUtils.sh
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


declare    ldcapp_name="testLdcDynNode"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.4"					# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $ldcbase_dirLib/testDump.sh
. $ldcbase_dirLib/testUtilities.sh

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

	ldcConioDisplay "Trimming string =${string}="

	ldcStrTrim "${string}" result

	ldcConioDisplay "result  =${result}="
	ldcConioDisplay "ldcstr_Trimmed =${ldcstr_Trimmed}="

	result=""
	ldcStrTrim "${string}" string

	ldcConioDisplay "result  =${string}="
	ldcConioDisplay "ldcstr_Trimmed =${ldcstr_Trimmed}="

	result=""
	ldcStrTrim "${string}"

	ldcConioDisplay "result  =${string}="
	ldcConioDisplay "ldcstr_Trimmed =${ldcstr_Trimmed}="
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

	ldcConioDisplay ""
	ldcConioDisplay "Unquoting string '${string}'"

	ldcStrUnquote "${string}" result

	ldcConioDisplay "result  =${result}="
	ldcConioDisplay "ldcstr_Unquoted =${ldcstr_Unquoted}="

	ldcConioDisplay ""
	ldcStrUnquote "${string}" string

	ldcConioDisplay "string  =${string}="
	ldcConioDisplay "ldcstr_Unquoted =${ldcstr_Unquoted}="
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

	ldcConioDisplay ""
	ldcConioDisplay "spliting string '${string}'"

	ldcStrSplit "${string}" key value "="

	ldcConioDisplay "key:   ${key}"
	ldcConioDisplay "value: '${value}'"

	ldcConioDisplay ""

	key=""
	value=""

	string="netuser/\"netshare\""

	ldcConioDisplay ""
	ldcConioDisplay "spliting string '${string}'"

	ldcStrSplit "${string}" key value "/"

	ldcConioDisplay "key:   ${key}"
	ldcConioDisplay "value: '${value}'"

	ldcConioDisplay ""

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

	ldcUtilOsInfo "$arrayName"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "UtilityError" "OsInfo failed for array '$arrayName'."
		return 1
	 }

	local count

	ldcDynaCount "$arrayName" count
	[[ $count -eq 0 ]] &&
	 {
		ldcConioDisplay "os parsed array is empty"
    	ldcConioDebug $LINENO "UtilityError" "os parsed array is empty"
    	return 1
	 }

	local list
	ldcDynaKeys "$arrayName" list
	[[ $? -eq 0 ]] || return 1

	ldcsrt_array=( "${list} " )
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "UtilityError" "ldcDynaKeys unable to get keys for array '$arrayName'."
		return 1
	 }

	ldcSortArrayBubble

	local maxKeyLength=2
	for name in "${ldcsrt_array[@]}"
	do
		[[ ${#name} -gt ${maxKeyLength} ]] && maxKeyLength=${#name}
	done

	ldcConioDisplay "OS Info:"
	ldcConioDisplay ""

	local spaceCount
	local spaces

	for name in "${ldcsrt_array[@]}"
	do
		ldcDynaGetAt "$arrayName" "${name}" value
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "UtilityError" "ldcDynaGetAt failed at key: $name."
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

		ldcConioDisplay "    ${name} = ${value}"
	done

	ldcConioDisplay ""

	return 0
}

function testOsType()
{
	local arrayName="${1}"

	ldcUtilOsType "$arrayName" "osType"
	[[ $? -eq 0 ]] || return 1

	ldcConioDisplay "OS Type: ${osType}"
	ldcConioDisplay ""

	return 0
}

function testtestLdcWMParse()
{
	local arrayName="${1}"
	local wmInfo="${2}"

	ldcUtilWMParse "${arrayName}" "${wmInfo}"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "Debug" "Unable to parse wminfo: '$wmInfo'."
		return 1
	 }

	ldcDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "ldcDynnReset '${arrayName}' failed."
		return 2
	 }

	ldcDynnValid "${arrayName}" ldcerr_result
	[[ $? -eq 0 ]] || return 1

	while [[ ${ldcerr_result} -eq 0 ]]
	do
		ldcDynnMap "${arrayName}" wmIndex
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "Failed to get current key."
			return 3
		 }

		ldcDynnGet "${arrayName}" wmInfo
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "Unable to fetch next record."
			return 4
		 }

		echo "$wmIndex: $wmInfo"

		ldcDynnNext "${arrayName}"
		ldcDynnValid "${arrayName}" ldcerr_result
		[[ $? -eq 0 ]] || return 1
	done

	echo " "

	return 0
}

function testWmList()
{
	local arrayName="${1}"

	ldcUtilWMList "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "Debug" "Unable to get WM List."
		return 1
	 }

	ldcDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "ldcDynnReset '${arrayName}' failed."
		return 2
	 }

	ldcDynnValid "${arrayName}" ldcerr_result
	[[ $? -eq 0 ]] || return 1

	while [[ ${ldcerr_result} -eq 0 ]]
	do
		ldcDynnCurrent "${arrayName}" wmIndex
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "Failed to get current key."
			return 3
		 }

		ldcDynnGet "${arrayName}" wmInfo
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "Unable to fetch next record."
			return 4
		 }

		echo "$wmIndex: $wmInfo"

		testtestLdcWMParse "${arrayName}_p" "$wmInfo"

		ldcDynnNext "${arrayName}"
		ldcDynnValid "${arrayName}" ldcerr_result
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

testTrim

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

testUnquote

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

testSplitFields

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

testOsInfo "osInfo"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

testOsType "osType"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

#testWmList "wmTestList"

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************

