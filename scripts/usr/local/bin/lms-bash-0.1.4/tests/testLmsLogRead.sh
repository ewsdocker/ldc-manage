#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLmsLogRead.sh
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

declare    lmsscr_Version="0.1.1"	# script version

declare    lmstst_Declarations="$etcDir/lms-testOptions.xml"
declare    lmstst_cliOptions="$etcDir/cliOptions.xml"

declare    lmstst_logName="/var/local/log/lms-test/testLmsLog.log"

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

lmsScriptFileName $0

. $testlibDir/openLog.sh
. $testlibDir/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

lmscli_optDebug=0

lmsConioDisplay "Initializing parameters from configuration files."
lmsConioDisplay ""

# *****************************************************************************
#
#	Load configuration from cliOptions.xml
#
# *****************************************************************************

	lmsXCfgLoad ${lmstst_cliOptions} "lmsxmlconfig"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsXCfgLoad '${lmstst_Declarations}'"
		lmsErrorExitScript "ConfigXmlError"
	 }

	# *************************************************************************

lmsConioDisplay "calling lmsCliParse"

	lmsCliParse 0
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "cliParameterParse failed"
		lmsErrorExitScript "ParamError"
	 }

	# *************************************************************************

echo "Errors: '$lmscli_Errors'"

	[[ ${lmscli_Errors} -eq 0 ]] &&
	 {
		lmsCliApply
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDisplay "lmsCliApply failed." 
			lmsErrorExitScript "ParamError"
		 }
	 }

	lmsCliLookup "logname" lmstst_logNameOption
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "lmsCliValid failed for logname"
testLmsDmpVar "lmscli_ lmstest_"
		lmsErrorExitScript "ParamError"
	}

	eval 'lmstst_logName=$'"lmscli_${lmstst_logNameOption}"

	if [ -z "${lmstst_logName}" ]
	then
		lmsConioDisplay "Missing log file name"
		lmsErrorExitScript "ParamError"
	fi

	[[ -n "$lmscli_optLogDir" ]] && lmstst_logName="${lmscli_optLogDir}${lmstst_logName}"

# *****************************************************************************

lmsConioDisplay "-------------------------------"
lmsConioDisplay ""
lmsConioDisplay "Opening log: $lmstst_logName"
lmsConioDisplay ""

lmsLogReadOpen "${lmstst_logName}"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "lmsLogReadOpen failed ($?)."
	lmsErrorExitScript "LogError"
 }

lmsConioDisplay "Log file successfully opened."
lmsConioDisplay "-------------------------------"
lmsConioDisplay ""

lmscli_optDebug=0
lmscli_optLogDisplay=0

lmsConioDisplay "Reading log: $lmstst_logName"
lmsConioDisplay ""

lmsLogRead
[[ $? -eq 0 ]] ||
{
	lmserr_result=$?
	[[ $lmserr_result -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsLogRead failed, result = ${lmserr_result}."
		lmsErrorExitScript "LogError"
	 }
}

lmsConioDisplay "Reading complete"
lmsConioDisplay "-------------------------------"
lmsConioDisplay ""

lmsConioDisplay "Closing log: $lmstst_logName"
lmsConioDisplay ""

lmsLogReadClose

# *****************************************************************************

. $testlibDir/testEnd.sh

# *****************************************************************************
