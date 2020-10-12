# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	ldcDynArray.sh
#
#		Dynamic array functionality.
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.4
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage dynaArray
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
#			Version 0.0.1 - 03-14-2016.
#					0.0.2 - 06-03-2016.
#					0.0.3 - 07-21-2016.
#					0.0.4 - 08-05-2016.
#					0.1.0 - 08-26-2016.
#					0.1.1 - 09-02-2016.
#					0.2.0 - 01-10-2017.
#					0.2.1 - 01-31-2017.
#					0.2.2 - 02-08-2017.
#					0.2.3 - 02-10-2017.
#					0.2.4 - 08-25-2018.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare    ldclib_ldcDynArray="0.2.4"	# version of library

declare    ldcdyna_currentArray=""	# current dynamic array name
declare    ldcdyna_arrayType="A"	# type of array

declare -A ldcdyna_arrays=()		# dynamic array directory
declare    ldcdyna_node=""			# name of the current dynaNode iterator
declare    ldcdyna_map=""			# map array for the current dynaNode iterator

declare    ldcdyna_keyList=""		# list of keys

declare    ldcdyna_index=""			# current iterator index
declare    ldcdyna_limit=0			#                  limit

declare    ldcdyna_key=""			# most recent key content retrieved
declare    ldcdyna_value=""			# most recent value content retrieved

declare -i ldcdyna_dirty=0			# set to 1 to force re-loading vars from current array
declare -i ldcdyna_valid=0			# results of the most recent validity check

declare    ldcdyna_remap=0			# remap is needed during ldcDynnReload

declare    ldcdyna_sort=0			# sort enabled if 1
declare    ldcdyna_resort=0			#     re-sort required
declare    ldcdyna_sortValue=0		#     sort values if 1, keys if 0
declare    ldcdyna_sortType=0		#     sort type: 0=bubble, ... (default=0)
declare    ldcdyna_sortOrder=0		#     0 = ascending, 1 = descending
declare    ldcdyna_sortNumeric=0    #

