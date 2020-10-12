#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testExpression.sh
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 04-04-2016.
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

. externalScriptList.sh

# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************
# *************************************************************************************************

function testExpr()
{
	local lldelete=$1
	local llcolor=$2

	lmsConioDisplay "testExpr:"
	lmsConioDisplay "    delete = $lldelete, color = $llcolor"
	lmsConioDisplay ""

	let llcolor=$llcolor%2
	let llcolor+=$lldelete

	if [[  $lldelete -eq 1  ||  $llcolor -eq 0 ]]
	then
		lmsConioDisplay "        Executing conditional code"
	else
		lmsConioDisplay "    NOT Executing conditional code"
	fi
}

function compareNodes()
{
	local leftnodeName="$1"
	local nodeData="left node"
	local nodeUID=""

	lmsLLRBnCreate "${leftnodeName}" nodeUID "${nodeData}"

	local rightnodeName="$2"

	nodeData="right node"
	nodeUID=""

	lmsLLRBnCreate "${rightnodeName}" nodeUID "${nodeData}"

	rname=$( lmsLLRBnGet $rightnodeName 'key' )
	lname=$( lmsLLRBnGet $leftnodeName  'key' )

	lmsLLRBnCompare $rightnodeName $leftnodeName
	case $? in

		0)	lmsConioDisplay "$rightnodeName = $leftnodeName"
			;;

		1)	lmsConioDisplay "$rightnodeName > $leftnodeName"
			;;

		2)	lmsConioDisplay "$rightnodeName < $leftnodeName"
			;;

		*)	lmsConioDisplay "Unable to perform comparison"
			errorQueueDisplay 1 0 NodeCompare
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

lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsScriptDisplayName

lmsConioDisplay ""

# *************************************************************************************************
# *************************************************************************************************

testExpr 0 0

testExpr 1 0

testExpr 0 1

testExpr 1 1

# **********************************************************************

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""
lmsConioDisplay "Compare 'Bridget' with 'Zandar'"
lmsConioDisplay ""

compareNodes Bridget Zandar

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

# **********************************************************************

errorQueueDisplay 1 0 None
