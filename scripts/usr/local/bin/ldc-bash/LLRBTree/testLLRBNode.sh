#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testLLRBNode.sh
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 02-28-2016.
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
silentOverride=0			# set to 1 to ldccli_optOverride the ldccli_optSilent flag

applicationVersion="1.0"	# Application version

testErrors=0

# *******************************************************
# *******************************************************

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
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

nodeData="the maid"
nodeName="Bridget"
nodeUID=""

ldcConioDisplay "Creating node: ${nodeName}"

ldcLLRBnCreate "${nodeName}" nodeUID "${nodeData}"

ldcConioDisplay "Created node: ${nodeName} = $nodeUID"
ldcConioDisplay ""

# **********************************************************************

ldcConioDisplay "Getting 'data' element from node: ${nodeName}"
ldcConioDisplay ""

nodeData=$( ldcLLRBnGet "$nodeName" "data" )
if [ $? -eq 1 ]
then
	ldcConioDisplay "Unable to get the requested node: ${nodeName}"
else
	ldcConioDisplay "NodeData: $nodeData"
fi

ldcConioDisplay "$( ldcLLRBnTS $nodeName )"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

# **********************************************************************

nodeData="No longer the maid"
ldcLLRBnSet "${nodeName}" "data" "${nodeData}"
if [ $? -ne 0 ]
then
	ldcConioDisplay "Unable to set the requested node: ${nodeName}"
fi

nodeData=$( ldcLLRBnGet "${nodeName}" "data" )
if [ $? -eq 1 ]
then
	ldcConioDisplay "Unable to get the requested node: ${nodeName}"
else
	ldcConioDisplay "NodeData: $nodeData"
fi

ldcConioDisplay "$( ldcLLRBnTS $nodeName )"

# **********************************************************************

rightnodeData="Bridgets brother"
rightnodeName="Zandar"
rightnodeUID=""

ldcConioDisplay "Creating node: ${rightnodeName}"

ldcLLRBnCreate "${rightnodeName}" rightnodeUID "${rightnodeData}"

ldcLLRBnSet $nodeName "right" $rightnodeName

ldcConioDisplay "$( ldcLLRBnTS $nodeName )"
ldcConioDisplay "$( ldcLLRBnTS $rightnodeName )"

# **********************************************************************

ldcConioDisplay "Copying node: $nodeName to ${rightnodeName}"

ldcLLRBnCopy "$rightnodeName" "$nodeName"

ldcConioDisplay "$( ldcLLRBnTS $nodeName )"
ldcConioDisplay "$( ldcLLRBnTS $rightnodeName )"

# **********************************************************************

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

llfield="key"
llkey=""
ldcLLRBn_Field "$rightnodeName" $llfield llkey

ldcConioDisplay "Changing '$llfield' in '$rightnodeName' to " -n

llkey=""
llkeyNew="Mark"
ldcConioDisplay "'$llkeyNew'"

ldcLLRBn_Field "$rightnodeName" $llfield llkey "$llkeyNew"

ldcConioDisplay "Key: $llkey"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcConioDisplay "$( ldcLLRBnTS $rightnodeName )"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcConioDisplay "Changing '$llfield' in '$rightnodeName' to " -n

llkey=""
llkeyNew="Zandar"
ldcConioDisplay "'$llkeyNew'"

ldcLLRBn_Field "$rightnodeName" $llfield llkey "$llkeyNew"

ldcConioDisplay "Key: $llkey"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcConioDisplay "$( ldcLLRBnTS $rightnodeName )"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

# **********************************************************************
# **********************************************************************
# **********************************************************************
# **********************************************************************

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

llfield="left"
llkey=""
ldcLLRBn_Field "$rightnodeName" $llfield llkey

ldcConioDisplay "Changing '$llfield' in '$rightnodeName' to " -n

llkey=""
llkeyNew="Zandar"
ldcConioDisplay "'$llkeyNew'"

ldcLLRBn_Field "$rightnodeName" $llfield llkey "$llkeyNew"

ldcConioDisplay "Key: $llkey"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcConioDisplay "$( ldcLLRBnTS $rightnodeName )"

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

# **********************************************************************

ldcConioDisplay "Deleting llrbNode = ${rightnodeName}"
ldcLLRBnDelete "${rightnodeName}"

ldcConioDisplay "Deleting llrbNode = ${nodeName}"
ldcLLRBnDelete "${nodeName}"

#dumpNameTable

# **********************************************************************

errorQueueDisplay 1 0 None
