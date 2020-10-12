#!/bin/bash

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	dynamicArrayAssociative.bash
#
#		By Jay Wheeler.
#
#			Version 0.0.1 - 07-19-2016.
#
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r lmslib_dynamicArrayAssociative="0.0.2"	# version of library

# ***********************************************************************************************************
#
#	dynAssocCreate
#
#		Dynamically create an array by name
#
#	Parameters:
#		name = new array name
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function dynAssocCreate()
{
	local name="${1}"
	local type=${2:-0}

	if [ ${type} -eq 0 ]
	then
		declare -ga $name=\(\)
	else
		declare -gA $name=\(\)
	fi

	declare -p "lmslib_dynamicArrayIterator" > /dev/null 2>&1
	[[ $? -eq 0 ]] &&
	 {
		dynArrayITReset ${name}
	 }

	return 0
}

# ***********************************************************************************************************
#
#	dynAssocAdd
#
#		Insert at the end of the array ( size(array) )
#
#	Parameters:
#		name = array name
#		value = value to insert
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function dynAssocAdd()
{
	local name="${1}"
	local value=${2}
	local key=${3}

	[[ -z "${name}" || -z "${value}" ]] &&
	{
		return 1
	}

	[[ -z "${key}" ]] &&
	{
		key=$(dynAssocCount ${name} )
	}

	dynAssocSetAt ${name} ${key} "${value}"
	return $?
}

# ***********************************************************************************************************
#
#	dynAssocGet
#
#		Get the dynAssoc content (all of it - i.e. - ${dynAssocay[@]})
#
#	Parameters:
#		name = array name
#
#	Outputs:
#		content = (string) array contents
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ********************************************************************************************************
function dynAssocGet()
{
	local name="${1}"

	local values
	eval 'values=$'"{$name[@]}"

	echo $values
}

# ***********************************************************************************************************
#
#	dynAssocSetAt
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
function dynAssocSetAt()
{
	local name="${1}"
	local key=${2}
	local value=${3}

	eval "$name[${key}]='${value}'"
}

# ***********************************************************************************************************
#
#	dynAssocGetAt
#
#		Get the value stored at a specific index eg. ${array[0]}
#
#	Parameters:
#		name = array name
#		index = array element to get
#
#	Outputs:
#		value = (mixed) value of the indexed item
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function dynAssocGetAt()
{
	local name="${1}"
	local key="${2}"

	local value
	eval 'value=$'"{$name[$key]}"

	echo $value
	return 0
}

# ***********************************************************************************************************
#
#	dynAssocFind
#
#		Search for requested value and return it's index, if found
#
#	Parameters:
#		name = array name
#		value = array value
#
#	Outputs:
#		index = value of the found index
#
#	Returns:
#		0 = no error
#		non-zero = not found
#
# ********************************************************************************************************
function dynAssocFind()
{
	local name="${1}"
	local searchValue="${2}"

	local keylist=dynAssocKeys ${name}

	for key in ${keylist[@]}
	do
		value=dynAssocGetAt ${name} ${key}
		[[ "${searchValue}" == "${value}" ]] &&
		 {
			echo "${key}"
			return 0
		 }
	done

	echo "Not found"
	return 1
}

# ***********************************************************************************************************
#
#	dynAssocKeys
#
#		Get the keys as a list from the specified array
#
#	Parameters:
#		name = array name
#
#	Outputs:
#		keys = string representation of an array's keys
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function dynAssocKeys()
{
	local name="${1}"

	local keys
	eval 'keys=$'"{!$name[@]}"

	echo $keys
}

# ***********************************************************************************************************
#
#	dynAssocCount
#
#		Get the value stored at a specific index eg. ${array[0]}
#
#	Parameters:
#		name = array name
#
#	Outputs:
#		count = integer size of the stack (# elements)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function dynAssocCount()
{
	local name="${1}"
	
	local count
	eval 'count=$'"{#$name[@]}"

	echo ${count}
    return 0
}

# ***********************************************************************************************************
#
#	dynAssocUnset
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
# **********************************************************************************************************
function dynAssocUnset()
{
	local name="${1}"

	declare -p "lmslib_dynamicArrayIterator" > /dev/null 2>&1
	[[ $? -eq 0 ]] &&
	 {
		dynArrayITUnset ${name}
	 }

	declare -n r=${name}
	unset r
}

# ***********************************************************************************************************
#
#	dynAssocValidArray
#
#		validate the passed parameter
#
#	Parameters:
#		parameter = parameter to validate
#
#	Returns:
#		0 = acceptable bash name
#		1 = NOT a valid bash name
#
# **********************************************************************************************************
function dynAssocValidArray()
{
	local name=${1}

  	declare -p "${name}" > /dev/null 2>&1
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "DynArrayError" "Bash variable [${name}] does not exist"
		return 1
	}

	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#		End
#
# ***********************************************************************************************************
# ***********************************************************************************************************

