# ***********************************************************************************************************
# ***********************************************************************************************************
#
#	ldcDynSort.sh
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

declare    ldclib_ldcDynSort="0.0.2"	# version of library

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

	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local name=${1}
	ldcdyna_callback=${2}

	local regNum
	ldcDynsRegister ${ldcdyna_callback} regNum
	[[ $? -eq 0 ]] || return 2

	ldcDynn_Set "type" ${regNum}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsInit
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
function ldcDynsInit()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	ldcDynnReload "${1}"
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
		ldcDynn_Set "value" ${key}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "type" ${type}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "order" ${order}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "numeric" ${numeric}
		[[ $? -eq 0 ]] || break

		ldcDynn_Set "resort" 1
		[[ $? -eq 0 ]] || break
	
		ldcDynn_Set "sort" 0
		[[ $? -eq 0 ]] || break
		
		ldcDynsRegName ${type} ldcdyna_callback
		[[ $? -eq 0 ]] || break

		result=0
		break
	done

	return $result
}

# ***********************************************************************************************************
#
#	ldcDynsSetValue
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
function ldcDynsSetValue()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	ldcdyna_sortValue=${2:-1}

	ldcDynn_Set "value" ${ldcdyna_sortValue}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsSetNum
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
function ldcDynsSetNum()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	ldcdyna_sortNumeric=${2:-0}

	ldcDynn_Set "numeric" ${ldcdyna_sortNumeric}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsSetType
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
function ldcDynsSetType()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 2

	local regName=""
	ldcDynsRegName ${2} regName
	[[ $? -eq 0 ]] || return 3

	ldcdyna_callback=$regName

	ldcdyna_type=${2}
	ldcDynn_Set "type" ${ldcdyna_type}
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsSetOrder
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
function ldcDynsSetOrder()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local name=${1}
	ldcdyna_sortOrder=${2:-0}

	ldcDynn_Set "order" ${ldcdyna_sortOrder}
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsDisable
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
function ldcDynsDisable()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local disable=${2:-1}

	[[ $disable -eq 0 ]] &&
	{
		ldcDynsEnable ${1} 1
		[[ $? -eq 0 ]] || return 2

		return 0
	}

	ldcdyna_sort=0
	ldcDynn_Set "sort" ${ldcdyna_sort}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsEnable
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
function ldcDynsEnable()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	local enable=${2:-1}
	[[ ${enable} -eq 1 ]]  ||
	 {
		ldcDynsDisable ${ldcdyna_currentArray} 1
		[[ $? -eq 0 ]] || return 2

		return 0
	 }

	ldcdyna_sort=1
	ldcDynn_Set "sort" ${ldcdyna_sort}
	[[ $? -eq 0 ]] || return 3

	ldcDyns_Resort
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsSetResort
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
function ldcDynsSetResort()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1
	
	ldcDyns_SetResort
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsRegister
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
function ldcDynsRegister()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local name="${1}"
	local update=${3:-0}

	[[ ! "${!ldcdyna_sortReg[@]}" =~ "${name}" ]] &&
	 {
		[[ ${update} -eq 0 ]] && return 2
	
		ldcdyna_sortReg+=( ${name} )
	 }

	local index=0

	while [[ $index -lt ${#ldcdyna_sortReg[*]} ]]
	do
		[[ "${ldcdyna_sortReg[$index]}" == "${name}" ]] && 
		 {
			ldcDeclareStr ${2} $index
			[[ $? -eq 0 ]] || return 3
			
			return 0
		 }

		(( index++ ))
	done

	return 4
}

# ***********************************************************************************************************
#
#	ldcDynsRegName
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
function ldcDynsRegName()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local type=${1}

	[[ ! " ${!ldcdyna_sortReg[@]} " =~ "$type" ]] && return 2

	ldcDeclareStr ${2} "${ldcdyna_sortReg[$type]}"
	[[ $? -eq 0 ]] || return 3
	
	return 0
}

# ***********************************************************************************************************
#
#	ldcDynsBubble
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
function ldcDynsBubble()
{
	ldcDynnReload "${1}"
	[[ $? -eq 0 ]] || return 1

	ldcDyns_Bubble
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
#	ldcDyns_SetResort
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
function ldcDyns_SetResort()
{
	ldcdyna_resort=1
	ldcDynn_Set "resort" ${ldcdyna_resort}
	[[ $? -eq 0 ]] || return 1

	ldcDyns_Resort
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcDyns_Resort
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
function ldcDyns_Resort()
{
	[[ ${ldcdyna_sort} -ne 0  &&  ${ldcdyna_resort} -ne 0 ]] || return 0

	eval ${ldcdyna_callback}
	[[ $? -eq 0 ]] || return 2

	[[ ${ldcdyna_sortError} -eq 0 ]] || return 1

	ldcDynn_Set "resort" 0
	return 0
}

# ***********************************************************************************************************
#
#	ldcDyns_Bubble
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
function ldcDyns_Bubble()
{
	local ubound
	local current
	local next

	local type="${ldcdyna_arrays[$ldcdyna_currentArray]}"

	ldcDynn_Get "limit" ubound
	[[ $? -eq 0 ]] || return 1

	(( ubound-- ))
    while ((ubound > 0))
	do
		local index=0
		while ((index < ubound))
		do
			eval 'current=$'"{$ldcdyna_map[$index]}"
			eval 'next=$'"{$ldcdyna_map[$((index + 1))]}"

			ldcDyns_BubbleCmpV $type $index "${current}" "${next}"
			((++index))
		done

		((--ubound))
	done

	ldcdyna_sortError=0
	return 0
}

# ***********************************************************************************************************
#
#	ldcDyns_BubbleCmpV
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
function ldcDyns_BubbleCmpV()
{
	local type=${1}
	local index=${2}
	local current=${3}
	local next=${4}

	local cValue=$current
	local nValue=$next

	[[ $ldcdyna_sortValue -eq 1 ]] &&
	 {
		eval 'cValue=$'"{$ldcdyna_currentArray[$current]}"
		eval 'nValue=$'"{$ldcdyna_currentArray[$next]}"
	 }

	if [[ $type == "a" ]]
	then
		[[ $ldcdyna_sortValue -eq 0 || $ldcdyna_sortNumeric -eq 1 ]] &&
		 {
			printf -v cValue "%05u" ${cValue}
			printf -v nValue "%05u" ${nValue}
		 }
	else
		[[ $ldcdyna_sortNumeric -eq 1 ]] &&
		 {
			printf -v cValue "%05u" ${cValue}
			printf -v nValue "%05u" ${nValue}
		 }
	fi

	if [ ${cValue} \> ${nValue} ]
	then
		ldcDyns_BubbleSwap $index $current $next
	fi
	
	return 0
}

# ***********************************************************************************************************
#
#	ldcDyns_BubbleSwap
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
function ldcDyns_BubbleSwap()
{
	local index=${1}
	local current=${2}
	local next=${3}

	eval $ldcdyna_map[$index]="${next}"
	eval $ldcdyna_map[$((index + 1))]="${current}"
	
	return 0
}


