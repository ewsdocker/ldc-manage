# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	lmsDynArray.sh
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

declare    lmslib_lmsDynArray="0.2.4"	# version of library

declare    lmsdyna_currentArray=""	# current dynamic array name
declare    lmsdyna_arrayType="A"	# type of array

declare -A lmsdyna_arrays=()		# dynamic array directory
declare    lmsdyna_node=""			# name of the current dynaNode iterator
declare    lmsdyna_map=""			# map array for the current dynaNode iterator

declare    lmsdyna_keyList=""		# list of keys

declare    lmsdyna_index=""			# current iterator index
declare    lmsdyna_limit=0			#                  limit

declare    lmsdyna_key=""			# most recent key content retrieved
declare    lmsdyna_value=""			# most recent value content retrieved

declare -i lmsdyna_dirty=0			# set to 1 to force re-loading vars from current array
declare -i lmsdyna_valid=0			# results of the most recent validity check

declare    lmsdyna_remap=0			# remap is needed during lmsDynnReload

declare    lmsdyna_sort=0			# sort enabled if 1
declare    lmsdyna_resort=0			#     re-sort required
declare    lmsdyna_sortValue=0		#     sort values if 1, keys if 0
declare    lmsdyna_sortType=0		#     sort type: 0=bubble, ... (default=0)
declare    lmsdyna_sortOrder=0		#     0 = ascending, 1 = descending
declare    lmsdyna_sortNumeric=0    #

