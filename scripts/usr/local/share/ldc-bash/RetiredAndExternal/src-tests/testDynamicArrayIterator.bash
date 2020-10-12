#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testDynamicArrayIterator.bash
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
#			Version 0.0.1 - 06-13-2016
#					0.0.2 - 08-07-2016.
#
# *****************************************************************************
# *****************************************************************************

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
. $libDir/lmsDynNode.bash
. $libDir/lmsDynArray.bash
. $libDir/lmsError.bash
. $libDir/errorQueueDisplay.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsHelp.bash
. $libDir/lmsLog.bash
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
#		Application Script below here
#
# *******************************************************
# *******************************************************

lmsStartupInit "${lmsscr_Version}" "${lmsvar_errors}"

lmsConioDisplay "*******************************************"

dynArrayITReset "${lmserr_arrayName}"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "dynArrayITReset failed."
	exit 1
 }

dynArrayITValid "${lmserr_arrayName}"
while [ $? -eq 0 ]
do
	value=$( dynArrayITGet "${lmserr_arrayName}" )
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "dynArrayITGet failed."
		break
	}
	
	index=${lmsdyn_arrays[${lmserr_arrayName}]}

	lmsConioDisplay "${index} = ${value}"

	dynArrayITNext "${lmserr_arrayName}"
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "dynArrayITNext failed."
		break
	}
	
	dynArrayITValid "${lmserr_arrayName}"
done

lmsConioDisplay ""
lmsConioDisplay "***************  Mapped Index  ***************"
lmsConioDisplay ""

lmsdyn_arrays[${#lmsdyn_arrays[@]}]="lmserr_codesName"

dynArrayITReset "${lmserr_codesName}"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "dynArrayITReset failed."
	exit 1
 }

dynArrayITValid "${lmserr_codesName}"
while [ $? -eq 0 ]
do
	value=$( dynArrayITGet "${lmserr_codesName}" )
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "dynArrayITGet failed."
		break
	}
	
	index=$( dynArrayITMap ${lmserr_codesName} )

	lmsConioDisplay "${index} = ${value}"

	dynArrayITNext "${lmserr_codesName}"
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "dynArrayITNext failed."
		break
	}
	
	dynArrayITValid "${lmserr_codesName}"
done

lmsConioDisplay "***************  EXIT  ***************"

if [ $lmscli_optProduction -ne 1 ]
then
	lmsErrorQDispPop
fi

lmsConioDebugExit $LINENO "Debug" "End of test" 1

lmsErrorExitScript "EndOfTest"

# *******************************************************

