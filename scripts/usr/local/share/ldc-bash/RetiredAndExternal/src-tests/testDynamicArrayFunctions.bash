#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testDynamicArrayFunctions.bash
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage tests
#
# *****************************************************************************
#
#	Copyright © 2016. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 03-14-2016.
#					0.0.2 - 06-03-2016
#					0.0.2 - 09-02-2016
#
# *****************************************************************************
# *****************************************************************************

# *******************************************************
# *******************************************************
#
#		External Scripts
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
. $libDir/lmsDynNode.bash
. $libDir/lmsDynArray.bash

. $libDir/lmsDynArray.bash
. $libDir/lmsDynNode.bash

. $libDir/lmsError.bash
. $libDir/errorQueueDisplay.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsHelp.bash
. $libDir/lmsLog.bash
. $libDir/lmsLogRead.bash
. $libDir/lmsScriptName.bash
. $libDir/lmsStack.bash
. $libDir/lmsStartup.bash
. $libDir/lmsStr.bash
. $libDir/lmsUId
. $libDir/lmsUtilities.bash
. $libDir/lmsXMLParse
. $libDir/lmsXPath.bash

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************

lmsscr_Version="0.0.2"					# script version
lmsvar_errors="$etcDir/errorCodes.xml"
lmsvar_help="$etcDir/testHelp.xml"			# path to the help information file

# *******************************************************
# *******************************************************
#
#		Application Functions
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#	arrayTests
#
#		Array Tests
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *******************************************************
function arrayTests()
{
	local arrayType=${1:-"a"}

	local string=""
	local name=""
	local key=""
	local value=""
	local index=0

	declare -a array_names=("bob" "jane" "dick")
	
	if [[ "${arrayType}" == "a" ]]
	then
		declare -a array_keys=(0 1 2)
	else
		declare -a array_keys=("abc" "def" "ghi")
	fi

	declare -a arrayValues=( "one'" "two" "three" )

	# **************************************************************************************************

	for name in "${array_names[@]}"
	do
		lmsConioDisplay "Creating Associative array ${name}"

		lmsDynaNew dyn_${name} ${arrayType}
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebugExit $LINENO "Debug" "Unable to create dynamic associative array '${name}'"
		 }
	done

	lmsConioDisplay
	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	declare -${arrayType} | grep "${arrayType} dyn_"

	lmsConioDisplay
	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	for name in "${array_names[@]}"
	do
		index=0
		for key in "${array_keys[@]}"
		do
			lmsConioDisplay "Adding dyn_$name [ $key ] = '${arrayValues[$index]}'"
			
			lmsDynaAdd dyn_${name} "${arrayValues[$index]}" ${key}
			[[ $? -eq 0 ]] ||
			 {
				lmsConioDebugExit $LINENO "Debug" "unable to add dyn_${name}"
			 }

			(( index++ ))

		done

   		lmsConioDisplay ""
	done

	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	declare -${arrayType} | grep "$arrayType dyn_"

	lmsConioDisplay
	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	for name in "${array_names[@]}"
	do
		for key in "${array_keys[@]}"
		do
			lmsConioDisplay "Setting dyn_$name [ $key ] = first+$key"
			dynArraySetAt dyn_${name} "$key" "first+$key"
			[[ $? -eq 0 ]] ||
			 {
				lmsConioDebugExit $LINENO "Debug" "unable to set dyn_${name}"
			 }
		done

   		lmsConioDisplay ""
	done

	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	declare -${arrayType} | grep "${arrayType} dyn_"

	lmsConioDisplay
	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	lmsConioDisplay "Listing dyn_"

	for name in "${array_names[@]}"
	do
		string=$( dynArrayGet "dyn_$name" )
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

		string=$( dynArrayKeys "dyn_${name}" )

		for key in ${string}
		do
			lmsDynaGetAt dyn_${name} ${key} value
			[[ $? -eq 0 ]] ||
			 {
				lmsConioDebugExit $LINENO "Debug" "unable to get dyn_${name} [$key]"
			 }

			lmsConioDisplay "    dyn_$name[$key]: $value"
		done

		lmsConioDisplay ""
	done

	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	for name in "${array_names[@]}"
	do
		lmsConioDisplay "Dumping dyn_$name"
		for value in $(dynArrayGet dyn_$name)
		do
			lmsConioDisplay "    ${value}"
		done

   		lmsConioDisplay ""
	done

	lmsConioDisplay "*******************************************"
	lmsConioDisplay

	for name in "${array_names[@]}"
	do
		lmsConioDisplay "Deleting dyn_$name"

   		dynArrayUnset dyn_$name
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "DynArrayError" "dynArrayUnset 'dyn_$name' failed."
			return 1
		 }
	done

	#unset array_names array_keys arrayValues
	string=""

	declare -${arrayType} | grep "$arrayType dyn_"
	if [ $? -eq 0 ]
	then
		lmsConioDisplay
		lmsConioDisplay "*******************************************"
		lmsConioDisplay

		lmsConioDisplay "Apparition: deleted all dyn_ but still some left!"
	fi

	return 0
}

# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************

lmsStartupInit "${lmsscr_Version}" "${lmsvar_errors}"

lmsConioDisplay "*******************************************"
lmsConioDisplay "*******************************************"
lmsConioDisplay "*"
lmsConioDisplay "*	         Array Tests"
lmsConioDisplay "*"
lmsConioDisplay "*******************************************"
lmsConioDisplay "*******************************************"

arrayTests "a"


lmsConioDisplay "*******************************************"
lmsConioDisplay "*******************************************"
lmsConioDisplay "*"
lmsConioDisplay "*	    Associative Array Tests"
lmsConioDisplay "*"
lmsConioDisplay "*******************************************"
lmsConioDisplay "*******************************************"

arrayTests "A"

if [ $lmscli_optDebug -ne 0 ]
then
	lmsConioDisplay ""
	lmsConioDisplay "*******************************************"
	lmsConioDisplay ""

	lmsErrorQDispPop
fi

lmsConioDisplay ""
lmsConioDisplay "*******************************************"
lmsConioDisplay ""


lmsConioDisplay ""
lmsConioDisplay "*******************************************"
lmsConioDisplay ""

#lmsConioDebugExit $LINENO "Debug" "end of test" 1

lmsErrorExitScript "EndOfTest"


