# *****************************************************************************
#
#    testLdcDynaNew
#
#      Test performance of the ldcDynaNew function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaNew()
{
	ldcDynaNew ${1} ${2}
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# ***********************************************************************************************************
#
#	testLdcDynaAdd
#
#		test Insert at the end of the array ( size(array) )
#
#	Parameters:
#		name = array name
#		value = value to insert
#		key = (optional) array key
#
#	Returns:
#		0 = no error
#		non-zero = error code ==> 1 invalid name
#							  ==> 2 missing value parameter
#							  ==> 3 ldcDynaSetAt failed
#
# *********************************************************************************************************
function testLdcDynaAdd()
{
	ldcDynaAdd ${1} "${2}" "${3}"
	[[ $? -eq 0 ]] || 
	{
		ldcConioDisplay "ldcDynaAdd failed for ${1}, '${2}', '${3}' with reply $?"
		return 1
	}

	return 0
}

# *****************************************************************************
#
#    testLdcDynaSetAt
#
#      Test performance of the ldcDynaSetAt function
#
#	parameters:
#		arrayName = name of the dynamic array
#		key = address to set the data
#		data = value to set the key entry to
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaSetAt()
{
	local arrayName="${1}"
	local key="${2}"
	local data="${3}"

	ldcDynaSetAt ${arrayName} "${key}" "${data}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# *****************************************************************************
#
#    testLdcDynaDeleteAt
#
#      Test performance of the ldcDynaDeleteAt function
#
#	parameters:
#		arrayName = name of the dynamic array
#		key = address to set the data
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaDeleteAt()
{
	ldcDynaDeleteAt "${1}" "${2}"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# *****************************************************************************
#
#    testLdcDynaUnset
#
#      Test performance of the ldcDynaUnset function
#
#	parameters:
#		arrayName = name of the dynamic array to delete
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaUnset()
{
	ldcDynaUnset "${1}"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# *****************************************************************************
#
#    testLdcDynaKeys
#
#      Test performance of the ldcDynaKeys function
#
#	parameters:
#		arrayName = name of the dynamic array to delete
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaKeys()
{
	local arrayName="${1}"

	ldcDynaKeys "${arrayName}" ldctst_keys
	[[ $? -eq 0 ]] || return 1

	ldcConioDisplay "ldcDynaKeys: ${arrayName} = $ldctst_keys"
	ldcConioDisplay ""

	return 0
}

# *****************************************************************************
#
#    testLdcDynaGet
#
#      Test performance of the ldcDynaGet function
#
#	parameters:
#		arrayName = name of the dynamic array
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaGet()
{
	local arrayName="${1}"

	ldcDynaGet "${arrayName}" testContent
	[[ $? -eq 0 ]] || return 1

	ldcConioDisplay "ldcDynaGet: ${arrayName} = $testContent"
	ldcConioDisplay ""

	return 0
}

# *****************************************************************************
#
#    testLdcDynaKeyExists
#
#      Test performance of the ldcDynaKeyExists function
#
#	parameters:
#		arrayName = name of the dynamic array
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynaKeyExists()
{
	local arrayName="${1}"
	ldctst_key="${2}"

	while [ true ]
	do
		ldcConioDisplay "ldcDynaKeyExists: ${ldctst_key} = " n

		ldcDynaKeyExists "${arrayName}" "${ldctst_key}"
		[[ $? -eq 0 ]] && 
		 {
			ldcConioDisplay "FOUND"
			break
		 }

		ldcConioDisplay "NOT found"
		break
	done

	ldcConioDisplay ""
	return 0
}

# *****************************************************************************
#
#    testLdcDynaFind
#
#      Test performance of the ldcDynaFind function
#
#	parameters:
#		arrayName = name of the dynamic array
#		value = value to search for
#
#	Returns
#		0 = found
#		1 = not found or error
#
# *****************************************************************************
function testLdcDynaFind()
{
	local arrayName="${1}"
	local value="${2}"

	ldcConioDisplay "ldcDynaFind: value '${value}' " n

	ldcDynaFind "${arrayName}" "${value}" ldctst_find
	[[ $? -eq 0 ]] || 
	 {
		ldcConioDisplay "NOT found."
		ldcConioDisplay ""
		return 1
	 }

	ldcConioDisplay "FOUND at key = $ldctst_find"
	ldcConioDisplay ""
	return 0
}

# *****************************************************************************
#
#    testLdcDynaCount
#
#      Test performance of the ldcDynaCount function
#
#	parameters:
#		arrayName = name of the dynamic array
#
#	Returns
#		0 = found
#		1 = not found or error
#
# *****************************************************************************
function testLdcDynaCount()
{
	local arrayName="${1}"

	ldcDynaCount "${arrayName}" ldctst_count
	[[ $? -eq 0 ]] || return 1

	ldcConioDisplay "ldcDynaCount: ${arrayName} = $ldctst_count"
	ldcConioDisplay ""

	return 0
}

