#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testIndirectArrays.bash
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

. ../ShellSnippets/lmsUId
. ../ShellSnippets/namespace.bash
. ../ShellSnippets/lmsDeclare.bash
. ../ShellSnippets/lmsStr.bash
. ../ShellSnippets/lmsScriptName.bash
. ../ShellSnippets/lmsErrorQ.bash
. ../ShellSnippets/lmsError.bash
. ../ShellSnippets/lmsConio.bash
. ../ShellSnippets/setupErrorCodes.bash
. ../ShellSnippets/lmsStack.bash

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

lmsErrorInitialize
lmsErrorQInit
if [ $? -ne 0 ]
then
	lmsConioDisplay "Unable to initialize error queue."
	exit 1
fi

lmsConioDisplay ""
lmsScriptDisplayName

# *******************************************************

A1=( apple trees )
A2=( building blocks )
A3=( color television colortv )

	# ***************************************************

	Aref=A1[index]
	index=0

	lmsConioDisplay "${!Aref}"

	# ***************************************************

	Aref=A2[index]
	index=1

	lmsConioDisplay "${!Aref}"

	# ***************************************************

	Aref=A3[index]
	index=2

	lmsConioDisplay "${!Aref}"

# *******************************************************

	lmsConioDisplay ""
	lmsConioDisplay	"***************************************************"
	lmsConioDisplay ""

	array=2
	ArrayRef=A$array[index]
	index=1

	lmsConioDisplay "${!ArrayRef}"

	index=2
	ArrayRef="newitem"

	ArrayRef=A$array[index]
	lmsConioDisplay "${!ArrayRef}"

	# ***************************************************

	lmsConioDisplay ""
	lmsConioDisplay	"***************************************************"
	lmsConioDisplay ""

	array=2
	ArrayRef=A$array[@]

	message=$( echo "${!ArrayRef}")
	lmsConioDisplay "$message"

	lmsConioDisplay	"***************************************************"
	lmsConioDisplay ""

# *******************************************************

lmscli_optDebug=0

lmsErrorExitScript None

# *******************************************************

