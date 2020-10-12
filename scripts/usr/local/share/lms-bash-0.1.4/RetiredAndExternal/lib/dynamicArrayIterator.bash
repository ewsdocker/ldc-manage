# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	dynamicArrayIterator.bash
#
#		Rudimentary array iterator functions for dynamicArray variables..
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.0
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage dynamicArrayIterator
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
#			Version 0.0.1 - 06-11-2016.
#					0.1.0 - 08-07-2016.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r lmslib_dynamicArrayIterator="0.1.0"	# version of library

# ***********************************************************************************************************

declare -A lmsdyn_iterator

declare    lmsdyn_itCurrent

declare    lmsdyn_itKeys
declare    lmsdyn_itKey

declare    lmsdyn_itIndex
declare    lmsdyn_itLimit

# ***********************************************************************************************************
#
#	dynArrayITReset
#
#		Reset the iterator to the first variable in the array
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function dynArrayITReset()
{
	local name="${1}"

	dynArrayITValidName "${name}"
	[[ $? -eq 0 ]] ||
	 {
		return 1
	 }

	lmsdyn_iterator[${name}]=0
	lmsdyn_itIndex=0

	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITGet
#
#		Return the current value pointed to by (lmsdyn_it)
#
#	Parameters:
#		name = name of the array to iterate
#
#	Outputs:
#		value = the value at the current iterator key
#
#	Returns:
#		0 = no error
#		non-zero = unknown index (usually past the end of the array)
#
# *********************************************************************************************************
function dynArrayITGet()
{
	local name=${1}
	local value

	local index=$( dynArrayITMap ${name} )
	[[ $? -eq 0 ]] ||
	 {
		echo 0
		return 1
	 }

	value=$( dynArrayGetAt ${name} $index )
	
	echo "${value}"
   	return $?
}

# ***********************************************************************************************************
#
#	dynArrayITSet
#
#		Set the current value pointed to by (lmsdyn_iterator)
#
#	Parameters:
#		name = name of the array to iterate
#		value = value to set at the current position
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function dynArrayITSet()
{
	local name="${1}"
	local value=${2}

	local index=$( dynArrayITMap "${name}" )
	[[ $? -eq 0 ]] ||
	 {
		return 1
	 }

   	dynArraySetAt "$name" $index "${value}"
   	[[ $? -eq 0 ]] ||
   	 {
   		let lmserr_result=$?+1
   		return $lmserr_result
	 }

	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITNext
#
#		Move the iterator (lmsdyn_iterator) to the next key
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = no error
#		non-zero = unknown index (usually past the end of the array)
#
# *********************************************************************************************************
function dynArrayITNext()
{
	local name="${1}"

	dynArrayITValid "${name}"
	[[ $? -eq 0 ]] ||
	 {
		return 1
	 }

	let lmsdyn_iterator["${name}"]+=1
	lmsdyn_itIndex=${lmsdyn_iterator["${name}"]}

   	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITCurrent
#
#		Return the current iterator index (lmsdyn_itIndex) for the provided array name
#
#	Parameters:
#		name = name of the array
#
#	Output:
#		itIndex = value of the current iterator index
#
#	Returns:
#		0 = no error
#		non-zero = unknown index (usually past the end of the array)
#
# *********************************************************************************************************
function dynArrayITCurrent()
{
	local name="${1}"

	dynArrayITValid "${name}"
	[[ $? -eq 0 ]] ||
	 {
		echo "0"
		return 1
	 }

	lmsdyn_itIndex=${lmsdyn_iterator["${name}"]}

	echo "${lmsdyn_itIndex}"

   	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITCount
#
#		Get the number of items in the array
#
#	Parameters:
#		name = array name
#
#	Outputs:
#		count = integer # of elements
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function dynArrayITCount()
{
	local name="${1}"

	[[ "${name}" == "${lmsdyn_itCurrent}" ]] ||
	{
		dynArrayITValidName "${name}"
		[[ $? -eq 0 ]] ||
		 {
			return 1
		 }
	}

	echo $( dynArrayCount "${name}" )
	return $?
}

# ***********************************************************************************************************
#
#	dynArrayITMap - Map the value in the iterator index to the actual array index
#
#		(This allows for processing sparse and/or associative arrays sequentially 
#			without too much trouble)
#
#	Parameters:
#		name = name of the array to iterate
#
#	Outputs:
#		value = the value at the mapped iterator key
#
#	Returns:
#		0 = no error
#		non-zero = invalid array name or unknown index
#
# *********************************************************************************************************
function dynArrayITMap()
{
	local name="${1}"

	[[ "${name}" == "${lmsdyn_itCurrent}" ]] ||
	{
		lmsdyn_itKeys=""

		dynArrayITValidName "${name}"
		[[ $? -eq 0 ]] ||
		 {
			return 1
		 }
	}

	local index=${lmsdyn_iterator[${name}]}

	[[ -z "${lmsdyn_itKeys}" ]] &&
	 {
		lmsdyn_itKeys=( $( dynArrayKeys ${name} 1 ) )
		[[ $? -eq 0 ]] ||
		 {
			return 1
		 }
	 }

	lmsdyn_itKey="${lmsdyn_itKeys[${index}]}"

	echo "${lmsdyn_itKey}"
	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITValid
#
#		Return true if the iterator is still within range, otherwise false
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = valid
#		non-zero = function error number
#
# *********************************************************************************************************
function dynArrayITValid()
{
	local name=${1}

	[[ "${name}" == "${lmsdyn_itCurrent}" ]] ||
	{
		dynArrayITValidName "${name}"
		[[ $? -eq 0 ]] ||
		 {
			return 1
		 }
	}

	lmsdyn_itLimit=$( dynArrayCount "${name}" 1 )
	[[ $? -eq 0 ]] ||
	 {
		return 2
	 }

	[[ ${lmsdyn_itLimit} -gt 0 && ${lmsdyn_iterator["${name}"]} -ge 0  &&  ${lmsdyn_iterator["${name}"]} -lt ${lmsdyn_itLimit} ]] ||
	 {
		return 3
	 }

	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITValidName
#
#		Return the current value pointed to by (lmsdyn_iterator)
#
#	Parameters:
#		name = name of the array to iterate
#
#	Returns:
#		0 = no error
#		non-zero = bad array name/array not found
#
# *********************************************************************************************************
function dynArrayITValidName()
{
	local name=${1}

	[[ "${lmsdyn_itCurrent}" != "${name}" ]] &&
	 {
		lmsdyn_itCurrent=""
		lmsdyn_itKeys=""

		dynArrayExists ${name}
		[[ $? -eq 0 ]] ||
		 {
			return 1
		 }
		
		if [[ ! " ${!lmsdyn_iterator[@]} " =~ "$name" ]]
		then
			lmsdyn_iterator[${name}]=0
		fi

		lmsdyn_itCurrent=${name}
	 }

	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITActive
#
#		Return the current number of active iterators
#
#	Parameters:
#		none
#
#	Outputs:
#		count = number of active iterators
#
#	Returns:
#		0 = no errors
#
# *********************************************************************************************************
function dynArrayITActive()
{
	echo ${#lmsdyn_iterator[@]}
	return 0
}

# ***********************************************************************************************************
#
#	dynArrayITUnset
#
#		Unset all indexes
#
#	Parameters:
#		name = array name
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# **********************************************************************************************************
function dynArrayITUnset()
{
	local name="${1}"

	dynArrayITValid ${name}
	[[ $? -eq 0 ]] &&
	 {
		lmsdyn_itCurrent=""
		lmsdyn_itKeys=""

		eval unset "${name}"
		eval unset lmsdyn_iterator[${name}]
	 }

   	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#			End
#
# ***********************************************************************************************************
# ***********************************************************************************************************

