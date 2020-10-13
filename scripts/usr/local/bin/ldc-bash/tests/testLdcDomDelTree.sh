#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLdcDomDelTree.sh
#
#	Test ability to correctly delete a DOM tree created by the ldcDomRRead library.
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

declare    ldcapp_name="testLdcDomDelTree"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.0.3"						# script version
declare    ldcapp_errors="$ldcbase_dirEtc/errorCodes.xml"
declare    ldcvar_help="$ldcbase_dirEtc/testHelp.xml"			# path to the help information file

declare	   ldctest_cliOptions="$ldcbase_dirEtc/testDOMToConfig.xml"

declare    ldctest_logDir="$ldcbase_dirAppLog"
declare    ldctest_logName="test.log"
declare    ldctest_logFile="${ldctest_logDir}/${ldctest_logName}"

declare -i ldctest_result=0

# *****************************************************************************

# *****************************************************************************
#
#	updateCliOptions
#
#		Read the cli options and set in ldctest_xxxxOptions
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
	ldcXCfgLoad ${ldctest_cliOptions} "ldcxmlconfig"
	ldctest_result=$?
	[[ $ldctest_result -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "ConfigXmlError" "ldcXCfgLoad '${ldctest_Declarations}'"
		return 1
	 }

	ldcCliParse
	ldctest_result=$?
	[[ $ldctest_result -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "ParamError" "cliParameterParse failed"
		return 2
	 }

	[[ ${ldccli_Errors} -eq 0 ]] &&
	 {
		ldcCliApply
		ldctest_result=$?
		[[ $ldctest_result -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "ParamError" "ldcCliApply failed." 
			return 3
		 }
	 }

	if [[ $ldccli_debugOptions -ne 0 ]] 
	then
		declare -p | grep ldccli_
		ldcConioDisplay ""
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
	ldctest_logDir="${ldctest_logDir}"
	ldctest_logName="${ldcscr_Name}.log"

	ldctest_logFile="${ldctest_logDir}/${ldctest_logName}"
	ldcConioDebug $LINENO "Debug" "Log file name: $ldctest_logFile"

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

ldcHelpInit ${ldcvar_help}

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

ldccli_optDebug=0				# (d) Debug output if not 0
ldccli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
ldccli_optBatch=0				# (b) Batch mode - missing parameters fail
ldccli_optQuiet=0				# set to 1 to ldccli_optOverride the ldccli_optSilent flag
ldccli_optQueueErrors=0

updateCliOptions
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "Debug" "($ldctest_result) updateCliOptions failed"
	exit 1
 }

updateLogFileName
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "Debug" "($ldctest_result) Unable to open log file: '${ldctest_logFile}'"
	exit 1
 }

ldcLogClose

ldcLogOpen "${ldctest_logFile}" "new"
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcConioDebug $LINENO "Debug" "($ldctest_result) Unable to open log file: '${ldctest_logFile}'"
	exit 1
 }

ldcConioDisplay "  Log-file: ${ldctest_logFile}"
ldcConioDisplay ""

ldcXPathSelect ${ldcerr_arrayName}
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "Debug" "($ldctest_result) Unable to select ${ldcerr_arrayName}"
	exit 1
 }

# *****************************************************************************

ldcDomRInit
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "DomError" "ldcDomRInit failed."
	exit 1
 }

ldcConioDisplay "  Building DOM tree"
ldcConioDisplay ""

ldcDomDParse ${ldctest_cliOptions}
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "DomError" "ldcDomDParse '${ldctest_cliOptions}'"
	exit 1
 }

[[ $ldccli_optDebug -eq 0 ]] ||
 {
	lBuffer=$( ldcDomToStr )
	ldctest_result=$?
	[[ $ldctest_result -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DomError" "ldcDomTCConfig failed."
		exit 1
	 }

	echo "$lBuffer"
 }

ldcConioDisplay "  Finished building DOM Tree"
ldcConioDisplay ""

echo ""
declare -p | grep ldcdom_
echo ""

ldcConioDisplay "  Deleting DOM Tree"
ldcConioDisplay ""

ldcDomDTDelete "${ldcdom_docTree}"
ldctest_result=$?
[[ $ldctest_result -eq 0 ]] ||
 {
	ldcLogDebugMessage $LINENO "DomError" "Unable to delete the specified dom tree: '$ldcdom_docTree'"
 }

ldcConioDisplay "  DOM Tree has been deleted(?)"
ldcConioDisplay ""

echo ""
declare -p | grep ldcdom_
echo ""

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
