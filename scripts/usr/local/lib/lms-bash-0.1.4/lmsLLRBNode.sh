# *********************************************************************************
# *********************************************************************************
#
#   lmsLLRBNode.sh
#
#		Left-Leaning Red-Black Tree Node
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage llrbNode
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 02-29-2016.
#					0.0.2 - 02-25-2017.
#
# *********************************************************************************
# *********************************************************************************


# *********************************************************************************
# *********************************************************************************
#
#	Each node is declared as a five-element associative array
#
#		"key"		= the name (or key) of the node, to be used in tree placement
#
#		"data"		= the "data" (or value associated with the key) (optional)
#		"left"		= the "key" of the left node, or null
#		"right"		= the "key" of the right node, or null
#		"color"		= the "color" of the node (1 = red, 0 = black)
#
#	The name of the array will be llrbNode_$UID
#		where UID is a (semi) unique identifier assigned to the node
#			for branching purposes.
#
#	The lmsLLRB_nTable can be used to convert between the UID and the key name
#
# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	lmsLLRBnCreate
#
#		Create a new llrb node array and initialize the entries
#
#	parameters:
#		key = the key to store in the tree structure
#		result = the place to return the name of the llrbNode array
#		data = (optional) data to place in the array
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsLLRBnCreate()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local cKey="${1}"
#	local cResult=$2
	local cData="${3}"

	local cUid

	lmsLLRBnLookup "${cKey}" cUid
	[[ $? -eq 0 ]] && return 2

	lmsUIdUnique cUid
	[[ $? -eq 0 ]] || return 3

	lmsLLRB_nTable["${cKey}"]="$cUid"

	local cName="lmsLLRB_n${cUid}"

	lmsDeclareAssoc "${cName}"
	[[ $? -eq 0 ]] || return 4

	lmsDeclareArrayEl "${cName}" "uid"	 "$lmsLLRB_n${cUid}"
	[[ $? -eq 0 ]] || return 4

	lmsDeclareArrayEl "${cName}" "key"   "${cKey}"
	[[ $? -eq 0 ]] || return 4

	lmsDeclareArrayEl "${cName}" "data"  "${cData}"
	[[ $? -eq 0 ]] || return 4

	lmsDeclareArrayEl "${cName}" "left"  0
	[[ $? -eq 0 ]] || return 4

	lmsDeclareArrayEl "${cName}" "right" 0
	[[ $? -eq 0 ]] || return 4

	lmsDeclareArrayEl "${cName}" "color" ${lmsLLRB_nRED}
	[[ $? -eq 0 ]] || break

	lmsDeclareStr ${2} "${cUid}"
	[[ $? -eq 0 ]] || return 4

	return 0
}

# *********************************************************************************
#
#	lmsLLRBnDelete
#
#		delete the llrbNode
#
#	parameters:
#		key   = the node to search for
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsLLRBnDelete()
{
	local llrbNKey="${1}"
	local llrbNUid

	if [ -z "${lmsLLRB_nTable[$llrbNKey]}" ]
	then
    	lmsErrorQWrite $LINENO NodeDelete "Node '${llrbNKey}' not found."
		return 1
	fi

	llrbNUid=${lmsLLRB_nTable[$llrbNKey]}
	unset lmsLLRB_nTable["$llrbNKey"]

	eval "unset llrbNode_${llrbNUid}"

	return 0
}

# *********************************************************************************
#
#	lmsLLRBnGet
#
#		get the llrbNode element
#
#	parameters:
#		name   	= the node name to search for
#		element	= element of node array to fetch
#		ret 	= place to store the result
#
#	outputs:
#		value = the value from the requested element (if 'ret' is not supplied)
#
#	returns:
#		0 = found in table, uid is valid
#		1 = not found in table, uid is invalid
#
# *********************************************************************************
function lmsLLRBnGet()
{
	local gName=$1
	local gElement=$2

	lmsLLRBnLookup "${gName}" lUid
	if [ $? -eq 0 ]
	then
    	lmsErrorQWrite $LINENO NodeGet "Node '${gName}' not found."
    	return 1
	fi

	local element
	eval 'element=$'"{llrbNode_$lUid[$gElement]}"

	if [ -n "${3}" ]
	then
    	eval ${3}="'${gElement}'"
    else
    	echo "${gElement}"
	fi
}

