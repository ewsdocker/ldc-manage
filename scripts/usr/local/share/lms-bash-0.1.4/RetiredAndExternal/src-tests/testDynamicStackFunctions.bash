#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testDynamicStackFunctions.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 03-15-2016.
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

# *******************************************************
#
#	runTest
#
# *******************************************************
function runTest()
{
	dynStackNew "testStack"
	if (( dynStackError != 0 ))
	then
		lmsConioDisplay "*****   $(dynStackGetError)"
		return 1
	fi

	for name in ${testNames[@]}
	do
		lmsConioDisplay "Adding '$name' - " -n

		dynStackPush "testStack" "${name}"
		if [ $? -ne 0 ]
		then
			lmsConioDisplay "$(dynStackGetError)"
			return 1
		fi

		lmsConioDisplay "added"
		lmsConioDisplay "stack size: $(dynStackSize 'testStack')"

		stackBuffer=""
		dynStackToString "testStack" stackBuffer
		lmsConioDisplay "$stackBuffer"

		lmsConioDisplay "+++++++++++++++++++++"
	done

	stackCount=$(dynStackSize 'testStack')
	if (( $stackCount < 0 ))
	then
		lmsConioDisplay "$(dynStackGetError)"
	fi

	lmsConioDisplay "Stack size: $stackCount"

	stackBuffer=""
	dynStackToString 'testStack' stackBuffer
	lmsConioDisplay "$stackBuffer"

	lmsConioDisplay "+++++++++++++++++++++"

	stackCount=$(dynStackSize 'testStack')

	while true
	do
		lmsConioDisplay "Stack size: $stackCount"
		[[ $stackCount > 0 ]] || break
		lmsConioDisplay "Popping stack"

		dynStackPop "testStack" value
		if [ $? -ne 0 ]
		then
			if [ $? -eq 1 ]
			then
				lmsConioDisplay "unable to pop the stack"
			else
				lmsConioDisplay "empty stack"
			fi

			break
		fi

		stackBuffer=""
		dynStackToString "testStack" stackBuffer
		lmsConioDisplay "$stackBuffer"

		stackCount=$(dynStackSize 'testStack')
	done

	stackCount=$(dynStackSize 'testStack')
	lmsConioDisplay "Stack size: $stackCount"

	stackBuffer=""
	dynStackToString "testStack" stackBuffer
	lmsConioDisplay "$stackBuffer"

	dynStackDelete "testStack"
	
	return 0
}

# *******************************************************
# *******************************************************
#
#		The BODY of the Script begins here
#
# *******************************************************
# *******************************************************

declare -i stackCount

declare -a testNames=( global lmscli_optProduction configuration database )
declare name
declare value

declare stackBuffer=""
declare -i stackCount=0

# *******************************************************

initializeErrorCodes

lmscli_optOverride=1
lmscli_optNoReset=1

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
displayApplicationName
lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

# *******************************************************

lmscli_optDebug=0
runTest
testResult=$?

lmsConioDisplay "*********************"

#dumpNameTable

lmscli_optDebug=0

if [ $testResult -ne 0 ]
then
	exitScript Error_Unknown
fi

exitScript Error_None
