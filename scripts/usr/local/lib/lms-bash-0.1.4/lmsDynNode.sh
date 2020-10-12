# ******************************************************************************
# ******************************************************************************
#
#   lmsDynNode.sh
#
#		A dynamic array iterator
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.6
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage dynNode
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/lms-bash.
#
#   ewsdocker/lms-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/lms-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/lms-bash.  If not, see 
#   <http://www.gnu.org/licenses/>.
#
# *****************************************************************************
#
#		Version 0.0.1 - 12-27-2016.
#				0.0.2 - 01-04-2017.
#				0.0.3 - 02-08-2017.
#				0.0.4 - 02-10-2017.
#				0.0.5 - 02-19-2017.
#				0.0.6 - 08-25-2018.
#
# ******************************************************************************
# ******************************************************************************

declare  lmslib_dynaNode="0.0.6"			# version of dynaNode library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

# ******************************************************************************
# ******************************************************************************
#
#		Functions - general purpose user functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsDynnNew
#
#		Create the node
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynnNew()
{
	local name="${1}"

	lmsdyna_currentArray="${name}"
	lmsdyna_node="${name}_it"
	lmsdyna_map="${name}_map"

	lmsUtilVarExists ${lmsdyna_node}
	[[ $? -eq 0 ]] ||
	 {
		local type
		lmsUtilIsArray ${lmsdyna_node} "type"
		[[ $? -eq 0 ]] ||
		 {
			[[ "${type}" == "A" ]] || lmsDynn_Destruct
		 }
	 }

	lmsDynnInit ${name}
	return $?
}

# ***********************************************************************************************************
#
#	lmsDynnDestruct
#
#		Delete the iteration arrays of the array being iterated
#
#	Parameters:
#		name = array name
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function lmsDynnDestruct()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	lmsDynn_Destruct
   	return 0
}

