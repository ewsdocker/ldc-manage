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

declare -i lmscli_optProduction=0

if [ $lmscli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/lms/bash"
	lmsapp_errors="$rootDir/etc/lms/errorCodes.xml"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	lmsapp_errors="$rootDir/etc/errorCodes.xml"
fi

. $libDir/arraySort.sh
. $libDir/lmsConio.sh
. $libDir/lmsCli.sh
. $libDir/lmsError.sh
. $libDir/lmsErrorQDisp.sh
. $libDir/lmsErrorQ.sh
. $libDir/lmsScriptName.sh
. $libDir/lmsDeclare.sh
. $libDir/lmsStack.sh
. $libDir/lmsStartup.sh
. $libDir/lmsStr.sh
. $libDir/lmsUId
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
	lmsLLRBtCreate "${treeName}"
	if [ $? -ne 0 ]
	then
		lmsErrorQWrite $LINENO TreeCreate "Unable to create the requested tree: $treeName"
		errorQueueDisplay 0 1 EndOfTest
	fi

	lmsConioDisplay "Created tree '$treeName'"

	# **************************************************************************
	# **************************************************************************

	keynodeName="${treeName}"
	keynodeUID=""

	result=$( lmsLLRBtIsRed $keynodeName )

	lmsConioDisplay "result = $result"

	lmsConioDisplay "$( lmsLLRBnTS $keynodeName )"

	# **************************************************************************

	lmsConioDisplay ""
	lmsConioDisplay "*******************************************************"
	lmsConioDisplay ""

	leftnodeData="the maid"
	leftnodeName="Bridget"
	leftnodeUID=""

	lmsConioDisplay "Creating node: ${leftnodeName}"

	lmsLLRBnCreate "${leftnodeName}" leftnodeUID "${leftnodeData}"
	lmsLLRBnSet "${leftnodeName}" "color" 0

	lmsConioDisplay "Created node: ${leftnodeName} = $leftnodeUID, linking left child of $keynodeName"
	lmsConioDisplay ""

	lmsLLRBnSet $keynodeName "left" $leftnodeName

	lmsConioDisplay "$( lmsLLRBnTS $keynodeName )"

	# **************************************************************************

	lmsConioDisplay ""
	lmsConioDisplay "*******************************************************"
	lmsConioDisplay ""

	rightnodeData="Bridgets brother"
	rightnodeName="Zandar"
	rightnodeUID=""

	lmsConioDisplay "Creating node: ${rightnodeName}"

	lmsLLRBnCreate "${rightnodeName}" rightnodeUID "${rightnodeData}"
	lmsLLRBnSet "${rightnodeName}" "color" 0

	lmsConioDisplay "Created node: ${rightnodeName} = $rightnodeUID, linking right child of $keynodeName"
	lmsConioDisplay "" and unwind properly

	lmsLLRBnSet $keynodeName "right" $rightnodeName

	lmsConioDisplay "$( lmsLLRBnTS $keynodeName )"

	# **************************************************************************

	displayNodes

	# **************************************************************************

	lmsConioDisplay "flipping color"
	lmsConioDisplay ""

	lmsLLRBtFlipC "$keynodeName"
	if [ $? -ne 0 ]
	then
		lmsErrorQWrite $LINENO TreeModifyNode "Unable to flip color on the requested node: $keynodeName"
		errorQueueDisplay 0 1 EndOfTest
	fi

	displayNodes

	# **************************************************************************

	lmsConioDisplay "flipping color AGAIN"
	lmsConioDisplay ""

	lmsLLRBtFlipC $keynodeName
	if [ $? -ne 0 ]
	then
		lmsErrorQWrite $LINENO TreeModifyNode "Unable to flip color on the requested node: $keynodeName"
		errorQueueDisplay 0 1 EndOfTest
	fi

	displayNodes

	# **************************************************************************

	lmsConioDisplay "comparison"
	lmsConioDisplay ""

	rname=$( lmsLLRBnGet $rightnodeName 'key' )
	lname=$( lmsLLRBnGet $leftnodeName  'key' )

	lmsConioDisplay "Comparing $rname with $lname"

	displayComparison $rname $lname

	displayComparison $lname $rname
}

function displayNodes()
{
	lmsConioDisplay ""
	lmsConioDisplay "******************* NODES *****************************"
	lmsConioDisplay ""

	lmsConioDisplay "$( lmsLLRBnTS $keynodeName )"

	lmsConioDisplay "$( lmsLLRBnTS $leftnodeName )"

	lmsConioDisplay "$( lmsLLRBnTS $rightnodeName )"

	lmsConioDisplay ""
	lmsConioDisplay "*************** END NODES *****************************"
	lmsConioDisplay ""

}

function displayComparison()
{
	local rightnodeName="${1}"
	local leftnodeName="${2}"

	lmsLLRBnCompare "${rightnodeName}" "${leftnodeName}"
	result=$?

	lmsConioDisplay "Compare result = '$result'"
	case $result in

			0)	lmsConioDisplay "$rightnodeName = $leftnodeName"
				;;

			1)	lmsConioDisplay "$rightnodeName > $leftnodeName"
				;;

			2)	lmsConioDisplay "$rightnodeName < $leftnodeName"
				;;

			*)	lmsErrorQWrite $LINENO NodeCompare "Unable to perform comparison"
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

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag

applicationVersion="1.0"	# Application version

testErrors=0

# *************************************************************************************************
# *************************************************************************************************

lmsErrorInitialize

lmsErrorQInit
if [ $? -ne 0 ]
then
	lmsConioDisplay "Unable to initialize error queue."
	exit 1
fi

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsScriptDisplayName

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay "*******************************************************"

# *************************************************************************************************

#runFirstTests

# *************************************************************************************************

treeName="LLRBTree"
lmsLLRBtCreate "${treeName}"
if [ $? -ne 0 ]
then
	lmsErrorQWrite $LINENO TreeCreate "Unable to create the requested tree: $treeName"
	errorQueueDisplay 0 1 EndOfTest
fi

lmsConioDisplay "Created tree '$treeName'"

# *************************************************************************************************
# *************************************************************************************************

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

memberData="1980-11-01"
memberName="Edward"
memberUID=""

lmsConioDisplay "Insertting node: ${memberName}"

lmsLLRBtInsert "${memberName}" "${memberData}"


#dumpNameTable
exit 1



lmsConioDisplay "Created node: ${leftnodeName} = $leftnodeUID, linking left child of $keynodeName"
lmsConioDisplay ""

lmsLLRBnSet $keynodeName "left" $leftnodeName

lmsConioDisplay "$( lmsLLRBnTS $keynodeName )"

# *************************************************************************************************

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

rightnodeData="Bridgets brother"
rightnodeName="Zandar"
rightnodeUID=""

lmsConioDisplay "Creating node: ${rightnodeName}"

lmsLLRBnCreate "${rightnodeName}" rightnodeUID "${rightnodeData}"
lmsLLRBnSet "${rightnodeName}" "color" 0

lmsConioDisplay "Created node: ${rightnodeName} = $rightnodeUID, linking right child of $keynodeName"
lmsConioDisplay ""

lmsLLRBnSet $keynodeName "right" $rightnodeName

lmsConioDisplay "$( lmsLLRBnTS $keynodeName )"

# *************************************************************************************************

displayNodes

# **********************************************************************

errorQueueDisplay 0 1 EndOfTest
