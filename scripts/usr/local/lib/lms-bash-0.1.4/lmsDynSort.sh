# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	lmsDynSort.sh
#
#		Provide sort routines for dynamic arrays.
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage dynaArray
#
# *****************************************************************************
#
#	Copyright © 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 02-01-2017.
#					0.0.2 - 02-08-2017.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare    lmslib_lmsDynSort="0.0.2"	# version of library

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#		Functions
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	dynaSort
#
#		Dynamic array in-place sort entry point
#
#	Parameters:
#		name = dynamic array name to be sorted
#		callback = name of the sorting function
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function dynaSort()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local name=${1}
	lmsdyna_callback=${2}

	local regNum
	lmsDynsRegister ${lmsdyna_callback} regNum
	[[ $? -eq 0 ]] || return 2

	lmsDynn_Set "type" ${regNum}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsInit
#
#		Dynamic array in-place sort initialization function
#
#	Parameters:
#		name = dynamic array name to be sorted
#		type = type of sort to be performed
#		key = 0 to sort data, 1 to sort keys
#		order = 0 for ascending, 1 for descending
#		numeric = 0 for alhpa-numeric values, 1 for numeric values
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsInit()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2
	
	local name=${1}
	local type=${2:-0}
	local key=${3:-0}
	local order=${4:-0}
	local numeric=${5:-0}

	local regNum
	local result=2

	while [[ true ]]
	do
		lmsDynn_Set "value" ${key}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "type" ${type}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "order" ${order}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "numeric" ${numeric}
		[[ $? -eq 0 ]] || break

		lmsDynn_Set "resort" 1
		[[ $? -eq 0 ]] || break
	
		lmsDynn_Set "sort" 0
		[[ $? -eq 0 ]] || break
		
		lmsDynsRegName ${type} lmsdyna_callback
		[[ $? -eq 0 ]] || break

		result=0
		break
	done

	return $result
}

# ***********************************************************************************************************
#
#	lmsDynsSetValue
#
#		Dynamic array in-place sort set "value" value
#
#	Parameters:
#		name = dynamic array name to be sorted
#		value = sort by value: 0 = key sort, 1 = value sort (default)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsSetValue()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	lmsdyna_sortValue=${2:-1}

	lmsDynn_Set "value" ${lmsdyna_sortValue}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsSetNum
#
#		Dynamic array in-place sort set "numeric" value
#
#	Parameters:
#		name = dynamic array name to be sorted
#		numeric = 0 ==> key/value is NOT numeric (default), 1 = key/value is numeric
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsSetNum()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	lmsdyna_sortNumeric=${2:-0}

	lmsDynn_Set "numeric" ${lmsdyna_sortNumeric}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsSetType
#
#		Dynamic array in-place sort set "type" value
#
#	Parameters:
#		name = dynamic array name to be sorted
#		type = registration number of the callback function
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsSetType()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	local regName=""
	lmsDynsRegName ${2} regName
	[[ $? -eq 0 ]] || return 3

	lmsdyna_callback=$regName

	lmsdyna_type=${2}
	lmsDynn_Set "type" ${lmsdyna_type}
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsSetOrder
#
#		Dynamic array in-place sort set "order" value
#
#	Parameters:
#		name = dynamic array name to be sorted
#		order = sort order value: 0 = ascending, 1 = descending
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsSetOrder()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local name=${1}
	lmsdyna_sortOrder=${2:-0}

	lmsDynn_Set "order" ${lmsdyna_sortOrder}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsDisable
#
#		Dynamic array in-place sort disable function
#
#	Parameters:
#		name = dynamic array name to be sorted
#		disable = (optional) 1 to enable, 0 to disable (default = 0)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsDisable()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local disable=${2:-1}

	[[ $disable -eq 0 ]] &&
	{
		lmsDynsEnable ${1} 1
		[[ $? -eq 0 ]] || return 2

		return 0
	}

	lmsdyna_sort=0
	lmsDynn_Set "sort" ${lmsdyna_sort}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsEnable
