#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testXmlNaiveParser.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 02-28-2016.
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
	shellVariables="$rootDir/etc/lms/shellVariables.xml"	# where to get variables/settings
	lmsvar_help="$root/etc/lms/shellVariablesHelp.xml"
	audioTest="$root/etc/lms/AudioControl.xml"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	lmsvar_errors="$rootDir/etc/errorCodes.xml"
	shellVariables="$rootDir/etc/shellVariables.xml"
	lmsvar_help="$rootDir/etc/shellVariablesHelp.xml"
	audioTest="$root/etc/AudioControl.xml"
fi

. $libDir/lmsUId
. $libDir/namespace.bash
. $libDir/lmsDeclare.bash
. $libDir/lmsStr.bash
. $libDir/lmsScriptName.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsError.bash
. $libDir/lmsConio.bash
. $libDir/setupErrorCodes.bash
. $libDir/lmsStack.bash
. $libDir/xmlParser.bash
. $libDir/errorQueueDisplay.bash

# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
#		Start main program below here
#
# *******************************************************
# *******************************************************

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag

applicationVersion="1.0"	# Application version

# *******************************************************
# *******************************************************

lmsErrorInitialize
lmsErrorQInit
if [ $? -ne 0 ]
then
	lmsConioDisplay "Unable to initialize error queue."
	exit 1
fi

lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsScriptDisplayName

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

#loadXmlData $shellVariables
#loadXmlData "$rootDir/etc/lmsInstallScript.xml"
loadXmlData "$rootDir/etc/lmsInstallScriptHelp.xml"

dumpNameTable

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""



lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

if [ $lmscli_optDebug -ne 0 ]
then
	lmsErrorQDispPop
fi

$LINENO "EndOfTest"
