#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testXmlSimpleParse.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 05-28-2016.
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
#    	External Scripts
#
# *******************************************************
# *******************************************************

declare -i lmscli_optProduction=1

if [ $lmscli_optProduction -eq 0 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/lms/bash"
	lmsvar_errors="$rootDir/etc/lms/errorCodes.xml"
	lmsvar_help="$rootDir/etc/lms/lmsInstallScriptHelp.xml"
	lmsVariables="$rootDir/etc/lms/lmsInstallScript.xml"	# where to get variables/settings
	testXmlVars="$rootDir/etc/lms/testVariables.xml"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	lmsvar_errors="$rootDir/etc/errorCodes.xml"
	lmsvar_help="$rootDir/etc/shellHelp.xml"
	scriptVariables="$rootDir/etc/shellVariables.xml"
	testXmlVars="$rootDir/etc/testVariables.xml"
fi

. $libDir/arraySort.bash
. $libDir/runtimeUser.bash
. $libDir/lmsConio.bash
. $libDir/lmsCli.bash
. $libDir/lmsError.bash
. $libDir/errorQueueDisplay.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsScriptName.bash
. $libDir/setupErrorCodes.bash
. $libDir/lmsDeclare.bash
. $libDir/lmsStack.bash
. $libDir/lmsStartup.bash
. $libDir/lmsStr.bash
. $libDir/lmsUId
. $libDir/xmlParser.bash
. $libDir/xmlSimpleParse.bash

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************
lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag

lmsscr_Version="0.0.1"		# Application version

# *******************************************************
# *******************************************************
#
#		Start main program functions below here
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
#		Start main program script below here
#
# *******************************************************
# *******************************************************

lmscli_Validate=1

lmscli_ParameterBuffer=( "$@" )
lmsErrorInitialize
echo "parseXML"

parseXML $testXmlVars
if [ $? -ne 0 ]
then
	dumpNameTable
	lmsErrorExitScript Unknown
fi

echo "$status_test_xyz |  $status_test_abc |  $status_test_pqr" #Variables for each  XML ELement
echo "$status_test_xyz_arg1 |  $status_test_abc_arg2 |  $status_test_pqr_arg3 | $status_test_pqr_arg4" #Variables for each XML Attribute
echo ""

dumpNameTable
lmsConioDisplay "**************************"

#All the variables that were produced by the parseXML function
set | /bin/grep -e "^$prefix" 

$LINENO "EndOfTest"