#
#		Dynamic array in-place sort enable function
#
#	Parameters:
#		name = dynamic array name to be sorted
#		enable = (optional) 1 to enable, 0 to disable (default = 1)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsEnable()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local enable=${2:-1}
	[[ ${enable} -eq 1 ]]  ||
	 {
		lmsDynsDisable ${lmsdyna_currentArray} 1
		[[ $? -eq 0 ]] || return 2

		return 0
	 }

	lmsdyna_sort=1
	lmsDynn_Set "sort" ${lmsdyna_sort}
	[[ $? -eq 0 ]] || return 3

	lmsDyns_Resort
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsSetResort
#
#		Dynamic array in-place sort enable function
#
#	Parameters:
#		name = dynamic array name to be sorted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsSetResort()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	lmsDyns_SetResort
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsRegister
#
#		Dynamic array in-place sort - register sort callback 
#
#	Parameters:
#		name = dynamic array sort function to register
#		regNumber = location to place the callback registration number
#		update = 1 == > add to the registry if not found, 
#				 0 ==> don't add (generate error code)
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsRegister()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local name="${1}"
	local update=${3:-0}

	[[ ! "${!lmsdyna_sortReg[@]}" =~ "${name}" ]] &&
	 {
		[[ ${update} -eq 0 ]] && return 2
	
		lmsdyna_sortReg+=( ${name} )
	 }

	local index=0

	while [[ $index -lt ${#lmsdyna_sortReg[*]} ]]
	do
		[[ "${lmsdyna_sortReg[$index]}" == "${name}" ]] && 
		 {
			lmsDeclareStr ${2} $index
			[[ $? -eq 0 ]] || return 3
			
			return 0
		 }

		(( index++ ))
	done

	return 4
}

# ***********************************************************************************************************
#
#	lmsDynsRegName
#
#		Dynamic array in-place sort - registration name lookup 
#
#	Parameters:
#		regNumber = dynamic array sort function index to lookup
#		regName = location to place the registered function name
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsRegName()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local type=${1}

	[[ ! " ${!lmsdyna_sortReg[@]} " =~ "$type" ]] && return 2

	lmsDeclareStr ${2} "${lmsdyna_sortReg[$type]}"
	[[ $? -eq 0 ]] || return 3
	
	return 0
}

# ***********************************************************************************************************
#
#	lmsDynsBubble
#
#		Dynamic array in-place bubble sort 
#
#	Parameters:
#		name = dynamic array name to be sorted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDynsBubble()
{
	lmsDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	lmsDyns_Bubble
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#			Non-public
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	lmsDyns_SetResort
#
#		Dynamic array in-place sort enable function
#
#	Parameters:
#		none
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDyns_SetResort()
{
	lmsdyna_resort=1
	lmsDynn_Set "resort" ${lmsdyna_resort}
	[[ $? -eq 0 ]] || return 1

	lmsDyns_Resort
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsDyns_Resort
#
#		Dynamic array in-place sort re-sort entry point
#
#	Parameters:
#		none
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDyns_Resort()
{
	[[ ${lmsdyna_sort} -ne 0  &&  ${lmsdyna_resort} -ne 0 ]] || return 0

	eval ${lmsdyna_callback}
	[[ $? -eq 0 ]] || return 2

	[[ ${lmsdyna_sortError} -eq 0 ]] || return 1

	lmsDynn_Set "resort" 0
	return 0
}

# ***********************************************************************************************************
#
#	lmsDyns_Bubble
#
#		Dynamic array in-place bubble sort 
#
#	Parameters:
#		none
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDyns_Bubble()
{
	local ubound
	local current
	local next

	local type="${lmsdyna_arrays[$lmsdyna_currentArray]}"

	lmsDynn_Get "limit" ubound
	[[ $? -eq 0 ]] || return 1

	(( ubound-- ))
    while ((ubound > 0))
	do
		local index=0
		while ((index < ubound))
		do
			eval 'current=$'"{$lmsdyna_map[$index]}"
			eval 'next=$'"{$lmsdyna_map[$((index + 1))]}"

			lmsDyns_BubbleCmpV $type $index "${current}" "${next}"
			((++index))
		done

		((--ubound))
	done

	lmsdyna_sortError=0
	return 0
}

# ***********************************************************************************************************
#
#	lmsDyns_BubbleCmpV
#
#		Compare 2 fields and swap if the 'current' index is greater than the 'next' index 
#
#	Parameters:
#		type = type of array ("a" or "A")
#		index = current index
#		current = map value of index
#		next = map value of index+1
#
#	Returns:
#		0 = no error
#
# *********************************************************************************************************
function lmsDyns_BubbleCmpV()
{
	local type=${1}
	local index=${2}
	local current=${3}
	local next=${4}

	local cValue=$current
	local nValue=$next

	[[ $lmsdyna_sortValue -eq 1 ]] &&
	 {
		eval 'cValue=$'"{$lmsdyna_currentArray[$current]}"
		eval 'nValue=$'"{$lmsdyna_currentArray[$next]}"
	 }

	if [[ $type == "a" ]]
	then
		[[ $lmsdyna_sortValue -eq 0 || $lmsdyna_sortNumeric -eq 1 ]] &&
		 {
			printf -v cValue "%05u" ${cValue}
			printf -v nValue "%05u" ${nValue}
		 }
	else
		[[ $lmsdyna_sortNumeric -eq 1 ]] &&
		 {
			printf -v cValue "%05u" ${cValue}
			printf -v nValue "%05u" ${nValue}
		 }
	fi

	if [ ${cValue} \> ${nValue} ]
	then
		lmsDyns_BubbleSwap $index $current $next
	fi
	
	return 0
}

# ***********************************************************************************************************
#
#	lmsDyns_BubbleSwap
#
#		swap the map value in index with the value in index+1 
#
#	Parameters:
#		index = current index
#		current = map value of index
#		next = map value of index+1
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************************************
function lmsDyns_BubbleSwap()
{
	local index=${1}
	local current=${2}
	local next=${3}

	eval $lmsdyna_map[$index]="${next}"
	eval $lmsdyna_map[$((index + 1))]="${current}"
	
	return 0
}


