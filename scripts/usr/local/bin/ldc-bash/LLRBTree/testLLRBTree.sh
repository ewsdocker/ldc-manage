#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testLLRBTree.sh
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 04-01-2016.
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

declare -i ldccli_optProduction=0

if [ $ldccli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/ldc/bash"
	ldcapp_errors="$rootDir/etc/ldc/errorCodes.xml"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	ldcapp_errors="$rootDir/etc/errorCodes.xml"
fi

. $libDir/arraySort.sh
. $libDir/ldcConio.sh
. $libDir/ldcCli.sh
. $libDir/ldcError.sh
. $libDir/ldcErrorQDisp.sh
. $libDir/ldcErrorQ.sh
. $libDir/ldcScriptName.sh
. $libDir/ldcDeclare.sh
. $libDir/ldcStack.sh
. $libDir/ldcStartup.sh
. $libDir/ldcStr.sh
. $libDir/ldcUId
. $libDir/varsFromXml.sh
. $libDir/xmlParser.sh


# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************

function runFirstTests()
{
	treeName="NoblePineLodge"
	ldcLLRBtCreate "${treeName}"
	if [ $? -ne 0 ]
	then
		ldcErrorQWrite $LINENO TreeCreate "Unable to create the requested tree: $treeName"
		errorQueueDisplay 0 1 EndOfTest
	fi

	ldcConioDisplay "Created tree '$treeName'"

	# **************************************************************************
	# **************************************************************************

	keynodeName="${treeName}"
	keynodeUID=""

	result=$( ldcLLRBtIsRed $keynodeName )

	ldcConioDisplay "result = $result"

	ldcConioDisplay "$( ldcLLRBnTS $keynodeName )"

	# **************************************************************************

	ldcConioDisplay ""
	ldcConioDisplay "*******************************************************"
	ldcConioDisplay ""

	leftnodeData="the maid"
	leftnodeName="Bridget"
	leftnodeUID=""

	ldcConioDisplay "Creating node: ${leftnodeName}"

	ldcLLRBnCreate "${leftnodeName}" leftnodeUID "${leftnodeData}"
	ldcLLRBnSet "${leftnodeName}" "color" 0

	ldcConioDisplay "Created node: ${leftnodeName} = $leftnodeUID, linking left child of $keynodeName"
	ldcConioDisplay ""

	ldcLLRBnSet $keynodeName "left" $leftnodeName

	ldcConioDisplay "$( ldcLLRBnTS $keynodeName )"

	# **************************************************************************

	ldcConioDisplay ""
	ldcConioDisplay "*******************************************************"
	ldcConioDisplay ""

	rightnodeData="Bridgets brother"
	rightnodeName="Zandar"
	rightnodeUID=""

	ldcConioDisplay "Creating node: ${rightnodeName}"

	ldcLLRBnCreate "${rightnodeName}" rightnodeUID "${rightnodeData}"
	ldcLLRBnSet "${rightnodeName}" "color" 0

	ldcConioDisplay "Created node: ${rightnodeName} = $rightnodeUID, linking right child of $keynodeName"
	ldcConioDisplay "" and unwind properly

	ldcLLRBnSet $keynodeName "right" $rightnodeName

	ldcConioDisplay "$( ldcLLRBnTS $keynodeName )"

	# **************************************************************************

	displayNodes

	# **************************************************************************

	ldcConioDisplay "flipping color"
	ldcConioDisplay ""

	ldcLLRBtFlipC "$keynodeName"
	if [ $? -ne 0 ]
	then
		ldcErrorQWrite $LINENO TreeModifyNode "Unable to flip color on the requested node: $keynodeName"
		errorQueueDisplay 0 1 EndOfTest
	fi

	displayNodes

	# **************************************************************************

	ldcConioDisplay "flipping color AGAIN"
	ldcConioDisplay ""

	ldcLLRBtFlipC $keynodeName
	if [ $? -ne 0 ]
	then
		ldcErrorQWrite $LINENO TreeModifyNode "Unable to flip color on the requested node: $keynodeName"
		errorQueueDisplay 0 1 EndOfTest
	fi

	displayNodes

	# **************************************************************************

	ldcConioDisplay "comparison"
	ldcConioDisplay ""

	rname=$( ldcLLRBnGet $rightnodeName 'key' )
	lname=$( ldcLLRBnGet $leftnodeName  'key' )

	ldcConioDisplay "Comparing $rname with $lname"

	displayComparison $rname $lname

	displayComparison $lname $rname
}

function displayNodes()
{
	ldcConioDisplay ""
	ldcConioDisplay "******************* NODES *****************************"
	ldcConioDisplay ""

	ldcConioDisplay "$( ldcLLRBnTS $keynodeName )"

	ldcConioDisplay "$( ldcLLRBnTS $leftnodeName )"

	ldcConioDisplay "$( ldcLLRBnTS $rightnodeName )"

	ldcConioDisplay ""
	ldcConioDisplay "*************** END NODES *****************************"
	ldcConioDisplay ""

}

function displayComparison()
{
	local rightnodeName="${1}"
	local leftnodeName="${2}"

	ldcLLRBnCompare "${rightnodeName}" "${leftnodeName}"
	result=$?

	ldcConioDisplay "Compare result = '$result'"
	case $result in

			0)	ldcConioDisplay "$rightnodeName = $leftnodeName"
				;;

			1)	ldcConioDisplay "$rightnodeName > $leftnodeName"
				;;

			2)	ldcConioDisplay "$rightnodeName < $leftnodeName"
				;;

			*)	ldcErrorQWrite $LINENO NodeCompare "Unable to perform comparison"
				errorQueueDisplay 0 1 EndOfTest
				;;
	esac
}

