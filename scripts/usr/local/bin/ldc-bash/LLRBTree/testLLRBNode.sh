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

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag

applicationVersion="1.0"	# Application version

testErrors=0

# *******************************************************
# *******************************************************

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
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

nodeData="the maid"
nodeName="Bridget"
nodeUID=""

lmsConioDisplay "Creating node: ${nodeName}"

lmsLLRBnCreate "${nodeName}" nodeUID "${nodeData}"

lmsConioDisplay "Created node: ${nodeName} = $nodeUID"
lmsConioDisplay ""

# **********************************************************************

lmsConioDisplay "Getting 'data' element from node: ${nodeName}"
lmsConioDisplay ""

nodeData=$( lmsLLRBnGet "$nodeName" "data" )
if [ $? -eq 1 ]
then
	lmsConioDisplay "Unable to get the requested node: ${nodeName}"
else
	lmsConioDisplay "NodeData: $nodeData"
fi

lmsConioDisplay "$( lmsLLRBnTS $nodeName )"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

# **********************************************************************

nodeData="No longer the maid"
lmsLLRBnSet "${nodeName}" "data" "${nodeData}"
if [ $? -ne 0 ]
then
	lmsConioDisplay "Unable to set the requested node: ${nodeName}"
fi

nodeData=$( lmsLLRBnGet "${nodeName}" "data" )
if [ $? -eq 1 ]
then
	lmsConioDisplay "Unable to get the requested node: ${nodeName}"
else
	lmsConioDisplay "NodeData: $nodeData"
fi

lmsConioDisplay "$( lmsLLRBnTS $nodeName )"

# **********************************************************************

rightnodeData="Bridgets brother"
rightnodeName="Zandar"
rightnodeUID=""

lmsConioDisplay "Creating node: ${rightnodeName}"

lmsLLRBnCreate "${rightnodeName}" rightnodeUID "${rightnodeData}"

lmsLLRBnSet $nodeName "right" $rightnodeName

lmsConioDisplay "$( lmsLLRBnTS $nodeName )"
lmsConioDisplay "$( lmsLLRBnTS $rightnodeName )"

# **********************************************************************

lmsConioDisplay "Copying node: $nodeName to ${rightnodeName}"

lmsLLRBnCopy "$rightnodeName" "$nodeName"

lmsConioDisplay "$( lmsLLRBnTS $nodeName )"
lmsConioDisplay "$( lmsLLRBnTS $rightnodeName )"

# **********************************************************************

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

llfield="key"
llkey=""
lmsLLRBn_Field "$rightnodeName" $llfield llkey

lmsConioDisplay "Changing '$llfield' in '$rightnodeName' to " -n

llkey=""
llkeyNew="Mark"
lmsConioDisplay "'$llkeyNew'"

lmsLLRBn_Field "$rightnodeName" $llfield llkey "$llkeyNew"

lmsConioDisplay "Key: $llkey"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsConioDisplay "$( lmsLLRBnTS $rightnodeName )"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsConioDisplay "Changing '$llfield' in '$rightnodeName' to " -n

llkey=""
llkeyNew="Zandar"
lmsConioDisplay "'$llkeyNew'"

lmsLLRBn_Field "$rightnodeName" $llfield llkey "$llkeyNew"

lmsConioDisplay "Key: $llkey"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsConioDisplay "$( lmsLLRBnTS $rightnodeName )"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

# **********************************************************************
# **********************************************************************
# **********************************************************************
# **********************************************************************

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

llfield="left"
llkey=""
lmsLLRBn_Field "$rightnodeName" $llfield llkey

lmsConioDisplay "Changing '$llfield' in '$rightnodeName' to " -n

llkey=""
llkeyNew="Zandar"
lmsConioDisplay "'$llkeyNew'"

lmsLLRBn_Field "$rightnodeName" $llfield llkey "$llkeyNew"

lmsConioDisplay "Key: $llkey"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsConioDisplay "$( lmsLLRBnTS $rightnodeName )"

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

# **********************************************************************

lmsConioDisplay "Deleting llrbNode = ${rightnodeName}"
lmsLLRBnDelete "${rightnodeName}"

lmsConioDisplay "Deleting llrbNode = ${nodeName}"
lmsLLRBnDelete "${nodeName}"

#dumpNameTable

# **********************************************************************

errorQueueDisplay 1 0 None
