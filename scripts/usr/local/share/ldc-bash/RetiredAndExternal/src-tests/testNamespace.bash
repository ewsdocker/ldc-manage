#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testNamespace.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 03-07-2016.
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
lmscli_optOverride=0					# set to 1 to lmscli_optOverride the lmscli_optSilent flag
lmscli_optNoReset=0			# not automatic reset of lmscli_optOverride if 1

applicationVersion="1.0"	# Application version

# *******************************************************

declare nsUid=""
declare namespace
declare -i nsLen

declare testNames=( global lmscli_optProduction configuration database )

# *******************************************************

lmsErrorInitialize
lmsErrorQInit
if [ $? -ne 0 ]
then
	lmsConioDisplay "Unable to initialize error queue stacks"
	exit 1
fi

lmscli_optOverride=1
lmscli_optNoReset=1

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsScriptDisplayName
lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

namespaceLength nsLen
lmsConioDisplay "Current namespace name length = ${nsLen} " -n

namespaceLength nsLen 8
lmsConioDisplay "changed to ${nsLen}"

lmsConioDisplay ""

for name in ${testNames[@]}
do
	lmsConioDisplay "Adding namespace $name = " -n
	namespaceSet nsUid "${name}"
	if [ $? -ne 0 ]
	then
		lmsConioDisplay "unable to set namespace"
	fi

	lmsConioDisplay "${nsUid}"
done

lmsConioDisplay ""

namespaceDumpTable

lmsConioDisplay ""

for name in ${testNames[@]}
do
	lmsConioDisplay "Looking up namespace $name = " -n
	namespaceGet nsUid "${name}"
	if [ $? -ne 0 ]
	then
		lmsConioDisplay "unable to get namespace"
	fi

	lmsConioDisplay "${nsUid}"
done

lmsErrorExitScript None
