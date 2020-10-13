#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcWinNode.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.5
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
#               0.0.3 - 01-13-2017.
#				0.0.4 - 02-09-2017.
#				0.0.5 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************


declare    ldcapp_name="testLdcWinNode"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.5"					# script version

declare windowArray=""

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
#	testLdcWMNodeOutput
#
#		outputs window information from an associative dynamic array
#
#	parameters:
#		arrayName = the name of an associative dynamic array
#		wmInfo = record to be parsed
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function testLdcWMNodeOutput()
{
	local arrayName="${1}"

	ldcUtilWMList "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "Debug" "Unable to get WM List."
		return 1
	 }

	ldcDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DebugError" "ldcDynnReset '${arrayName}' failed."
		return 2
	 }

	ldcDynnReload "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DebugError" "ldcDynnReset '${arrayName}' failed."
		return 2
	 }

	while [[ ${ldcdyna_valid} -eq 1 ]]
	do
		ldcDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DebugError" "Unable to fetch next record."
			return 3
		 }

		testtestLdcWMParse "${arrayName}_p" "${ldcdyna_value}"

		ldcDynnNext "${arrayName}"
	done

	return 0
}

# *****************************************************************************
#
#	testLdcWMParse
#
#		parses window information record into an associative dynamic array
#
#	parameters:
#		wsName = the name of an  associative dynamic array to populate
#		wmInfo = record to be parsed
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function testLdcWMParse()
{
	local wsName=${1}
	local wmInfo="${2}"

	ldcDynaNew ${wsName} "A"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "Unable to create workspace directory '${wsDir}'."
		return 1
	 }

	ldcUtilWMParse ${wsName} "${wmInfo}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "Debug" "Unable to parse wminfo: '$wmInfo'."
		return 1
	 }

	ldcDynnReset ${wsName}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "ldcDynnReset '${wsName}' failed."
		return 2
	 }

	ldcDynnReload ${wsName}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "ldcDynnReload '${wsName}' failed."
		return 2
	 }

#echo "${wsName}"

	while [[ ${ldcdyna_valid} -eq 1 ]]
	do
		ldcDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			[[ $ldcdyna_valid -eq 0 ]] && break

			ldcLogDebugMessage $LINENO "DebugError" "Unable to fetch next record."
			return 3
		 }

		echo "$ldcdyna_key: $ldcdyna_value"

		ldcDynnNext "${arrayName}"
	done

	return 0
}

# *****************************************************************************
#
#	testLdcProcessWMList
#
#		process each window information record in arrayName
#
#	parameters:
#		arrayName = the name of the array containing workspace information records
#		wsDir = the name of an  associative dynamic array to populate
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function testLdcProcessWMList()
{
	local arrayName=${1:-""}
	local wsDir=${2:-""}

ldccli_optDebug=1

	ldcLogDebugMessage $LINENO "UtilityDebug" "Creating workspace directory in '${wsDir}'."

	ldcDynaNew ${wsDir} "a"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "Unable to create workspace directory '${wsDir}'."
		return 1
	 }

	ldcDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "Unable to reset '${arrayName}'."
		return 2
	 }

	ldcDynaRegistered ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		ldcLogDebugMessage $LINENO "UtilityError" "ldcDynaRegistered failed for $arrayName."
		return 7
	 }

#	ldcDynnReload "${arrayName}"
#	[[ $? -eq 0 ]] ||
#	 {
#		ldcLogDebugMessage $LINENO "UtilityError" "Unable to reload '${arrayName}'."
#		return 3
#	 }

	winNodeName=$wsDir
	winNodeNumber=0

	while [[ ${ldcdyna_valid} -eq 1 ]]
	do
		ldcDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "Unable to fetch next record."
			return 4
		 }

[[ $ldcdyna_index -gt 1 ]] && break

		winName="${winNodeName}${winNodeNumber}"

		testLdcWMParse ${winName} "${ldcdyna_value}"
		[[ $? -eq 0 ]] || 
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "testLdcWMParse failed for '${ldcdyna_value}'."
			return 5
		 }

		ldcDynaSetAt ${wsDir} "${winName}" ${winNodeNumber}
		[[ $? -eq 0 ]] || 
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "ldcDynaAdd failed for $winName."
			return 6
		 }

		ldcDynaRegistered ${arrayName}
		[[ $? -eq 0 ]] || 
		 {
			ldcLogDebugMessage $LINENO "UtilityError" "ldcDynaRegistered failed for $arrayName."
			return 7
		 }

		ldcDynnNext "${arrayName}"

		ldcDynn_Valid
		ldcdyna_valid=$?
	done

ldccli_optDebug=0

testDumpVars "ldcdyna_ workspace ws"

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

ldccli_optDebug=0			# (d) Debug output if not 0
ldccli_optQueueErrors=0
ldccli_optSilent=0    		# (q) Quiet setting: non-zero for absolutely NO output
ldccli_optBatch=0			# (b) Batch mode - missing parameters fail
silentOverride=0				# set to 1 to ldccli_optOverride the ldccli_optSilent flag

applicationVersion="1.0"		# Application version

# *******************************************************
#
#	test variables
#
# *******************************************************
# *******************************************************

windowArray="workspaces"

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

ldccli_optDebug=0

ldcConioDisplay "======================================================="
ldcConioDisplay ""
ldcConioDisplay "Loading currently running windows in all workspaces"
ldcConioDisplay ""
ldcConioDisplay "======================================================="

ldcUtilWMList "${windowArray}"
[[ $? -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "DebugError" "Unable to load/output wmList"	
 }

declare -p | grep "$windowArray"

ldcConioDisplay ""

ldccli_optDebug=0

ldcConioDisplay "======================================================="
ldcConioDisplay ""
ldcConioDisplay "Process the windowArray and list the window information"
ldcConioDisplay ""
ldcConioDisplay "======================================================="

testLdcProcessWMList "${windowArray}" "ws"
[[ $? -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "DebugError" "testLdcProcessWMList failed."	
 }

ldcConioDisplay ""

declare -a | grep "${windowArray}"
ldcConioDisplay ""

declare -A | grep "${windowArray}"
ldcConioDisplay ""

declare -a | grep ws
ldcConioDisplay ""

declare -A | grep ws
ldcConioDisplay ""

declare -p | grep ldcdyna_
ldcConioDisplay ""

ldccli_optDebug=0

# *******************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *******************************************************

