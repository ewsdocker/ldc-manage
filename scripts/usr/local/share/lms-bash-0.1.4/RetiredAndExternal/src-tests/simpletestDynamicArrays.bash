#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testDynamicArrays.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 03-14-2016.
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

initializeErrorCodes

lmsConioDisplay ""
displayApplicationName

# *******************************************************

lmscli_optDebug=0

array_names=(bob jane dick)

for name in "${array_names[@]}"
do
    dynArrayNew dyn_$name
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }
done

echo "Arrays Created"

declare -a | grep "a dyn_"

#
# 	Insert three items per array
#
for name in "${array_names[@]}"
do
    lmsConioDisplay "Inserting dyn_$name abc"
    dynArrayInsert dyn_$name "abc"
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }

    lmsConioDisplay "Inserting dyn_$name def"
    dynArrayInsert dyn_$name "def"
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }

    lmsConioDisplay "Inserting dyn_$name ghi"
    dynArrayInsert dyn_$name "ghi"
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }
done

for name in "${array_names[@]}"
do
    lmsConioDisplay "Setting dyn_$name[0]=first"
    dynArraySet dyn_$name 0 "first"
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }

    lmsConioDisplay "Setting dyn_$name[2]=third"
    dynArraySet dyn_$name 2 "third"
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }
done

declare -a | grep 'a dyn_'

for name in "${array_names[@]}"
do
    dynArrayGet dyn_$name
	[[ dynArrayError -eq 0 ]] ||
	 {
		lmsConioDisplay "$(dynArrayGetError)"
		exitError Error_Unknown
	 }
done

for name in "${array_names[@]}"
do
    lmsConioDisplay "Dumping dyn_$name by index"

    # Print by index
    for (( i=0 ; i < $(dynArrayCount dyn_$name) ; i++ ))
    do
        lmsConioDisplay "dyn_$name[$i]: $(dynArrayGetAt dyn_$name $i)"
		[[ dynArrayError -eq 0 ]] ||
		 {
			lmsConioDisplay "$(dynArrayGetError)"
			exitError Error_Unknown
		 }
        done
done

for name in "${array_names[@]}"
do
    lmsConioDisplay "Dumping dyn_$name"
    for n in $(dynArrayGet dyn_$name)
    do
        lmsConioDisplay $n
    done
done

lmscli_optDebug=0

declare deletedValue="<unknown>"

for name in "${array_names[@]}"
do
    lmsConioDisplay "Deleting dyn_$name by index"

    index=$(dynArrayCount dyn_$name)
    while (( $index > 0 ))
    do
    	let index-=1

		lmsConioDisplay "   deleting 'dyn_$name' item '$index'" -n

		deletedValue=$(dynArrayDeleteAt dyn_$name $index)
		if [[ dynArrayError -ne 0 ]]
		then
			lmsConioDisplay ""
			lmsConioDisplay "$(dynArrayGetError)"
			dumpNameTable
			lmsConioDisplay "Unable to delete item $index in dyn_$name"
			exitScript Error_Unknown
		fi

		lmsConioDisplay " = '${deletedValue}'"

       	index=$(dynArrayCount dyn_$name)
		if [[ dynArrayError -ne 0 ]]
		then
			lmsConioDisplay "$(dynArrayGetError)"
			exitScript Error_Unknown
		fi

dumpNameTable
exit 1
		break
    done

    lmsConioDisplay "Removing array dyn_$name"
    dynArrayUnset dyn_$name
done

# *******************************************************

lmscli_optDebug=0
#dumpNameTable

exitScript Error_None

# *******************************************************

