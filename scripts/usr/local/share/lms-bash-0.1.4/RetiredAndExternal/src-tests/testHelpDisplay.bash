#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testLmsCli.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 02-24-2016.
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
	etcDir="$rootDir/etc/lms"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/arraySort.bash
. $libDir/runtimeUser.bash
. $libDir/lmsConio.bash
. $libDir/lmsCli.bash
. $libDir/lmsError.bash
. $libDir/errorQueueDisplay.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsScriptName.bash
. $libDir/lmsDeclare.bash
. $libDir/lmsStack.bash
. $libDir/lmsStartup.bash
. $libDir/lmsStr.bash
. $libDir/lmsUId
. $libDir/xmlParser.bash
. $libDir/lmsXPath.bash

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************

lmsscr_Version="0.0.1"		# script version
lmsvar_errors="$etcDir/errorCodes.xml"

# *******************************************************
# *******************************************************
#
#		Application Script below here
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

lmscli_optDebug=1

# *******************************************************
# *******************************************************

initializeErrorCodes

displayApplicationName

displayHelp

exitScript Error_None
