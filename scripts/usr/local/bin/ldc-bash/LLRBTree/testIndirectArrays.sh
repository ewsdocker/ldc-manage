#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testIndirectArrays.sh
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

. externalScriptList.sh

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

ldccli_optDebug=0				# (d) Debug output if not 0
ldccli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
ldccli_optBatch=0					# (b) Batch mode - missing parameters fail
ldccli_optOverride=0					# set to 1 to ldccli_optOverride the ldccli_optSilent flag
ldccli_optNoReset=0			# not automatic reset of ldccli_optOverride if 1

applicationVersion="1.0"	# Application version

# *******************************************************

ldcErrorInitialize
ldcErrorQInit
if [ $? -ne 0 ]
then
	ldcConioDisplay "Unable to initialize error queue."
	exit 1
fi

ldcConioDisplay ""
ldcScriptDisplayName

# *******************************************************

A1=( apple trees )
A2=( building blocks )
A3=( color television colortv )

	# ***************************************************

	Aref=A1[index]
	index=0

	ldcConioDisplay "${!Aref}"

	# ***************************************************

	Aref=A2[index]
	index=1

	ldcConioDisplay "${!Aref}"

	# ***************************************************

	Aref=A3[index]
	index=2

	ldcConioDisplay "${!Aref}"

# *******************************************************

	ldcConioDisplay ""
	ldcConioDisplay	"***************************************************"
	ldcConioDisplay ""

	array=2
	ArrayRef=A$array[index]
	index=1

	ldcConioDisplay "${!ArrayRef}"

	index=2
	ArrayRef="newitem"

	ArrayRef=A$array[index]
	ldcConioDisplay "${!ArrayRef}"

	# ***************************************************

	ldcConioDisplay ""
	ldcConioDisplay	"***************************************************"
	ldcConioDisplay ""

	array=2
	ArrayRef=A$array[@]

	message=$( echo "${!ArrayRef}")
	ldcConioDisplay "$message"

	ldcConioDisplay	"***************************************************"
	ldcConioDisplay ""

# *******************************************************

ldccli_optDebug=0

ldcErrorExitScript None

# *******************************************************

