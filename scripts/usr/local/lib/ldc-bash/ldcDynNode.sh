# ******************************************************************************
# ******************************************************************************
#
#   ldcDynNode.sh
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
#   This file is part of ewsdocker/ldc-bash.
#
#   ewsdocker/ldc-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/ldc-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/ldc-bash.  If not, see 
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

declare  ldclib_dynaNode="0.0.6"			# version of dynaNode library

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
#	ldcDynnNew
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
function ldcDynnNew()
{
	local name="${1}"

	ldcdyna_currentArray="${name}"
	ldcdyna_node="${name}_it"
	ldcdyna_map="${name}_map"

	ldcUtilVarExists ${ldcdyna_node}
	[[ $? -eq 0 ]] ||
	 {
		local type
		ldcUtilIsArray ${ldcdyna_node} "type"
		[[ $? -eq 0 ]] ||
		 {
			[[ "${type}" == "A" ]] || ldcDynn_Destruct
		 }
	 }

	ldcDynnInit ${name}
	return $?
}

# ***********************************************************************************************************
#
#	ldcDynnDestruct
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
function ldcDynnDestruct()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	ldcDynn_Destruct
   	return 0
}

# ******************************************************************************
#
#	ldcDynnSet
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
function ldcDynnSet()
{
	[[ -z "${2}" ]] && return 1

	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	ldcDynn_Set "${2}" "${3}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	ldcDynnGet
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
function ldcDynnGet()
{
	[[ -z "${2}" ]] && return 1

	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	ldcDynn_Get "${2}" ${3}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnMap - Map the value in the iterator index and return the indexed dynamic array value
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
function ldcDynnMap()
{
	ldcDynnKey "${1}" ldcdyna_key
	[[ $? -eq 0 ]] || return 1

	eval 'ldcdyna_value=$'"{$ldcdyna_currentArray[$ldcdyna_key]}"
	[[ $? -eq 0 ]] || return 2

	ldcDeclareStr ${2} "$ldcdyna_value"
	[[ $? -eq 0 ]] || return 3
	
	[[ -n "${3}" ]] &&
	 {
		ldcDeclareStr ${3} "$ldcdyna_key"
		[[ $? -eq 0 ]] || return 4
	 }

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnKey
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
function ldcDynnKey()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDynn_Valid
	ldcdyna_valid=$?
	
	[[ ${ldcdyna_valid} -eq 1 ]] || return 2

	eval 'ldcdyna_key=$'"{$ldcdyna_map[$ldcdyna_index]}"
	[[ $? -eq 0 ]] || return 3

	ldcDeclareStr ${2} "${ldcdyna_key}"
	[[ $? -eq 0 ]] || return 4
	
   	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnNext
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
function ldcDynnNext()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	(( ldcdyna_index++ ))

	ldcDynn_Set "index" ${ldcdyna_index}
	[[ $? -eq 0 ]] || return 2

   	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnReset
#
#		Sets ldcdyna_dirty flag to 
#				recreate the iterator map and 
#				reset iterator to the first item 
#		on the next ldcDynnReload
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function ldcDynnReset()
{
	local name="${1}"

	[[ "${!ldcdyna_arrays[@]}" =~ "${name}" ]] || return 1

	local node="${name}_it"

	ldcUtilVarExists ${node}
	[[ $? -eq 0 ]] || return 1

	eval $node['remap']=1
	ldcdyna_dirty=1

   	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnCurrent
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
function ldcDynnCurrent()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDeclareStr ${2} "$ldcdyna_index"
	[[ $? -eq 0 ]] || return 1

   	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnCount
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
function ldcDynnCount()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDeclareStr ${2} "$ldcdyna_limit"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynnValid
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
function ldcDynnValid()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDynn_Valid
	ldcdyna_valid=$?

	ldcDeclareStr ${2} ${ldcdyna_valid}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#	ldcDynnInit
#
#		Initialize/Reset the specified dynaNode
#			NOTE: should only be called by ldcDynnNew and ldcDynnReload
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
function ldcDynnInit()
{
	local name="${1}"

	[[ " ${!ldcdyna_arrays[@]} " =~ "$name" ]] || return 1

	ldcdyna_currentArray="$name"
	ldcdyna_node="${name}_it"
	ldcdyna_map="${name}_map"

	ldcDynn_Destruct

	declare -gA $ldcdyna_node=\(\) > /dev/null 2>&1
	declare -ga $ldcdyna_map=\(\)  > /dev/null 2>&1

	ldcDynn_Set "name" ${ldcdyna_currentArray}
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "index" 0
	[[ $? -eq 0 ]] || return  1

	eval 'ldcdyna_limit=$'"{#$ldcdyna_currentArray[@]}"
	[[ $? -eq 0 ]] || return 1

	ldcDynn_Set "limit" $ldcdyna_limit
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "remap" 1
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "sort" 0
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "resort" 0
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "value" 0
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "numeric" 0
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "type" 0
	[[ $? -eq 0 ]] || return  1

	ldcDynn_Set "order" 0
	[[ $? -eq 0 ]] || return  1

	ldcDynnReload ${name}
	return $?
}

# ******************************************************************************
#
#	ldcDynnReload
#
#		Reload the specified dynaNode
#			if ldcdyna_dirty is zero and $name equals ldcdyna_currentArray, returns
#
#			if ldcdyna_dirty is non-zero, or $name not equal to ldcdyna_currentArray,
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
function ldcDynnReload()
{
	local name="${1}"

	[[ ! "${!ldcdyna_arrays[@]}" =~ "${name}" ]] && return 1

	[[ $ldcdyna_dirty -eq 0  &&  "${ldcdyna_currentArray}" == "${name}" ]] && return 0

	ldcdyna_dirty=1
	ldcdyna_valid=0
	ldcdyna_currentArray="${name}"
	ldcdyna_node="${name}_it"
	ldcdyna_map="${name}_map"

	ldcUtilVarExists ${ldcdyna_node}
	[[ $? -eq 0 ]] || return 2

	ldcDynn_Reload
	[[ $? -eq 0 ]] || return 3

	ldcDynn_Valid
	ldcdyna_valid=$?

	ldcdyna_dirty=0
	return 0
}

# ******************************************************************************
#
#	ldcDynnToStr
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
function ldcDynnToStr()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	ldcdyna_nodeString=""
	local nString=""
	local type=""

	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	ldcUtilATS $ldcdyna_node nString
	[[ $? -eq 0 ]] || return 3

	ldcdyna_nodeString="${ldcdyna_nodeString}${nString}"

	ldcUtilATS $ldcdyna_map nString
	[[ $? -eq 0 ]] || return 3

	ldcdyna_nodeString="${ldcdyna_nodeString}${nString}"

	ldcUtilATS "ldcdyna_sortReg" nString
	[[ $? -eq 0 ]] || return 3

	ldcdyna_nodeString="${ldcdyna_nodeString}${nString}"

	ldcUtilATS $ldcdyna_currentArray nString
	[[ $? -eq 0 ]] || return 4

	ldcdyna_nodeString="${ldcdyna_nodeString}${nString}"

	ldcDeclareStr ${2} "${ldcdyna_nodeString}"
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
#		- it is assumed that ldcDynnReload (or its' equivalent) 
#			has already been called to reinstate the values for the 
#			array being iterated, if required;
#		- the value(s) returned may not be the same as the public counterpart
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	ldcDynn_Reload
#
#		Reload the global dynaNode variables from the global arrays
#
#		NOTE: Does NOT modify the ldcdyna_valid global
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcDynn_Reload()
{
	eval 'ldcdyna_remap=$'"{$ldcdyna_node[remap]}"

	[[ $ldcdyna_remap -eq 0 ]] && ldcDynn_NoRemap || ldcDynn_Remap
	[[ $? -eq 0 ]] || return 1

	ldcDyns_Resort ${ldcdyna_currentArray}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ******************************************************************************
#
#	ldcDynn_NoRemap
#
#		Reload the global dynaNode variables from the global arrays
#
#		NOTE: Does NOT modify the ldcdyna_valid global
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcDynn_NoRemap
{
	ldcDynn_Get "index" ldcdyna_index
	[[ $? -eq 0 ]] || return 1

	local result=2
	while [[ true ]]
	do
		ldcDynn_Get "limit" ldcdyna_limit
		[[ $? -eq 0 ]] || break

		ldcdyna_keyList="${!ldcdyna_map[@]}"

		ldcDynn_Get "sort" ldcdyna_sort
		[[ $? -eq 0 ]] || break

		ldcDynn_Get "resort" ldcdyna_resort
		[[ $? -eq 0 ]] || break

		ldcDynn_Get "value" ldcdyna_sortValue
		[[ $? -eq 0 ]] || break

		ldcDynn_Get "numeric" ldcdyna_sortNumeric
		[[ $? -eq 0 ]] || break
		
		ldcDynn_Get "order" ldcdyna_sortOrder
		[[ $? -eq 0 ]] || break
		
		ldcDynn_Get "type" ldcdyna_sortType
		[[ $? -eq 0 ]] || break
		
		ldcDynsRegName $ldcdyna_sortType ldcdyna_callback
		[[ $? -eq 0 ]] || break
		
		result=0
		break
	done
	
	[[ $result -eq 0 ]] || return 2
	return 0
}

# ******************************************************************************
#
#	ldcDynn_Remap
#
#		Recreate the global dynaNode variables and arrays from the
#			dynamic array contents
#
#		NOTE: Does NOT modify the ldcdyna_valid global
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcDynn_Remap()
{
	while [[ true ]]
	do
		eval 'ldcdyna_limit=$'"{#$ldcdyna_currentArray[@]}"
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "limit" ${ldcdyna_limit}
		[[ $? -eq 0 ]] || break

		ldcdyna_index=0
		ldcDynn_Set "index" ${ldcdyna_index}
		[[ $? -eq 0 ]] || break

		eval 'ldcdyna_keyList=$'"{!$ldcdyna_currentArray[@]}"
		[[ $? -eq 0 ]] || break

		eval "$ldcdyna_map=( $ldcdyna_keyList )"

		ldcdyna_remap=0
		ldcDynn_Set "remap" ${ldcdyna_remap}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "order" ${ldcdyna_sortOrder}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "type" ${ldcdyna_sortType}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "value" ${ldcdyna_sortValue}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "numeric" ${ldcdyna_sortNumeric}
		[[ $? -eq 0 ]] || break

		ldcDynn_Get "sort" ldcdyna_sort
		[[ $? -eq 0 ]] || break

		ldcDynn_Get "resort" ldcdyna_resort
		[[ $? -eq 0 ]] || break

		return 0
	done

	return 1
}

# *****************************************************************************
#
#   ldcDynn_GetElement
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
function ldcDynn_GetElement()
{
	ldcDynn_Valid
	[[ $? -eq 0 ]] && 
	 {
		ldcdyna_valid=0
		return 1
	 }

	ldcdyna_valid=1

	eval 'ldcdyna_key=$'"{$ldcdyna_map[$ldcdyna_index]}"
	[[ $? -eq 0 ]] || return 2

	eval 'ldcdyna_value=$'"{$ldcdyna_currentArray[${ldcdyna_key}]}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ******************************************************************************
#
#	ldcDynn_Set
#
#		Set the specified dynaNode field in the CURRENT ldcdyna_currentArray array
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
function ldcDynn_Set()
{
	local value="${2}"

	eval $ldcdyna_node["${1}"]='${value}'
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ******************************************************************************
#
#	ldcDynn_Get
#
#		Get the specified dynaNode field value from the CURRENT ldcdyna_currentArray array
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
function ldcDynn_Get()
{
	local field=${1:-""}

	local value
	eval 'value=$'"{$ldcdyna_node[$field]}"
	[[ $? -eq 0 ]] || return 1

	ldcDeclareStr ${2} "${value}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynn_Valid
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
function ldcDynn_Valid()
{
	[[ ${ldcdyna_limit} -gt 0  &&  ${ldcdyna_index} -ge 0  &&  ${ldcdyna_index} -lt ${ldcdyna_limit} ]]  &&  return 1
	return 0
}

# ***********************************************************************************************************
#
#	ldcDynn_Destruct
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
function ldcDynn_Destruct()
{
	unset ${ldcdyna_node} > /dev/null 2>&1
	unset ${ldcdyna_map} > /dev/null 2>&1

	ldcdyna_dirty=1
   	return 0
}

