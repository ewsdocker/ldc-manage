#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcLogRead.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1
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
#		Version 0.0.1 - 09-02-2016.
#				0.1.0 - 01-17-2017.
#				0.1.1 - 02-09-2017.
#
# *****************************************************************************
# *****************************************************************************

testlibDir="../../testlib"

. $testlibDir/installDirs.sh

. $testlibDir/stdLibs.sh

. $testlibDir/cliOptions.sh
. $testlibDir/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.1.1"	# script version

declare    ldctst_Declarations="$etcDir/ldc-testOptions.xml"
declare    ldctst_cliOptions="$etcDir/cliOptions.xml"

declare    ldctst_logName="/var/local/log/ldc-test/testLdcLog.log"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $testlibDir/testDump.sh
. $testlibDir/testUtilities.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

ldcScriptFileName $0

. $testlibDir/openLog.sh
. $testlibDir/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

ldccli_optDebug=0

ldcConioDisplay "Initializing parameters from configuration files."
ldcConioDisplay ""

# *****************************************************************************
#
#	Load configuration from cliOptions.xml
#
# *****************************************************************************

	ldcXCfgLoad ${ldctst_cliOptions} "ldcxmlconfig"
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "ldcXCfgLoad '${ldctst_Declarations}'"
		ldcErrorExitScript "ConfigXmlError"
	 }

	# *************************************************************************

ldcConioDisplay "calling ldcCliParse"

	ldcCliParse 0
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "cliParameterParse failed"
		ldcErrorExitScript "ParamError"
	 }

	# *************************************************************************

echo "Errors: '$ldccli_Errors'"

	[[ ${ldccli_Errors} -eq 0 ]] &&
	 {
		ldcCliApply
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDisplay "ldcCliApply failed." 
			ldcErrorExitScript "ParamError"
		 }
	 }

	ldcCliLookup "logname" ldctst_logNameOption
	[[ $? -eq 0 ]] ||
	{
		ldcConioDisplay "ldcCliValid failed for logname"
testLdcDmpVar "ldccli_ ldctest_"
		ldcErrorExitScript "ParamError"
	}

	eval 'ldctst_logName=$'"ldccli_${ldctst_logNameOption}"

	if [ -z "${ldctst_logName}" ]
	then
		ldcConioDisplay "Missing log file name"
		ldcErrorExitScript "ParamError"
	fi

	[[ -n "$ldccli_optLogDir" ]] && ldctst_logName="${ldccli_optLogDir}${ldctst_logName}"

# *****************************************************************************

ldcConioDisplay "-------------------------------"
ldcConioDisplay ""
ldcConioDisplay "Opening log: $ldctst_logName"
ldcConioDisplay ""

ldcLogReadOpen "${ldctst_logName}"
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "ldcLogReadOpen failed ($?)."
	ldcErrorExitScript "LogError"
 }

ldcConioDisplay "Log file successfully opened."
ldcConioDisplay "-------------------------------"
ldcConioDisplay ""

ldccli_optDebug=0
ldccli_optLogDisplay=0

ldcConioDisplay "Reading log: $ldctst_logName"
ldcConioDisplay ""

ldcLogRead
[[ $? -eq 0 ]] ||
{
	ldcerr_result=$?
	[[ $ldcerr_result -eq 0 ]] ||
	 {
		ldcConioDisplay "ldcLogRead failed, result = ${ldcerr_result}."
		ldcErrorExitScript "LogError"
	 }
}

ldcConioDisplay "Reading complete"
ldcConioDisplay "-------------------------------"
ldcConioDisplay ""

ldcConioDisplay "Closing log: $ldctst_logName"
ldcConioDisplay ""

ldcLogReadClose

# *****************************************************************************

. $testlibDir/testEnd.sh

# *****************************************************************************
