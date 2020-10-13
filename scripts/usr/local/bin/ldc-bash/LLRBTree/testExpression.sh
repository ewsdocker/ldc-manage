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

	ldcConioDisplay "testExpr:"
	ldcConioDisplay "    delete = $lldelete, color = $llcolor"
	ldcConioDisplay ""

	let llcolor=$llcolor%2
	let llcolor+=$lldelete

	if [[  $lldelete -eq 1  ||  $llcolor -eq 0 ]]
	then
		ldcConioDisplay "        Executing conditional code"
	else
		ldcConioDisplay "    NOT Executing conditional code"
	fi
}

function compareNodes()
{
	local leftnodeName="$1"
	local nodeData="left node"
	local nodeUID=""

	ldcLLRBnCreate "${leftnodeName}" nodeUID "${nodeData}"

	local rightnodeName="$2"

	nodeData="right node"
	nodeUID=""

	ldcLLRBnCreate "${rightnodeName}" nodeUID "${nodeData}"

	rname=$( ldcLLRBnGet $rightnodeName 'key' )
	lname=$( ldcLLRBnGet $leftnodeName  'key' )

	ldcLLRBnCompare $rightnodeName $leftnodeName
	case $? in

		0)	ldcConioDisplay "$rightnodeName = $leftnodeName"
			;;

		1)	ldcConioDisplay "$rightnodeName > $leftnodeName"
			;;

		2)	ldcConioDisplay "$rightnodeName < $leftnodeName"
			;;

		*)	ldcConioDisplay "Unable to perform comparison"
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

ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcScriptDisplayName

ldcConioDisplay ""

# *************************************************************************************************
# *************************************************************************************************

testExpr 0 0

testExpr 1 0

testExpr 0 1

testExpr 1 1

# **********************************************************************

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""
ldcConioDisplay "Compare 'Bridget' with 'Zandar'"
ldcConioDisplay ""

compareNodes Bridget Zandar

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

# **********************************************************************

errorQueueDisplay 1 0 None
