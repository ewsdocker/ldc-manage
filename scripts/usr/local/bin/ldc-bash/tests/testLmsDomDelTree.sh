#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testlmsDomDelTree.sh
#
#	Test ability to correctly delete a DOM tree created by the lmsDomRRead library.
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage DOMDocument
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
#			Version 0.0.1 - 09-06-2016.
#                   0.0.2 - 09-17-2016.
#					0.0.3 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsDomDelTree"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

declare    lmsscr_Version="0.0.3"						# script version
declare    lmsapp_errors="$lmsbase_dirEtc/errorCodes.xml"
declare    lmsvar_help="$lmsbase_dirEtc/testHelp.xml"			# path to the help information file

declare	   lmstest_cliOptions="$lmsbase_dirEtc/testDOMToConfig.xml"

declare    lmstest_logDir="$lmsbase_dirAppLog"
declare    lmstest_logName="test.log"
declare    lmstest_logFile="${lmstest_logDir}/${lmstest_logName}"

declare -i lmstest_result=0

# *****************************************************************************

# *****************************************************************************
#
#	updateCliOptions
#
#		Read the cli options and set in lmstest_xxxxOptions
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function updateCliOptions()
{
	lmsXCfgLoad ${lmstest_cliOptions} "lmsxmlconfig"
	lmstest_result=$?
	[[ $lmstest_result -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "ConfigXmlError" "lmsXCfgLoad '${lmstest_Declarations}'"
		return 1
	 }

	lmsCliParse
	lmstest_result=$?
	[[ $lmstest_result -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "ParamError" "cliParameterParse failed"
		return 2
	 }

	[[ ${lmscli_Errors} -eq 0 ]] &&
	 {
		lmsCliApply
		lmstest_result=$?
		[[ $lmstest_result -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "ParamError" "lmsCliApply failed." 
			return 3
		 }
	 }

	if [[ $lmscli_debugOptions -ne 0 ]] 
	then
		declare -p | grep lmscli_
		lmsConioDisplay ""
	fi

	return 0
}

# *****************************************************************************
#
#	updateLogFileName
#
#		Read the cli logDir and LogName options and create a log file name
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function updateLogFileName()
{
	lmstest_logDir="${lmstest_logDir}"
	lmstest_logName="${lmsscr_Name}.log"

	lmstest_logFile="${lmstest_logDir}/${lmstest_logName}"
	lmsConioDebug $LINENO "Debug" "Log file name: $lmstest_logFile"

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

lmsHelpInit ${lmsvar_help}

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0				# (b) Batch mode - missing parameters fail
lmscli_optQuiet=0				# set to 1 to lmscli_optOverride the lmscli_optSilent flag
lmscli_optQueueErrors=0

updateCliOptions
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "Debug" "($lmstest_result) updateCliOptions failed"
	exit 1
 }

updateLogFileName
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "Debug" "($lmstest_result) Unable to open log file: '${lmstest_logFile}'"
	exit 1
 }

lmsLogClose

lmsLogOpen "${lmstest_logFile}" "new"
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsConioDebug $LINENO "Debug" "($lmstest_result) Unable to open log file: '${lmstest_logFile}'"
	exit 1
 }

lmsConioDisplay "  Log-file: ${lmstest_logFile}"
lmsConioDisplay ""

lmsXPathSelect ${lmserr_arrayName}
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "Debug" "($lmstest_result) Unable to select ${lmserr_arrayName}"
	exit 1
 }

# *****************************************************************************

lmsDomRInit
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "DomError" "lmsDomRInit failed."
	exit 1
 }

lmsConioDisplay "  Building DOM tree"
lmsConioDisplay ""

lmsDomDParse ${lmstest_cliOptions}
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "DomError" "lmsDomDParse '${lmstest_cliOptions}'"
	exit 1
 }

[[ $lmscli_optDebug -eq 0 ]] ||
 {
	lBuffer=$( lmsDomToStr )
	lmstest_result=$?
	[[ $lmstest_result -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DomError" "lmsDomTCConfig failed."
		exit 1
	 }

	echo "$lBuffer"
 }

lmsConioDisplay "  Finished building DOM Tree"
lmsConioDisplay ""

echo ""
declare -p | grep lmsdom_
echo ""

lmsConioDisplay "  Deleting DOM Tree"
lmsConioDisplay ""

lmsDomDTDelete "${lmsdom_docTree}"
lmstest_result=$?
[[ $lmstest_result -eq 0 ]] ||
 {
	lmsLogDebugMessage $LINENO "DomError" "Unable to delete the specified dom tree: '$lmsdom_docTree'"
 }

lmsConioDisplay "  DOM Tree has been deleted(?)"
lmsConioDisplay ""

echo ""
declare -p | grep lmsdom_
echo ""

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
