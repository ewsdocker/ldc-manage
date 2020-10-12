#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testDynamicArrayFunctions.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 07-19-2016.
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

declare -i lmscli_optProduction=0

if [ $lmscli_optProduction -eq 1 ]
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
. $libDir/lmsCli.bash
. $libDir/lmsColorDef.bash
. $libDir/lmsConio.bash
. $libDir/lmsDmpVar
. $libDir/dynamicArrayAssociative.bash
. $libDir/lmsDynNode.bash
. $libDir/lmsDynArray.bash
. $libDir/lmsError.bash
. $libDir/errorQueueDisplay.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsHelp.bash
. $libDir/lmsScriptName.bash
. $libDir/lmsStack.bash
. $libDir/lmsStartup.bash
. $libDir/lmsStr.bash
. $libDir/lmsUId
. $libDir/lmsXMLParse
. $libDir/lmsXPath.bash

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************

lmsscr_Version="0.0.1"					# script version
lmsvar_errors="$etcDir/errorCodes.xml"
lmsvar_help="$etcDir/testHelp.xml"			# path to the help information file

# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************

lmsStartupInit "${lmsscr_Version}" "${lmsvar_errors}"

lmsConioDisplay "*******************************************"

declare name="bob"
declare bob="crane"

lmsConioDisplay
lmsConioDisplay "validity check:"

declare -p name
declare -p bob

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

array_names=(bob jane dick)

for name in "${array_names[@]}"
do
dynAssocCreate dyn_${name} 1
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "Unable to create dynamic associative array '${name}'"
	 }
done

declare -A | grep "A dyn_"

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

for name in "${array_names[@]}"
do
    lmsConioDisplay "Adding dyn_$name abc one"
	dynAssocAdd dyn_${name} "abc" "one"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "unable to add dyn_${name}"
	 }

    lmsConioDisplay "Adding dyn_$name def two"
	dynAssocAdd dyn_${name} "def" "two"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "unable to add dyn_${name}"
	 }

    lmsConioDisplay "Adding dyn_$name ghi three"
	dynAssocAdd dyn_${name} "ghi" "three"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "unable to add dyn_${name}"
	 }
done

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

declare -A | grep 'A dyn_'

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

for name in "${array_names[@]}"
do
    lmsConioDisplay "Setting dyn_$name["one"]=first"
    dynAssocSetAt dyn_${name} "one" "first"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "unable to set dyn_${name}"
	 }

    lmsConioDisplay "Setting dyn_$name["two"]=third"
    dynAssocSetAt dyn_$name "two" "third"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "unable to set dyn_${name}"
	 }
done

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

declare -A | grep 'A dyn_'

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

lmsConioDisplay "Listing dyn_"

for name in "${array_names[@]}"
do
    string=$( dynAssocGet "dyn_$name" )
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebugExit $LINENO "Debug" "unable to get dyn_${name}"
	 }
	
	lmsConioDisplay "${name} = ${string}"
done

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

for name in "${array_names[@]}"
do
    lmsConioDisplay "Dumping dyn_$name by index"

	string=$( dynAssocKeys "dyn_${name}" )

	for key in ${string}
    do
    	value=$( dynAssocGetAt dyn_${name} ${key} )
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebugExit $LINENO "Debug" "unable to get dyn_${name} [$key]"
		 }

        lmsConioDisplay "    dyn_$name[$key]: $value"
	done
done

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

for name in "${array_names[@]}"
do
    lmsConioDisplay "Dumping dyn_$name"
    for n in $(dynAssocGet dyn_$name)
    do
        lmsConioDisplay $n
    done
done

lmsConioDisplay
lmsConioDisplay "*******************************************"
lmsConioDisplay

let count=$(dynAssocCount dyn_${name})

lmsConioDisplay "Deleting $count entries"

while [ $count -gt 0 ]
do
	let count-=1
	name=${array_names[$count]}
    lmsConioDisplay "Deleting dyn_$name"

    dynAssocUnset dyn_$name
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "DynArrayError" "dynAssocUnset failed."
		exitError "Unknown"
	 }

	unset array_names[$count]	
done

unset array_names

declare -a | grep 'a dyn_'
if [ $? -eq 0 ]
then
	lmsConioDisplay "Apparition: deleted all dyn_ but still some left!"
fi

# *******************************************************

if [ $lmscli_optDebug -ne 0 ]
then
	lmsErrorQDispPop
fi

#lmsConioDebugExit $LINENO "Debug" "end of test" 1

lmsErrorExitScript "EndOfTest"
