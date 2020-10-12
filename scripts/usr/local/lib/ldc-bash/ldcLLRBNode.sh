# *********************************************************************************
# *********************************************************************************
#
#   ldcLLRBNode.sh
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
#	The ldcLLRB_nTable can be used to convert between the UID and the key name
#
# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	ldcLLRBnCreate
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
function ldcLLRBnCreate()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local cKey="${1}"
#	local cResult=$2
	local cData="${3}"

	local cUid

	ldcLLRBnLookup "${cKey}" cUid
	[[ $? -eq 0 ]] && return 2

	ldcUIdUnique cUid
	[[ $? -eq 0 ]] || return 3

	ldcLLRB_nTable["${cKey}"]="$cUid"

	local cName="ldcLLRB_n${cUid}"

	ldcDeclareAssoc "${cName}"
	[[ $? -eq 0 ]] || return 4

	ldcDeclareArrayEl "${cName}" "uid"	 "$ldcLLRB_n${cUid}"
	[[ $? -eq 0 ]] || return 4

	ldcDeclareArrayEl "${cName}" "key"   "${cKey}"
	[[ $? -eq 0 ]] || return 4

	ldcDeclareArrayEl "${cName}" "data"  "${cData}"
	[[ $? -eq 0 ]] || return 4

	ldcDeclareArrayEl "${cName}" "left"  0
	[[ $? -eq 0 ]] || return 4

	ldcDeclareArrayEl "${cName}" "right" 0
	[[ $? -eq 0 ]] || return 4

	ldcDeclareArrayEl "${cName}" "color" ${ldcLLRB_nRED}
	[[ $? -eq 0 ]] || break

	ldcDeclareStr ${2} "${cUid}"
	[[ $? -eq 0 ]] || return 4

	return 0
}

# *********************************************************************************
#
#	ldcLLRBnDelete
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
function ldcLLRBnDelete()
{
	local llrbNKey="${1}"
	local llrbNUid

	if [ -z "${ldcLLRB_nTable[$llrbNKey]}" ]
	then
    	ldcErrorQWrite $LINENO NodeDelete "Node '${llrbNKey}' not found."
		return 1
	fi

	llrbNUid=${ldcLLRB_nTable[$llrbNKey]}
	unset ldcLLRB_nTable["$llrbNKey"]

	eval "unset llrbNode_${llrbNUid}"

	return 0
}

# *********************************************************************************
#
#	ldcLLRBnGet
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
function ldcLLRBnGet()
{
	local gName=$1
	local gElement=$2

	ldcLLRBnLookup "${gName}" lUid
	if [ $? -eq 0 ]
	then
    	ldcErrorQWrite $LINENO NodeGet "Node '${gName}' not found."
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
#	ldcLLRBnSet
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
function ldcLLRBnSet()
{
	local gName=$1
	local gElement=$2
	local gValue=${3}

	local gUid
	ldcLLRBnLookup "${gName}" gUid
	[[ $? -eq 0 ]] || return 2

	ldcDeclareArrayEl "ldcLLRB_n$gUid" "${gElement}" "${gValue}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# *********************************************************************************
#
#	ldcLLRBnLookup
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
function ldcLLRBnLookup()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local nKey="${1}"

	[[ ! "${#ldcLLRB_nTable[@]}" =~ "$nKey" ]] && return 0

	ldcLLRB_nVarKey=$nKey
	ldcLLRB_nVarUid=${ldcLLRB_nTable[$nKey]}
	ldcLLRB_nVarName="ldcLLRB_n${ldcLLRB_nVarUid}"

	ldcDeclareStr ${2} "${ldcLLRB_nVarUid}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *********************************************************************************
#
#	ldcLLRBnTS
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
function ldcLLRBnTS()
{
	local llrbSName="${1}"
	local llrbSBuffer=$2

	local llrbSValue=""
	local field=""
	local nodeField=""

	local llrbBuffer
	printf -v llrbBuffer "Node: %s\n" "$llrbSName"

	for field in "${ldcLLRB_nFields[@]}"
	do
		ldcLLRBnGet ${llrbSName} ${field} llrbSValue
		if [ $? -eq 1 ]
		then
    		ldcErrorQWrite $LINENO NodeList "Unable to fetch field $field in $llrbSName"
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
#	ldcLLRBnCopy
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
function ldcLLRBnCopy()
{
	local lDest=$1
	local lSource=$2

	local lUid

	ldcLLRBnLookup "${lSource}" lUid
	[[ $? -eq 0 ]] || return 1

	ldcLLRBnLookup "${lDest}" lUid
	[[ $? -eq 0 ]] || return 2

	local lValue
	local lKey

	for lKey in "${ldcLLRB_nFields[@]}}"
	do
		[[ "$lKey" != "uid" && "$lKey" != "key" ]] &&
		 {
			lValue=$( ldcLLRBnGet $lSource "$lKey" )
			[[ $? -eq 0 ]] || return 3

			ldcLLRBnSet $lDest "$lKey" "${lValue}"
			[[ $? -eq 0 ]] || return 4
		 }
	done

	return 0
}

# *********************************************************************************
#
#	ldcLLRBnCompare
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
function ldcLLRBnCompare()
{
	local lSource="${1}"
	local lComp="${2}"

	local lUid

	while true
	do
		ldcLLRBnLookup "${lSource}" lUid
		[[ $? -eq 0 ]] || break

		ldcLLRBnLookup "${lComp}" lUid
		[[ $? -eq 0 ]] || break

		llsname=$( ldcLLRBnGet "${lSource}" "key" )
		[[ $? -eq 0 ]] || break

		llcname=$( ldcLLRBnGet "${lComp}" "key" )
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
#	ldcLLRBn_Field
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
function ldcLLRBn_Field()
{
	local llnode=$1
	local llfield=$2
	local llvalue=$3
	local llnewValue=$4

echo "llfield = '$llfield'"

	if ! [[ ${ldcLLRB_nFields[@]} =~ ${llfield} ]]
	then
		ldcErrorQWrite $LINENO NodeField "Invalid/unknown field name '${llfield}'."
		return 1
	fi

	if [[ -n "$llnewValue" ]]
	then
		ldcLLRBnSet $llnode $llfield $llnewValue
		if [[ $? -ne 0 ]]
		then
			ldcErrorQWrite $LINENO NodeField "Unable to set field name '${llfield}' in '$llnode'."
			return 1
		fi
	fi

	ldcLLRBnGet $llnode $llfield llvalue
	if [[ $? -ne 0 ]]
	then
		ldcErrorQWrite $LINENO NodeField "Unable to get value field name '${llfield}' in '$llnode'."
errorQueueDisplay 1 1
dumpNameTable
exit 1
		return 1
	fi

	return 0
}

# *********************************************************************************

