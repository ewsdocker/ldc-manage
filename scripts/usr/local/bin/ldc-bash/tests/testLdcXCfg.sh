#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcXCfg.sh
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
#			Version 0.0.1 - 07-02-2016.
#					0.1.0 - 01-24-2017.
#					0.1.1 - 02-09-2017.
#					0.1.2 - 02-14-2017.
#					0.1.3 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcXcfg"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.3"						# script version

ldctst_Declarations="$ldcbase_dirEtc/testVariables.xml"

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

# *******************************************************
#
#	testShow
#
# *******************************************************
function testShow()
{
	ldcUtilIndent ${1} ${2} 2
	ldcConioDisplay "${2}"
}

# *******************************************************
#
#	testBuildData
#
# *******************************************************
function testBuildData()
{
	case $ldcxml_TagType in

		"OPEN")
			ldcStackWrite global "${ldcxml_TagName}"
			ldcStackSize global ldctst_stackSize

			testShow $ldctst_stackSize "${ldcxml_TagName} (${ldcxml_Entity})"

			ldctst_currentStack=$ldctst_stackSize
			;;

		"CLOSE")
			ldcStackRead global ldctst_item
			;;

		*)
			;;
	esac
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

ldccli_optLogDisplay=0
ldccli_optDebug=1

ldctst_stackSize=0
ldctst_item=""

# *****************************************************************************

ldcXCfgLoad ${ldctst_Declarations} "ldcxcfg_testStack" 1
[[ $? -eq 0 ]] ||
 {
	ldctst_result=$?
	ldccli_optLogDisplay=0
	ldcConioDisplay "ldcXCfgLoad '${ldctst_Declarations}' failed: '${ldctst_result}'" 
 }

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

testLdcDmpVar "ldctest_ ldcxcfg_ ldcxml_ ldccli_ ldcstk"

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