# *******************************************************
# *******************************************************
#
#		Start main program below here
#
# *******************************************************
# *******************************************************

ldccli_optDebug=0				# (d) Debug output if not 0
ldccli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
ldccli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to ldccli_optOverride the ldccli_optSilent flag

applicationVersion="1.0"	# Application version

testErrors=0

# *************************************************************************************************
# *************************************************************************************************

ldcErrorInitialize

ldcErrorQInit
if [ $? -ne 0 ]
then
	ldcConioDisplay "Unable to initialize error queue."
	exit 1
fi

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcScriptDisplayName

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay "*******************************************************"

# *************************************************************************************************

#runFirstTests

# *************************************************************************************************

treeName="LLRBTree"
ldcLLRBtCreate "${treeName}"
if [ $? -ne 0 ]
then
	ldcErrorQWrite $LINENO TreeCreate "Unable to create the requested tree: $treeName"
	errorQueueDisplay 0 1 EndOfTest
fi

ldcConioDisplay "Created tree '$treeName'"

# *************************************************************************************************
# *************************************************************************************************

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

memberData="1980-11-01"
memberName="Edward"
memberUID=""

ldcConioDisplay "Insertting node: ${memberName}"

ldcLLRBtInsert "${memberName}" "${memberData}"


#dumpNameTable
exit 1



ldcConioDisplay "Created node: ${leftnodeName} = $leftnodeUID, linking left child of $keynodeName"
ldcConioDisplay ""

ldcLLRBnSet $keynodeName "left" $leftnodeName

ldcConioDisplay "$( ldcLLRBnTS $keynodeName )"

# *************************************************************************************************

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

rightnodeData="Bridgets brother"
rightnodeName="Zandar"
rightnodeUID=""

ldcConioDisplay "Creating node: ${rightnodeName}"

ldcLLRBnCreate "${rightnodeName}" rightnodeUID "${rightnodeData}"
ldcLLRBnSet "${rightnodeName}" "color" 0

ldcConioDisplay "Created node: ${rightnodeName} = $rightnodeUID, linking right child of $keynodeName"
ldcConioDisplay ""

ldcLLRBnSet $keynodeName "right" $rightnodeName

ldcConioDisplay "$( ldcLLRBnTS $keynodeName )"

# *************************************************************************************************

displayNodes

# **********************************************************************

errorQueueDisplay 0 1 EndOfTest