declare    lmsdyna_callback="lmsDyns_Bubble"
declare -a lmsdyna_sortReg=( "lmsDyns_Bubble" )

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#		Functions
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	lmsDynaNew
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
function lmsDynaNew()
{
	local name="${1}"
	local type=${2:-"a"}

	lmsdyna_currentArray="${name}"
	lmsdyna_dirty=1

	lmsUtilVarExists ${lmsdyna_currentArray}
	[[ $? -eq 0 ]] || lmsDynaUnset ${lmsdyna_currentArray}

	if [[ "${type}" == "a" ]]
	then
		declare -ga $name=\(\)
		lmsdyna_arrays["${name}"]="a"
	else
		declare -gA $name=\(\)
		lmsdyna_arrays["${name}"]="A"
	fi

	lmsDynnNew "${name}"
	[[ $? -eq 0 ]] || return 1
		
	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaAdd
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
#							  ==> 3 lmsDynaSetAt failed
#							  ==> 4 lmsDyna_Count failed
#
# *********************************************************************************************************
function lmsDynaAdd()
{
	local lname=${1:-""}
	local lvalue=${2:-""}
	local lkey=${3:-""}
	
	local lresult=1
	
	while [ true ]
	do		
		[[ -z "${lvalue}" ]] && break

		(( lresult++ ))

		lmsDynaRegistered "${lname}"
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		[[ -z "${lkey}" ]] && 
		{
			lmsDyna_Count lkey
			[[ $? -eq 0 ]] || break
		}

		(( lresult++ ))

		lmsDyna_SetAt ${lkey} "${lvalue}"
		[[ $? -eq 0 ]] || break
		
		lresult=0
		break
	done
	
	return $lresult
}

# ***********************************************************************************************************
#
#	lmsDynaSetAt
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
function lmsDynaSetAt()
{
	[[ -z "${2}"  ]] && return 1

#	local name=${1}
#	local key="${2}"
#	local value="${3}"

	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_SetAt "${2}" "${3}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaGetAt
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
function lmsDynaGetAt()
{
	[[ -z "${2}" || -z "${3}" ]] && return 1
	
	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_GetAt ${2} ${3}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	EXPERIMENTAL - NOT WORKING
#
#	lmsDynaDeleteAt
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
function lmsDynaDeleteAt()
{
	[[ -z "${2}" ]] && return 1
	
	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_DeleteAt "${2}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaGet
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
function lmsDynaGet()
{
	[[ -z "${2}" ]] && return 1
	
	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_Get ${2}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaKeys
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
function lmsDynaKeys()
{
	[[ -z "${2}" ]] && return 1
	
	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_Keys ${2}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaFind
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
function lmsDynaFind()
{
	while [ true ]
	do		
		[[ -z "${2}" || -z "${3}" ]] && break
	
		lmsDynaRegistered "${1}"
		[[ $? -eq 0 ]] || break

		lmsDyna_Find "${2}" ${3}
		[[ $? -eq 0 ]] || break
	
		return 0
	done
	
	return 1
}

# ***********************************************************************************************************
#
#	lmsDynaKeyExists
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
function lmsDynaKeyExists()
{
	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_KeyExists "${2}"
	[[ $? -eq 0 ]] && return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaCount
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
function lmsDynaCount()
{
echo "lmsDynaCount ${1} ${2}"

	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyna_Count ${2}
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaUnset
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
function lmsDynaUnset()
{
	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] &&
	 {
		lmsDynnDestruct ${lmsdyna_currentArray}
		eval unset lmsdyna_arrays[${1}]
	 }

	eval unset "${lmsdyna_currentArray}"

	lmsUtilVarExists ${lmsdyna_currentArray}
	[[ $? -eq 0 ]] && return 1
	
	lmsdyna_currentArray=""
	lmsdyna_dirty=1

	lmsdyna_sort=0
	lmsdyna_resort=0
	lmsdyna_sortValue=0
	lmsdyna_sortType=0
	lmsdyna_sortOrder=0

	lmsdyna_callback="lmsDyns_Bubble"

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaRegistered
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
function lmsDynaRegistered()
{
	local name=${1}

	while [ true ]
	do
		[[ ! " ${!lmsdyna_arrays[@]} " =~ "$name" ]] && break
		[[ "${name}" == "${lmsdyna_currentArray}"  &&  ${lmsdyna_dirty} -eq 0 ]] && return 0
	
		lmsdyna_arrayType="${lmsdyna_arrays[$name]}"
		lmsdyna_dirty=1

		lmsDynnReload ${name}
		[[ $? -eq 0 ]] || break

		lmsdyna_dirty=0
		return 0
	done

	lmsdyna_currentArray=""
	lmsdyna_dirty=1

	return 1
}

# ***********************************************************************************************************
#
#	lmsDynaActive
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
function lmsDynaActive()
{
	lmsDeclareStr ${1} "${#lmsdyna_arrays[@]}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynaType
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
function lmsDynaType()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsDynaRegistered "${1}"
	[[ $? -eq 0 ]] || return 2

	lmsdyna_arrayType="${lmsdyna_arrays[$name]}"
	lmsDeclareStr ${2} $lmsdyna_arrayType
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
#	lmsDyna_SetAt
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
function lmsDyna_SetAt()
{
	local key="${1}"
	local value="${2}"

	eval "$lmsdyna_currentArray[$key]='${value}'"

	lmsDynnReset "$lmsdyna_currentArray"
	[[ $? -eq 0 ]] || return 1

	lmsdyna_dirty=1
	return 0
}

# ***********************************************************************************************************
#
#	lmsDyna_GetAt
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
function lmsDyna_GetAt()
{
	local value
	eval 'value=$'"{$lmsdyna_currentArray[${1}]}"

	lmsDeclareStr ${2} "${value}"
	[[ $? -eq 0 ]] || break

	return 0
}

# ***********************************************************************************************************
#
#	lmsDyna_Count
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
function lmsDyna_Count()
{
	local count
	eval 'count=$'"{#$lmsdyna_currentArray[@]}"

	lmsDeclareStr ${1} "${count}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	EXPERIMENTAL - NOT WORKING
#
#	lmsDyna_DeleteAt
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
function lmsDyna_DeleteAt()
{
	local key="${1}"

	while [ true ]
	do
		lmsDyna_KeyExists $key
		[[ $? -eq 0 ]] || break

		eval 'unset $'"${lmsdyna_currentArray[$key]}"
		[[ $? -eq 0 ]] || break

		lmsDynnReset $lmsdyna_currentArray
		[[ $? -eq 0 ]] || break

		return 0
	done

	return 1
}

# ***********************************************************************************************************
#
#	lmsDyna_KeyExists
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
function lmsDyna_KeyExists()
{
	local key="${1}"

	while [ true ]
	do
		local klist
		lmsDyna_Keys klist
		[[ $? -eq 0 ]] || break

		local karray=( " $klist " )
		[[  "${karray[@]}" =~ "${key}" ]] || break
	
		return 1
	done

	return 0
}

# ***********************************************************************************************************
#
#	lmsDyna_Get
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
function lmsDyna_Get()
{
	local values
	eval 'values=$'"{$lmsdyna_currentArray[@]}"

	lmsDeclareStr ${1} "${values}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsDyna_Keys
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
function lmsDyna_Keys()
{
	while [ true ]
	do
		lmsDynnReset $lmsdyna_currentArray
		[[ $? -eq 0 ]] || break

		lmsDynnReload $lmsdyna_currentArray
		[[ $? -eq 0 ]] || break

		lmsDeclareStr ${1} "${lmsdyna_keyList}"
		[[ $? -eq 0 ]] || break

		return 0
	done
	
	return 1
}

# ***********************************************************************************************************
#
#	lmsDyna_Find
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
function lmsDyna_Find()
{
	local svalue="${1}"

	local klist
	local karray=()

	while [ true ]
	do
		lmsDyna_Get klist
		[[ $? -eq 0 ]] || break

		[[ " ${klist} " =~ "$svalue" ]] || break

		lmsDyna_Keys klist
		[[ $? -eq 0 ]] || break

		karray=( " $klist " )
		[[ $? -eq 0 ]] || break

		local key

		for key in ${karray[@]}
		do
			lmsDyna_GetAt "${key}" klist
			[[ $? -eq 0 ]] || break

			[[ "${klist}" == "${svalue}" ]] || continue

			lmsDeclareStr ${2} "${key}"
			[[ $? -eq 0 ]] || break

			return 0
		done

		break
	done

	return 1
}

