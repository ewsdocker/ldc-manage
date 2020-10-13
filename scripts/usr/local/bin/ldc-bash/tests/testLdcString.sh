#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcStr.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
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
#		Version 0.0.1 - 02-28-2016.
#				0.1.0 - 01-13-2017.
#				0.1.1 - 01-24-2017.
#				0.1.2 - 02-08-2017.
#				0.1.3 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcString"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.3"					# script version

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
#	testLdcStrTrim
#
# *****************************************************************************
function testLdcStrTrim()
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
#	testLdcStrUnquote
#
# *****************************************************************************
function testLdcStrUnquote()
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
#	testLdcStrSplitFields
#
# *****************************************************************************
function testLdcStrSplitFields()
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
#	testLdcStrExplode
#
# *****************************************************************************
function testLdcStrExplode()
{
	local resultString
	local string="firstname middlename lastname street city state zipcode "

	ldcConioDisplay "testLdcStrExplode"
	ldcConioDisplay "-----------"
	ldcConioDisplay ""

	ldcConioDisplay "exploding string"
	ldcConioDisplay "    '${string}'"
	ldcConioDisplay " to default array"
	ldcConioDisplay "    'ldcstr_Exploded':"
	ldcConioDisplay ""

	ldcStrExplode "${string}"

	ldcUtilATS ldcstr_Exploded resultString
	ldcerr_result=1
	[[ $ldcerr_result -eq 0 ]] && ldcConioDisplay "$resultString" || declare -a | grep ldcstr_Exploded

	ldcConioDisplay ""
	ldcConioDisplay "-----------"
	ldcConioDisplay ""

	# *************************************************************************

	ldcConioDisplay "exploding string"
	ldcConioDisplay "    '${string}'"
	ldcConioDisplay " to passed array"
	ldcConioDisplay "    'ldcstr_testArray':"
	ldcConioDisplay ""

	declare -a ldcstr_testArray=()

	ldcStrExplode "${string}" " " ldcstr_testArray

	ldcUtilATS ldcstr_testArray resultString
	ldcerr_result=1
	[[ $ldcerr_result -eq 0 ]] && ldcConioDisplay "$resultString" || declare -a | grep ldcstr_testArray

	ldcConioDisplay ""
	ldcConioDisplay "-----------"
	ldcConioDisplay ""

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

testLdcStrExplode

ldcConioDisplay ""
ldcConioDisplay "==========================================="
ldcConioDisplay ""

testLdcStrTrim

ldcConioDisplay ""
ldcConioDisplay "==========================================="
ldcConioDisplay ""

testLdcStrUnquote

ldcConioDisplay ""
ldcConioDisplay "==========================================="
ldcConioDisplay ""

testLdcStrSplitFields

ldcConioDisplay ""
ldcConioDisplay "==========================================="
ldcConioDisplay ""

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