declare    ldcdyna_callback="ldcDyns_Bubble"
declare -a ldcdyna_sortReg=( "ldcDyns_Bubble" )

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#		Functions
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	ldcDynaNew
#
#		Create a new dynamic array
#
#	Parameters:
#		name = new array name
#		type = array type - 'a' ==> sequential, 'A' ==> associative
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function ldcDynaNew()
{
	local name="${1}"
	local type=${2:-"a"}

	ldcdyna_currentArray="${name}"
	ldcdyna_dirty=1

	ldcUtilVarExists ${ldcdyna_currentArray}
	[[ $? -eq 0 ]] || ldcDynaUnset ${ldcdyna_currentArray}

	if [[ "${type}" == "a" ]]
	then
		declare -ga $name=\(\)
		ldcdyna_arrays["${name}"]="a"
	else
		declare -gA $name=\(\)
		ldcdyna_arrays["${name}"]="A"
	fi

	ldcDynnNew "${name}"
	[[ $? -eq 0 ]] || return 1
		
	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaAdd
#
#		Insert at the end of the array ( size(array) )
#
#	Parameters:
#		name = array name
#		value = value to insert
#		key = (optional) array key
#
#	Returns:
#		0 = no error
#		non-zero = error code ==> 1 missing value parameter
#							  ==> 2 invalid name
#							  ==> 3 ldcDynaSetAt failed
#							  ==> 4 ldcDyna_Count failed
#
# *********************************************************************************************************
function ldcDynaAdd()
{
	local lname=${1:-""}
	local lvalue=${2:-""}
	local lkey=${3:-""}
	
	local lresult=1
	
	while [ true ]
	do		
		[[ -z "${lvalue}" ]] && break

		(( lresult++ ))

		ldcDynaRegistered "${lname}"
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		[[ -z "${lkey}" ]] && 
		{
			ldcDyna_Count lkey
			[[ $? -eq 0 ]] || break
		}

		(( lresult++ ))

		ldcDyna_SetAt ${lkey} "${lvalue}"
		[[ $? -eq 0 ]] || break
		
		lresult=0
		break
	done
	
	return $lresult
}

# ***********************************************************************************************************
#
#	ldcDynaSetAt
#
#		Update an index by position
#
#	Parameters:
#		name = array name
#		key = array location (index) to put the value
#		value = value to insert
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ********************************************************************************************************
function ldcDynaSetAt()
{
	[[ -z "${2}"  ]] && return 1

#	local name=${1}
#	local key="${2}"
#	local value="${3}"

	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_SetAt "${2}" "${3}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaGetAt
#
#		Get the value stored at a specific index eg. ${array[0]}
#
#	Parameters:
#		name = array name
#		key = array element to get
#		value = location to place the value of the indexed item
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function ldcDynaGetAt()
{
	[[ -z "${2}" || -z "${3}" ]] && return 1
	
	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_GetAt ${2} ${3}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	EXPERIMENTAL - NOT WORKING
#
#	ldcDynaDeleteAt
#
#		Delete the value stored at a specific index eg. ${array[0]} or ${array[field]}
#
#	Parameters:
#		name = array name
#		key = array element to delete
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function ldcDynaDeleteAt()
{
	[[ -z "${2}" ]] && return 1
	
	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_DeleteAt "${2}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaGet
#
#		Get the dynaArray content (all of it - i.e. - ${dynaArray[@]})
#
#	Parameters:
#		name = array name
#		content = the location (variable) to store the result
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ********************************************************************************************************
function ldcDynaGet()
{
	[[ -z "${2}" ]] && return 1
	
	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_Get ${2}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaKeys
#
#		Get the keys as a list from the specified array
#
#	Parameters:
#		name = array name
#		keys = location to place the string representation of an array's keys
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function ldcDynaKeys()
{
	[[ -z "${2}" ]] && return 1
	
	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_Keys ${2}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaFind
#
#		Search for requested value and return it's index, if found
#
#	Parameters:
#		name = array name
#		value = array value
#		index = location to put the result
#
#	Returns:
#		0 = no error
#		non-zero = not found
#
# ********************************************************************************************************
function ldcDynaFind()
{
	while [ true ]
	do		
		[[ -z "${2}" || -z "${3}" ]] && break
	
		ldcDynaRegistered "${1}"
		[[ $? -eq 0 ]] || break

		ldcDyna_Find "${2}" ${3}
		[[ $? -eq 0 ]] || break
	
		return 0
	done
	
	return 1
}

# ***********************************************************************************************************
#
#	ldcDynaKeyExists
#
#		Returns true if the Key is valid, false if not
#
#	Parameters:
#		name = array name
#		key = key value
#
#	Returns:
#		0 = valid
#		1 = not valid
#
# ********************************************************************************************************
function ldcDynaKeyExists()
{
	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_KeyExists "${2}"
	[[ $? -eq 0 ]] && return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaCount
#
#		Get a count of the number of elements in the array
#
#	Parameters:
#		name = array name
#		count = location to place the integer size of the array (# elements)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function ldcDynaCount()
{
echo "ldcDynaCount ${1} ${2}"

	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyna_Count ${2}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaUnset
#
#		Uset all indexes and the array
#
#	Parameters:
#		name = array name
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **************************************************************************************
function ldcDynaUnset()
{
	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] &&
	 {
		ldcDynnDestruct ${ldcdyna_currentArray}
		eval unset ldcdyna_arrays[${1}]
	 }

	eval unset "${ldcdyna_currentArray}"

	ldcUtilVarExists ${ldcdyna_currentArray}
	[[ $? -eq 0 ]] && return 1
	
	ldcdyna_currentArray=""
	ldcdyna_dirty=1

	ldcdyna_sort=0
	ldcdyna_resort=0
	ldcdyna_sortValue=0
	ldcdyna_sortType=0
	ldcdyna_sortOrder=0

	ldcdyna_callback="ldcDyns_Bubble"

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaRegistered
#
#		validate the passed parameter
#
#	Parameters:
#		name = array name to check for
#
#	Returns:
#		0 = exists
#		1 = does NOT exist
#
# **********************************************************************************************************
function ldcDynaRegistered()
{
	local name=${1}

	while [ true ]
	do
		[[ ! " ${!ldcdyna_arrays[@]} " =~ "$name" ]] && break
		[[ "${name}" == "${ldcdyna_currentArray}"  &&  ${ldcdyna_dirty} -eq 0 ]] && return 0
	
		ldcdyna_arrayType="${ldcdyna_arrays[$name]}"
		ldcdyna_dirty=1

		ldcDynnReload ${name}
		[[ $? -eq 0 ]] || break

		ldcdyna_dirty=0
		return 0
	done

	ldcdyna_currentArray=""
	ldcdyna_dirty=1

	return 1
}

# ***********************************************************************************************************
#
#	ldcDynaActive
#
#		Return the current number of registered arrays
#
#	Parameters:
#		count = location to put the number of active iterators
#
#	Returns:
#		0 = no errors
#
# *********************************************************************************************************
function ldcDynaActive()
{
	ldcDeclareStr ${1} "${#ldcdyna_arrays[@]}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynaType
#
#		Return the type of a registered array
#
#	Parameters:
#		name = array name
#		type = location to put the array type
#
#	Returns:
#		0 = no errors
#		non-zero = error code
#
# *********************************************************************************************************
function ldcDynaType()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	ldcDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 2

	ldcdyna_arrayType="${ldcdyna_arrays[$name]}"
	ldcDeclareStr ${2} $ldcdyna_arrayType
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#		Internal Functions
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	ldcDyna_SetAt
#
#		Update the CURRENT array index by position
#
#	Parameters:
#		key = array location (index) to put the value
#		value = value to insert
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ********************************************************************************************************
function ldcDyna_SetAt()
{
	local key="${1}"
	local value="${2}"

	eval "$ldcdyna_currentArray[$key]='${value}'"

	ldcDynnReset "$ldcdyna_currentArray"
	[[ $? -eq 0 ]] || return 1

	ldcdyna_dirty=1
	return 0
}

# ***********************************************************************************************************
#
#	ldcDyna_GetAt
#
#		Get the value stored at a specific index eg. ${array[0]} - ASSUMES the key exists
#
#	Parameters:
#		key = array element to get
#		value = location to place the result
#
#	Returns:
#		0 = no error
#		non-zero = error
#
# *********************************************************************************************************
function ldcDyna_GetAt()
{
	local value
	eval 'value=$'"{$ldcdyna_currentArray[${1}]}"

	ldcDeclareStr ${2} "${value}"
	[[ $? -eq 0 ]] || break

	return 0
}

# ***********************************************************************************************************
#
#	ldcDyna_Count
#
#		Get a count of the number of elements in the array
#
#	Parameters:
#		count = location to store the number of elements
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function ldcDyna_Count()
{
	local count
	eval 'count=$'"{#$ldcdyna_currentArray[@]}"

	ldcDeclareStr ${1} "${count}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	EXPERIMENTAL - NOT WORKING
#
#	ldcDyna_DeleteAt
#
#		Deletes the item at the specified Key, if it is valid
#
#	Parameters:
#		key = key value
#
#	Returns:
#		1 = valid
#		0 = not valid
#
# ********************************************************************************************************
function ldcDyna_DeleteAt()
{
	local key="${1}"

	while [ true ]
	do
		ldcDyna_KeyExists $key
		[[ $? -eq 0 ]] || break

		eval 'unset $'"${ldcdyna_currentArray[$key]}"
		[[ $? -eq 0 ]] || break

		ldcDynnReset $ldcdyna_currentArray
		[[ $? -eq 0 ]] || break

		return 0
	done

	return 1
}

# ***********************************************************************************************************
#
#	ldcDyna_KeyExists
#
#		Returns 1 if the Key is valid, 0 if not
#
#	Parameters:
#		key = key value
#
#	Returns:
#		1 = valid
#		0 = not valid
#
# ********************************************************************************************************
function ldcDyna_KeyExists()
{
	local key="${1}"

	while [ true ]
	do
		local klist
		ldcDyna_Keys klist
		[[ $? -eq 0 ]] || break

		local karray=( " $klist " )
		[[  "${karray[@]}" =~ "${key}" ]] || break
	
		return 1
	done

	return 0
}

# ***********************************************************************************************************
#
#	ldcDyna_Get
#
#		Get the dynaArray content (all of it - i.e. - ${dynaArray[@]})
#
#	Parameters:
#		content = location to place the array values (contents) string
#
#	Returns:
#		0 = no error
#		1 = error
#
# ********************************************************************************************************
function ldcDyna_Get()
{
	local values
	eval 'values=$'"{$ldcdyna_currentArray[@]}"

	ldcDeclareStr ${1} "${values}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcDyna_Keys
#
#		Get the keys as a list from the specified array
#
#	Parameters:
#		keys = location to place the string representation of an array's keys
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function ldcDyna_Keys()
{
	while [ true ]
	do
		ldcDynnReset $ldcdyna_currentArray
		[[ $? -eq 0 ]] || break

		ldcDynnReload $ldcdyna_currentArray
		[[ $? -eq 0 ]] || break

		ldcDeclareStr ${1} "${ldcdyna_keyList}"
		[[ $? -eq 0 ]] || break

		return 0
	done
	
	return 1
}

# ***********************************************************************************************************
#
#	ldcDyna_Find
#
#		Search for requested value and return it's index, if found
#
#	Parameters:
#		value = array value
#		index = place to put the index of the found value
#
#	Returns:
#		0 = no error (found)
#		non-zero = not found
#
# ********************************************************************************************************
function ldcDyna_Find()
{
	local svalue="${1}"

	local klist
	local karray=()

	while [ true ]
	do
		ldcDyna_Get klist
		[[ $? -eq 0 ]] || break

		[[ " ${klist} " =~ "$svalue" ]] || break

		ldcDyna_Keys klist
		[[ $? -eq 0 ]] || break

		karray=( " $klist " )
		[[ $? -eq 0 ]] || break

		local key

		for key in ${karray[@]}
		do
			ldcDyna_GetAt "${key}" klist
			[[ $? -eq 0 ]] || break

			[[ "${klist}" == "${svalue}" ]] || continue

			ldcDeclareStr ${2} "${key}"
			[[ $? -eq 0 ]] || break

			return 0
		done

		break
	done

	return 1
}

