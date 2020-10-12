#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsWinNode.sh
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


declare    lmsapp_name="testLmsWinNode"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.5"					# script version

declare windowArray=""

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
#	testLmsWMNodeOutput
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
function testLmsWMNodeOutput()
{
	local arrayName="${1}"

	lmsUtilWMList "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "Debug" "Unable to get WM List."
		return 1
	 }

	lmsDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DebugError" "lmsDynnReset '${arrayName}' failed."
		return 2
	 }

	lmsDynnReload "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DebugError" "lmsDynnReset '${arrayName}' failed."
		return 2
	 }

	while [[ ${lmsdyna_valid} -eq 1 ]]
	do
		lmsDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "DebugError" "Unable to fetch next record."
			return 3
		 }

		testtestLmsWMParse "${arrayName}_p" "${lmsdyna_value}"

		lmsDynnNext "${arrayName}"
	done

	return 0
}

# *****************************************************************************
#
#	testLmsWMParse
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
function testLmsWMParse()
{
	local wsName=${1}
	local wmInfo="${2}"

	lmsDynaNew ${wsName} "A"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "Unable to create workspace directory '${wsDir}'."
		return 1
	 }

	lmsUtilWMParse ${wsName} "${wmInfo}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "Debug" "Unable to parse wminfo: '$wmInfo'."
		return 1
	 }

	lmsDynnReset ${wsName}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "lmsDynnReset '${wsName}' failed."
		return 2
	 }

	lmsDynnReload ${wsName}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "lmsDynnReload '${wsName}' failed."
		return 2
	 }

#echo "${wsName}"

	while [[ ${lmsdyna_valid} -eq 1 ]]
	do
		lmsDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			[[ $lmsdyna_valid -eq 0 ]] && break

			lmsLogDebugMessage $LINENO "DebugError" "Unable to fetch next record."
			return 3
		 }

		echo "$lmsdyna_key: $lmsdyna_value"

		lmsDynnNext "${arrayName}"
	done

	return 0
}

# *****************************************************************************
#
#	testLmsProcessWMList
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
function testLmsProcessWMList()
{
	local arrayName=${1:-""}
	local wsDir=${2:-""}

lmscli_optDebug=1

	lmsLogDebugMessage $LINENO "UtilityDebug" "Creating workspace directory in '${wsDir}'."

	lmsDynaNew ${wsDir} "a"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "Unable to create workspace directory '${wsDir}'."
		return 1
	 }

	lmsDynnReset "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "Unable to reset '${arrayName}'."
		return 2
	 }

	lmsDynaRegistered ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		lmsLogDebugMessage $LINENO "UtilityError" "lmsDynaRegistered failed for $arrayName."
		return 7
	 }

#	lmsDynnReload "${arrayName}"
#	[[ $? -eq 0 ]] ||
#	 {
#		lmsLogDebugMessage $LINENO "UtilityError" "Unable to reload '${arrayName}'."
#		return 3
#	 }

	winNodeName=$wsDir
	winNodeNumber=0

	while [[ ${lmsdyna_valid} -eq 1 ]]
	do
		lmsDynn_GetElement
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "Unable to fetch next record."
			return 4
		 }

[[ $lmsdyna_index -gt 1 ]] && break

		winName="${winNodeName}${winNodeNumber}"

		testLmsWMParse ${winName} "${lmsdyna_value}"
		[[ $? -eq 0 ]] || 
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "testLmsWMParse failed for '${lmsdyna_value}'."
			return 5
		 }

		lmsDynaSetAt ${wsDir} "${winName}" ${winNodeNumber}
		[[ $? -eq 0 ]] || 
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "lmsDynaAdd failed for $winName."
			return 6
		 }

		lmsDynaRegistered ${arrayName}
		[[ $? -eq 0 ]] || 
		 {
			lmsLogDebugMessage $LINENO "UtilityError" "lmsDynaRegistered failed for $arrayName."
			return 7
		 }

		lmsDynnNext "${arrayName}"

		lmsDynn_Valid
		lmsdyna_valid=$?
	done

lmscli_optDebug=0

testDumpVars "lmsdyna_ workspace ws"

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

lmscli_optDebug=0			# (d) Debug output if not 0
lmscli_optQueueErrors=0
lmscli_optSilent=0    		# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0			# (b) Batch mode - missing parameters fail
silentOverride=0				# set to 1 to lmscli_optOverride the lmscli_optSilent flag

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

. $lmsbase_dirLib/testDump.sh

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

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *******************************************************
# *******************************************************

lmscli_optDebug=0

lmsConioDisplay "======================================================="
lmsConioDisplay ""
lmsConioDisplay "Loading currently running windows in all workspaces"
lmsConioDisplay ""
lmsConioDisplay "======================================================="

lmsUtilWMList "${windowArray}"
[[ $? -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "DebugError" "Unable to load/output wmList"	
 }

declare -p | grep "$windowArray"

lmsConioDisplay ""

lmscli_optDebug=0

lmsConioDisplay "======================================================="
lmsConioDisplay ""
lmsConioDisplay "Process the windowArray and list the window information"
lmsConioDisplay ""
lmsConioDisplay "======================================================="

testLmsProcessWMList "${windowArray}" "ws"
[[ $? -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "DebugError" "testLmsProcessWMList failed."	
 }

lmsConioDisplay ""

declare -a | grep "${windowArray}"
lmsConioDisplay ""

declare -A | grep "${windowArray}"
lmsConioDisplay ""

declare -a | grep ws
lmsConioDisplay ""

declare -A | grep ws
lmsConioDisplay ""

declare -p | grep lmsdyna_
lmsConioDisplay ""

lmscli_optDebug=0

# *******************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *******************************************************