# *********************************************************************************
#
#	lmsLLRBnSet
#
#		set the llrbNode element
#
#	parameters:
#		name   	= the node name to search for
#		element	= element of node array to fetch
#		value 	= value to store in the node element
#
#	returns:
#		0 = found in table, uid is valid
#		1 = not found in table, uid is invalid
#
# *********************************************************************************
function lmsLLRBnSet()
{
	local gName=$1
	local gElement=$2
	local gValue=${3}

	local gUid
	lmsLLRBnLookup "${gName}" gUid
	[[ $? -eq 0 ]] || return 2

	lmsDeclareArrayEl "lmsLLRB_n$gUid" "${gElement}" "${gValue}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# *********************************************************************************
#
#	lmsLLRBnLookup
#
#		get the llrbNode key uid
#
#	parameters:
#		key   = the key to search for
#		uid   = place to store the result
#
#	returns:
#		0 = found in table, uid is valid
#		non-zero = not found
#
# *********************************************************************************
function lmsLLRBnLookup()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local nKey="${1}"

	[[ ! "${#lmsLLRB_nTable[@]}" =~ "$nKey" ]] && return 0

	lmsLLRB_nVarKey=$nKey
	lmsLLRB_nVarUid=${lmsLLRB_nTable[$nKey]}
	lmsLLRB_nVarName="lmsLLRB_n${lmsLLRB_nVarUid}"

	lmsDeclareStr ${2} "${lmsLLRB_nVarUid}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *********************************************************************************
#
#	lmsLLRBnTS
#
#		Return a printable buffer containing data about the node in question
#
#	parameters:
#		name   = the node name (key)
#		buffer = place to store the result
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsLLRBnTS()
{
	local llrbSName="${1}"
	local llrbSBuffer=$2

	local llrbSValue=""
	local field=""
	local nodeField=""

	local llrbBuffer
	printf -v llrbBuffer "Node: %s\n" "$llrbSName"

	for field in "${lmsLLRB_nFields[@]}"
	do
		lmsLLRBnGet ${llrbSName} ${field} llrbSValue
		if [ $? -eq 1 ]
		then
    		lmsErrorQWrite $LINENO NodeList "Unable to fetch field $field in $llrbSName"
			break
		fi

		printf -v nodeField "    %s = %s\n" "$field" "${llrbSValue}"
		llrbBuffer=$llrbBuffer$nodeField
	done

#	if [ -n "$2" ]
#	then
#		eval "$llrbSBuffer='$llrbBuffer'"
#	else
		echo "${llrbBuffer}"
#	fi
}

# *********************************************************************************
#
#	lmsLLRBnCopy
#
#		Copy the source node to the destination node
#
#	parameters:
#		destination	= the node name to copy to
#		source 	    = the node name to copy from
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsLLRBnCopy()
{
	local lDest=$1
	local lSource=$2

	local lUid

	lmsLLRBnLookup "${lSource}" lUid
	[[ $? -eq 0 ]] || return 1

	lmsLLRBnLookup "${lDest}" lUid
	[[ $? -eq 0 ]] || return 2

	local lValue
	local lKey

	for lKey in "${lmsLLRB_nFields[@]}}"
	do
		[[ "$lKey" != "uid" && "$lKey" != "key" ]] &&
		 {
			lValue=$( lmsLLRBnGet $lSource "$lKey" )
			[[ $? -eq 0 ]] || return 3

			lmsLLRBnSet $lDest "$lKey" "${lValue}"
			[[ $? -eq 0 ]] || return 4
		 }
	done

	return 0
}

# *********************************************************************************
#
#	lmsLLRBnCompare
#
#		Compare the source node to the compare node
#			(e.g. source < compare)
#
#	parameters:
#		compare	= the name of the node to compare the source node with
#		source 	= the node name of the source node to compare
#		result  = location to store the compare result
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsLLRBnCompare()
{
	local lSource="${1}"
	local lComp="${2}"

	local lUid

	while true
	do
		lmsLLRBnLookup "${lSource}" lUid
		[[ $? -eq 0 ]] || break

		lmsLLRBnLookup "${lComp}" lUid
		[[ $? -eq 0 ]] || break

		llsname=$( lmsLLRBnGet "${lSource}" "key" )
		[[ $? -eq 0 ]] || break

		llcname=$( lmsLLRBnGet "${lComp}" "key" )
		[[ $? -eq 0 ]] || break

		#
		#  less
		#
		if [ "$llsname" \< "$llcname" ]
		then
			return 2
		fi

		#
		#  greater
		#
		if [ "$llsname" \> "$llcname" ]
		then
			return 1
		fi

		return 0

	done

	return 3
}

# *********************************************************************************

# *********************************************************************************
#
#	lmsLLRBn_Field
#
#		Set/Get the node key
#
#	Parameters:
#		llnode = node to get the value for
#		llvalue = storage for the field value
#		llnewValue = (optional) new field value to set FIRST, if not empty
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsLLRBn_Field()
{
	local llnode=$1
	local llfield=$2
	local llvalue=$3
	local llnewValue=$4

echo "llfield = '$llfield'"

	if ! [[ ${lmsLLRB_nFields[@]} =~ ${llfield} ]]
	then
		lmsErrorQWrite $LINENO NodeField "Invalid/unknown field name '${llfield}'."
		return 1
	fi

	if [[ -n "$llnewValue" ]]
	then
		lmsLLRBnSet $llnode $llfield $llnewValue
		if [[ $? -ne 0 ]]
		then
			lmsErrorQWrite $LINENO NodeField "Unable to set field name '${llfield}' in '$llnode'."
			return 1
		fi
	fi

	lmsLLRBnGet $llnode $llfield llvalue
	if [[ $? -ne 0 ]]
	then
		lmsErrorQWrite $LINENO NodeField "Unable to get value field name '${llfield}' in '$llnode'."
errorQueueDisplay 1 1
dumpNameTable
exit 1
		return 1
	fi

	return 0
}

# *********************************************************************************

