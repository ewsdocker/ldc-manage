# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	dynamicArrayFunctions.bash
#
#		Based on the article Getting Bashed by Dynamic Arrays by Ludvik Jerabek
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage dynamicArrayFunctions
#
# *****************************************************************************
#
#	Copyright © 2016. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 03-14-2016.
#					0.0.2 - 06-03-2016.
#					0.0.3 - 07-21-2016.
#					0.0.4 - 08-05-2016.
#					0.1.0 - 08-26-2016.
#					0.1.1 - 09-02-2016.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r lmslib_dynamicArrayFunctions="0.1.1"	# version of library

# ***********************************************************************************************************

declare -i lmsdyna_arrayType='a'			# Type of array

# ***********************************************************************************************************
#
#	dynArrayCreate
#
#		Dynamically create an array by name
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
function dynArrayNew()
{
	local name="${1}"
	local type=${2:-"a"}

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		dynArrayUnset ${name}
	 }

	if [ "${type}" == "a" ]
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
#	lmsDynaAdd
#
#		Insert at the end of the array ( size(array) )
#
#	Parameters:
#		name = array name
#		value = value to insert
#
#	Returns:
#		0 = no error
#		non-zero = error code ==> 1 invalid name
#							  ==> 2 missing value parameter
#							  ==> 3 dynArraySetAt failed
#
# *********************************************************************************************************
function dynArrayAdd()
{
	local name="${1}"
	local value="${2}"
	local key=${3}

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		return 1
	 }

	[[ -z "${value}" ]] &&
	 {
		return 2
	 }

	[[ -z "${key}" ]] &&
	 {
		key=$( dynArrayCount ${name} )
	 }

	dynArraySetAt ${name} ${key} "${value}"
	[[ $? -eq 0 ]] ||
	 {
		return 3
	 }

	return 0
}

# ***********************************************************************************************************
#
#	dynArrayGet
#
#		Get the dynArray content (all of it - i.e. - ${dynArrayay[@]})
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
function dynArrayGet()
{
	local name="${1}"

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		echo ""
		return 1
	 }

	local values
	eval 'values=$'"{$name[@]}"

	echo $values
}

# ***********************************************************************************************************
#
#	dynArraySetAt
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
function dynArraySetAt()
{
	local name="${1}"
	local key=${2}
	local value="${3}"

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		return 1
	 }

	eval $name[$key]='${value}'  # <<<<======?
}

# ***********************************************************************************************************
#
#	dynArrayGetAt
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
function dynArrayGetAt()
{
	local name="${1}"
	local key="${2}"

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		echo "0"
		return 1
	 }

	local value
	eval 'value=$'"{$name[$key]}"

	echo $value
	return 0
}

# ***********************************************************************************************************
#
#	dynArrayFind
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
function dynArrayFind()
{
	local name="${1}"
	local searchValue="${2}"

	local keylist=$( dynArrayKeys ${name} )
	[[ $? -eq 0 ]] ||
	 {
		echo ""
		return 1
	 }

	local key
	local value
	local result=""

	for key in ${keylist[@]}
	do
		eval $sUid="'$searchUid'"

		value=$( dynArrayGetAt "${name}" "${key}" )
		[[ $? -eq 0 ]] ||
		 {
			echo ""
			return 1
		 }

		lmsConioDebug $LINENO "Debug" "value = ${value}"

		[[ "${searchValue}" == "${value}" ]] || continue

		eval 'result=$'"{$key}"
		echo $result
		
		return 0
	done

	echo ""
	return 1
}

# ***********************************************************************************************************
#
#	dynArrayKeyExists
#
#		Returns true if the Key is valid, false if not
#
#	Parameters:
#		name = array name
#		key = key value
#
#	Outputs:
#		1 = valid
#		0 = not valid
#
#	Returns:
#		0 = no error
#		non-zero = not found
#
# ********************************************************************************************************
function dynArrayKeyExists()
{
	local name="${1}"
	local key="${2}"

	local keys=$(dynArrayKeys ${name} )
	[[ $? -eq 0 ]] ||
	 {
		echo "0"
		return 1
	 }

	if [[ "${keys[@]}" =~ "${key}" ]]
	then
		echo "1"
		return 0
	fi

	echo "0"
	return 1
}

# ***********************************************************************************************************
#
#	dynArrayKeys
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
function dynArrayKeys()
{
	local name="${1}"
	local keys

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		echo ""
		return 1
	 }

	eval 'keys=$'"{!$name[@]}"

	echo "$keys"
}

# ***********************************************************************************************************
#
#	dynArrayCount
#
#		Get a count of the number of elements in the array
#
#	Parameters:
#		name = array name
#
#	Outputs:
#		count = integer size of the array (# elements)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function dynArrayCount()
{
	local name="${1}"
	local count

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		echo 0
		return 1
	 }

	eval 'count=$'"{#$name[@]}"

	echo ${count}
    return 0
}

# ***********************************************************************************************************
#
#	dynArrayUnset
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
function dynArrayUnset()
{
	local name="${1}"

	dynArrayExists ${name}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "DynArrayError" "Dynamic array ${name} does not exist."
		return 1
	 }

	declare -p "lmslib_dynamicArrayIterator" > /dev/null 2>&1
	[[ $? -eq 0 ]] &&
	 {
		dynArrayITUnset ${name}
	 }

	unset ${name}

	declare -p ${name} > /dev/null 2>&1
	[[ $? -eq 0 ]] && return 1
	
	return 0
}

# ***********************************************************************************************************
#
#	dynArrayExists
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
function dynArrayExists()
{
	local name=${1}

	lmsdyna_arrayType="a"

  	declare -p "${name}" > /dev/null 2>&1
	[[ $? -eq 0 ]] ||
	 {
		return 1
	 }

	declare -a | grep "$name" > /dev/null 2>&1
	[[ $? -eq 0 ]] &&
	 {
		lmsdyna_arrayType="a"
		
		return 0
	 }
	
	declare -A | grep "$name" > /dev/null 2>&1
	[[ $? -eq 0 ]] &&
	 {
		lmsdyna_arrayType="A"
		return 0
	 }
	
	dynArrayUnset ${name}

	return 1
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#		End
#
# ***********************************************************************************************************
# ***********************************************************************************************************

