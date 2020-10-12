#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testStackFunctions.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 03-07-2016.
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

. ../ShellSnippets/stack.bash
. ../ShellSnippets/lmsUId
. ../ShellSnippets/lmsStr.bash
. ../ShellSnippets/applicationName.bash
. ../ShellSnippets/lmsError.bash
. ../ShellSnippets/lmsConio.bash
. ../ShellSnippets/setupFedoraErrorCodes.bash

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

declare -i lmsStackSize

declare nameStack
declare name

declare testNames=( global lmscli_optProduction configuration database )

# *******************************************************

initializeErrorCodes

lmscli_optOverride=1
lmscli_optNoReset=1

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
displayApplicationName
lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

stack_new nameStack
if [ $? -ne 0 ]
then
	lmsConioDisplay "Unable to create a stack named 'nameStack'"
	exitScript Error_Unknown
fi

lmsConioDisplay "+++++++++++++++++++++"

for name in ${testNames[@]}
do
	lmsConioDisplay "   Adding '$name' - " -n
	stack_push nameStack "${name}"
	if [ $? -ne 0 ]
	then
		lmsConioDisplay "unable to push $name onto stack"
		exitScript Error_Unknown
	fi

	lmsConioDisplay "added"
	lmsConioDisplay "Stack contents:"
	stack_print nameStack
	lmsConioDisplay "+++++++++++++++++++++"
done

lmsConioDisplay "*********************"

stack_size nameStack lmsStackSize
lmsConioDisplay "Stack size: $lmsStackSize"

stack_print nameStack

lmsConioDisplay "*********************"

lmsConioDisplay "---------------------"

stack_size nameStack lmsStackSize
while (( ${lmsStackSize} != 0 ))
do
	lmsConioDisplay "Stack size: $lmsStackSize"
	lmsConioDisplay "  Popping stack - " -n
	stack_pop nameStack name
	if [ $? -ne 0 ]
	then
		if [ $? -eq 1 ]
		then
			lmsConioDisplay "unable to pop the stack"
		else
			lmsConioDisplay "empty stack"
		fi

		break
	fi

	lmsConioDisplay "$name"
	lmsConioDisplay ""
	stack_print nameStack
	stack_size nameStack lmsStackSize
	lmsConioDisplay "---------------------"
done

stack_size nameStack lmsStackSize
lmsConioDisplay "Stack size: $lmsStackSize"

stack_print nameStack

lmsConioDisplay "*********************"

stack_destroy nameStack

exitScript Error_None