# ******************************************************************************
#
#	lmsDynnSet
#
#		Set the specified dynaNode field
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#		field = the name of the field
#		value = the field's value
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynnSet()
{
	[[ -z "${2}" ]] && return 1

	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	lmsDynn_Set "${2}" "${3}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	lmsDynnGet
#
#		Get the specified dynaNode field value
#
#	parameters:
#		nodeName = name of the dynamic array
#		field = name of the field
#		value = location to place the value of the specified field
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynnGet()
{
	[[ -z "${2}" ]] && return 1

	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	lmsDynn_Get "${2}" ${3}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnMap - Map the value in the iterator index and return the indexed dynamic array value
#
#		(This allows for processing sparse and/or associative arrays sequentially 
#			without bumping into holes or invalid indexes)
#
#	Parameters:
#		name = name of the array being iterated
#		value = location to place the value at the mapped iterator key
#		key = (optional) location to place the iterator key
#
#	Returns:
#		0 = no error
#		non-zero = invalid array name or unknown index
#
# *********************************************************************************************************
function lmsDynnMap()
{
	lmsDynnKey "${1}" lmsdyna_key
	[[ $? -eq 0 ]] || return 1

	eval 'lmsdyna_value=$'"{$lmsdyna_currentArray[$lmsdyna_key]}"
	[[ $? -eq 0 ]] || return 2

	lmsDeclareStr ${2} "$lmsdyna_value"
	[[ $? -eq 0 ]] || return 3
	
	[[ -n "${3}" ]] &&
	 {
		lmsDeclareStr ${3} "$lmsdyna_key"
		[[ $? -eq 0 ]] || return 4
	 }

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnKey
#
#		Return the current iterator key (mapped index)
#
#	Parameters:
#		name = name of the array being iterated
#		key = location to store the mapped value of the current iterator index
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynnKey()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDynn_Valid
	lmsdyna_valid=$?
	
	[[ ${lmsdyna_valid} -eq 1 ]] || return 2

	eval 'lmsdyna_key=$'"{$lmsdyna_map[$lmsdyna_index]}"
	[[ $? -eq 0 ]] || return 3

	lmsDeclareStr ${2} "${lmsdyna_key}"
	[[ $? -eq 0 ]] || return 4
	
   	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnNext
#
#		Move the iterator to the next key
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynnNext()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	(( lmsdyna_index++ ))

	lmsDynn_Set "index" ${lmsdyna_index}
	[[ $? -eq 0 ]] || return 2

   	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnReset
#
#		Sets lmsdyna_dirty flag to 
#				recreate the iterator map and 
#				reset iterator to the first item 
#		on the next lmsDynnReload
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynnReset()
{
	local name="${1}"

	[[ "${!lmsdyna_arrays[@]}" =~ "${name}" ]] || return 1

	local node="${name}_it"

	lmsUtilVarExists ${node}
	[[ $? -eq 0 ]] || return 1

	eval $node['remap']=1
	lmsdyna_dirty=1

   	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnCurrent
#
#		Return the current iterator index
#
#	Parameters:
#		name = name of the array being iterated
#		index = location to store the value of the current iterator index
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynnCurrent()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDeclareStr ${2} "$lmsdyna_index"
	[[ $? -eq 0 ]] || return 1

   	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnCount
#
#		Get the number of items in the array being iterated
#
#	Parameters:
#		name = array name
#		count = location to store the integer # of elements
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function lmsDynnCount()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDeclareStr ${2} "$lmsdyna_limit"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynnValid
#
#		Return true if the iterator index is valid, otherwise false
#
#	Parameters:
#		name = name of the array being iterated
#		valid = location to store result: 0 if iterator is valid, else 1
#
#	Returns:
#		0 = no error
#		non-zero = function error number
#
# *********************************************************************************************************
function lmsDynnValid()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDynn_Valid
	lmsdyna_valid=$?

	lmsDeclareStr ${2} ${lmsdyna_valid}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#	lmsDynnInit
#
#		Initialize/Reset the specified dynaNode
#			NOTE: should only be called by lmsDynnNew and lmsDynnReload
#
#	parameters:
#		name  = the name of the array being iterated
#		index = value to set the index property to
#		limit = value to set the limit property to
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynnInit()
{
	local name="${1}"

	[[ " ${!lmsdyna_arrays[@]} " =~ "$name" ]] || return 1

	lmsdyna_currentArray="$name"
	lmsdyna_node="${name}_it"
	lmsdyna_map="${name}_map"

	lmsDynn_Destruct

	declare -gA $lmsdyna_node=\(\) > /dev/null 2>&1
	declare -ga $lmsdyna_map=\(\)  > /dev/null 2>&1

	lmsDynn_Set "name" ${lmsdyna_currentArray}
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "index" 0
	[[ $? -eq 0 ]] || return  1

	eval 'lmsdyna_limit=$'"{#$lmsdyna_currentArray[@]}"
	[[ $? -eq 0 ]] || return 1

	lmsDynn_Set "limit" $lmsdyna_limit
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "remap" 1
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "sort" 0
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "resort" 0
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "value" 0
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "numeric" 0
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "type" 0
	[[ $? -eq 0 ]] || return  1

	lmsDynn_Set "order" 0
	[[ $? -eq 0 ]] || return  1

	lmsDynnReload ${name}
	return $?
}

# ******************************************************************************
#
#	lmsDynnReload
#
#		Reload the specified dynaNode
#			if lmsdyna_dirty is zero and $name equals lmsdyna_currentArray, returns
#
#			if lmsdyna_dirty is non-zero, or $name not equal to lmsdyna_currentArray,
#				- if remap is non-zero, recreates the node array(s)
#				- reloads global variables from the node array(s)
#
#	parameters:
#		name = the name of the array being iterated
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynnReload()
{
	local name="${1}"

	[[ ! "${!lmsdyna_arrays[@]}" =~ "${name}" ]] && return 1

	[[ $lmsdyna_dirty -eq 0  &&  "${lmsdyna_currentArray}" == "${name}" ]] && return 0

	lmsdyna_dirty=1
	lmsdyna_valid=0
	lmsdyna_currentArray="${name}"
	lmsdyna_node="${name}_it"
	lmsdyna_map="${name}_map"

	lmsUtilVarExists ${lmsdyna_node}
	[[ $? -eq 0 ]] || return 2

	lmsDynn_Reload
	[[ $? -eq 0 ]] || return 3

	lmsDynn_Valid
	lmsdyna_valid=$?

	lmsdyna_dirty=0
	return 0
}

# ******************************************************************************
#
#	lmsDynnToStr
#
#		Create a printable string representation of the node arrays
#
#	parameters:
#		name = the name of the array parent
#		string = location to place the string
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynnToStr()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsdyna_nodeString=""
	local nString=""
	local type=""

	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	lmsUtilATS $lmsdyna_node nString
	[[ $? -eq 0 ]] || return 3

	lmsdyna_nodeString="${lmsdyna_nodeString}${nString}"

	lmsUtilATS $lmsdyna_map nString
	[[ $? -eq 0 ]] || return 3

	lmsdyna_nodeString="${lmsdyna_nodeString}${nString}"

	lmsUtilATS "lmsdyna_sortReg" nString
	[[ $? -eq 0 ]] || return 3

	lmsdyna_nodeString="${lmsdyna_nodeString}${nString}"

	lmsUtilATS $lmsdyna_currentArray nString
	[[ $? -eq 0 ]] || return 4

	lmsdyna_nodeString="${lmsdyna_nodeString}${nString}"

	lmsDeclareStr ${2} "${lmsdyna_nodeString}"
	[[ $? -eq 0 ]] || return 5
	
	return 0
}

# ******************************************************************************
# ******************************************************************************
#
#		Internal Functions
#
#	Be aware of the following when using these functions:
#
#		- it is assumed that lmsDynnReload (or its' equivalent) 
#			has already been called to reinstate the values for the 
#			array being iterated, if required;
#		- the value(s) returned may not be the same as the public counterpart
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsDynn_Reload
#
#		Reload the global dynaNode variables from the global arrays
#
#		NOTE: Does NOT modify the lmsdyna_valid global
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynn_Reload()
{
	eval 'lmsdyna_remap=$'"{$lmsdyna_node[remap]}"

	[[ $lmsdyna_remap -eq 0 ]] && lmsDynn_NoRemap || lmsDynn_Remap
	[[ $? -eq 0 ]] || return 1

	lmsDyns_Resort ${lmsdyna_currentArray}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ******************************************************************************
#
#	lmsDynn_NoRemap
#
#		Reload the global dynaNode variables from the global arrays
#
#		NOTE: Does NOT modify the lmsdyna_valid global
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynn_NoRemap
{
	lmsDynn_Get "index" lmsdyna_index
	[[ $? -eq 0 ]] || return 1

	local result=2
	while [[ true ]]
	do
		lmsDynn_Get "limit" lmsdyna_limit
		[[ $? -eq 0 ]] || break

		lmsdyna_keyList="${!lmsdyna_map[@]}"

		lmsDynn_Get "sort" lmsdyna_sort
		[[ $? -eq 0 ]] || break

		lmsDynn_Get "resort" lmsdyna_resort
		[[ $? -eq 0 ]] || break

		lmsDynn_Get "value" lmsdyna_sortValue
		[[ $? -eq 0 ]] || break

		lmsDynn_Get "numeric" lmsdyna_sortNumeric
		[[ $? -eq 0 ]] || break
		
		lmsDynn_Get "order" lmsdyna_sortOrder
		[[ $? -eq 0 ]] || break
		
		lmsDynn_Get "type" lmsdyna_sortType
		[[ $? -eq 0 ]] || break
		
		lmsDynsRegName $lmsdyna_sortType lmsdyna_callback
		[[ $? -eq 0 ]] || break
		
		result=0
		break
	done
	
	[[ $result -eq 0 ]] || return 2
	return 0
}

# ******************************************************************************
#
#	lmsDynn_Remap
#
#		Recreate the global dynaNode variables and arrays from the
#			dynamic array contents
#
#		NOTE: Does NOT modify the lmsdyna_valid global
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynn_Remap()
{
	while [[ true ]]
	do
		eval 'lmsdyna_limit=$'"{#$lmsdyna_currentArray[@]}"
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "limit" ${lmsdyna_limit}
		[[ $? -eq 0 ]] || break

		lmsdyna_index=0
		lmsDynn_Set "index" ${lmsdyna_index}
		[[ $? -eq 0 ]] || break

		eval 'lmsdyna_keyList=$'"{!$lmsdyna_currentArray[@]}"
		[[ $? -eq 0 ]] || break

		eval "$lmsdyna_map=( $lmsdyna_keyList )"

		lmsdyna_remap=0
		lmsDynn_Set "remap" ${lmsdyna_remap}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "order" ${lmsdyna_sortOrder}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "type" ${lmsdyna_sortType}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "value" ${lmsdyna_sortValue}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "numeric" ${lmsdyna_sortNumeric}
		[[ $? -eq 0 ]] || break

		lmsDynn_Get "sort" lmsdyna_sort
		[[ $? -eq 0 ]] || break

		lmsDynn_Get "resort" lmsdyna_resort
		[[ $? -eq 0 ]] || break

		return 0
	done

	return 1
}

# *****************************************************************************
#
#   lmsDynn_GetElement
#
#      return the current Key and Value in passed variables
#
#	parameters:
#		key = location to store the key name
#		value = location to store the key value
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function lmsDynn_GetElement()
{
	lmsDynn_Valid
	[[ $? -eq 0 ]] && 
	 {
		lmsdyna_valid=0
		return 1
	 }

	lmsdyna_valid=1

	eval 'lmsdyna_key=$'"{$lmsdyna_map[$lmsdyna_index]}"
	[[ $? -eq 0 ]] || return 2

	eval 'lmsdyna_value=$'"{$lmsdyna_currentArray[${lmsdyna_key}]}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	lmsDynn_Set
#
#		Set the specified dynaNode field in the CURRENT lmsdyna_currentArray array
#
#	parameters:
#		field = the name of the field
#		value = the field's value
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynn_Set()
{
	local value="${2}"

	eval $lmsdyna_node["${1}"]='${value}'
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ******************************************************************************
#
#	lmsDynn_Get
#
#		Get the specified dynaNode field value from the CURRENT lmsdyna_currentArray array
#
#	parameters:
#		field = name of the field
#		value = location to store the value of the specified field
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDynn_Get()
{
	local field=${1:-""}

	local value
	eval 'value=$'"{$lmsdyna_node[$field]}"
	[[ $? -eq 0 ]] || return 1

	lmsDeclareStr ${2} "${value}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynn_Valid
#
#		Return 1 if the CURRENT iterator index is valid, otherwise 0
#
#	Parameters:
#		none
#
#	Returns:
#		0 = NOT valid
#		1 = valid
#
# *********************************************************************************************************
function lmsDynn_Valid()
{
	[[ ${lmsdyna_limit} -gt 0  &&  ${lmsdyna_index} -ge 0  &&  ${lmsdyna_index} -lt ${lmsdyna_limit} ]]  &&  return 1
	return 0
}

# ***********************************************************************************************************
#
#	lmsDynn_Destruct
#
#		Delete the iteration arrays of the CURRENT array being iterated
#
#	Parameters:
#		none
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function lmsDynn_Destruct()
{
	unset ${lmsdyna_node} > /dev/null 2>&1
	unset ${lmsdyna_map} > /dev/null 2>&1

	lmsdyna_dirty=1
   	return 0
}

