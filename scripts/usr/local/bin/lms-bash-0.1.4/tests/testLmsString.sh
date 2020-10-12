#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsStr.sh
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

declare    lmsapp_name="testLmsString"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.3"					# script version

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
#	testLmsStrTrim
#
# *****************************************************************************
function testLmsStrTrim()
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
#	testLmsStrUnquote
#
# *****************************************************************************
function testLmsStrUnquote()
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
#	testLmsStrSplitFields
#
# *****************************************************************************
function testLmsStrSplitFields()
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
#	testLmsStrExplode
#
# *****************************************************************************
function testLmsStrExplode()
{
	local resultString
	local string="firstname middlename lastname street city state zipcode "

	lmsConioDisplay "testLmsStrExplode"
	lmsConioDisplay "-----------"
	lmsConioDisplay ""

	lmsConioDisplay "exploding string"
	lmsConioDisplay "    '${string}'"
	lmsConioDisplay " to default array"
	lmsConioDisplay "    'lmsstr_Exploded':"
	lmsConioDisplay ""

	lmsStrExplode "${string}"

	lmsUtilATS lmsstr_Exploded resultString
	lmserr_result=1
	[[ $lmserr_result -eq 0 ]] && lmsConioDisplay "$resultString" || declare -a | grep lmsstr_Exploded

	lmsConioDisplay ""
	lmsConioDisplay "-----------"
	lmsConioDisplay ""

	# *************************************************************************

	lmsConioDisplay "exploding string"
	lmsConioDisplay "    '${string}'"
	lmsConioDisplay " to passed array"
	lmsConioDisplay "    'lmsstr_testArray':"
	lmsConioDisplay ""

	declare -a lmsstr_testArray=()

	lmsStrExplode "${string}" " " lmsstr_testArray

	lmsUtilATS lmsstr_testArray resultString
	lmserr_result=1
	[[ $lmserr_result -eq 0 ]] && lmsConioDisplay "$resultString" || declare -a | grep lmsstr_testArray

	lmsConioDisplay ""
	lmsConioDisplay "-----------"
	lmsConioDisplay ""

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

testLmsStrExplode

lmsConioDisplay ""
lmsConioDisplay "==========================================="
lmsConioDisplay ""

testLmsStrTrim

lmsConioDisplay ""
lmsConioDisplay "==========================================="
lmsConioDisplay ""

testLmsStrUnquote

lmsConioDisplay ""
lmsConioDisplay "==========================================="
lmsConioDisplay ""

testLmsStrSplitFields

lmsConioDisplay ""
lmsConioDisplay "==========================================="
lmsConioDisplay ""

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
