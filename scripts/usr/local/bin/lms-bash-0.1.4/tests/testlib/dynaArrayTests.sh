# *****************************************************************************
#
#    testLmsDynaNew
#
#      Test performance of the lmsDynaNew function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynaNew()
{
	lmsDynaNew ${1} ${2}
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# ***********************************************************************************************************
#
#	testLmsDynaAdd
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
#							  ==> 3 lmsDynaSetAt failed
#
# *********************************************************************************************************
function testLmsDynaAdd()
{
	lmsDynaAdd ${1} "${2}" "${3}"
	[[ $? -eq 0 ]] || 
	{
		lmsConioDisplay "lmsDynaAdd failed for ${1}, '${2}', '${3}' with reply $?"
		return 1
	}

	return 0
}

# *****************************************************************************
#
#    testLmsDynaSetAt
#
#      Test performance of the lmsDynaSetAt function
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
function testLmsDynaSetAt()
{
	local arrayName="${1}"
	local key="${2}"
	local data="${3}"

	lmsDynaSetAt ${arrayName} "${key}" "${data}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# *****************************************************************************
#
#    testLmsDynaDeleteAt
#
#      Test performance of the lmsDynaDeleteAt function
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
function testLmsDynaDeleteAt()
{
	lmsDynaDeleteAt "${1}" "${2}"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# *****************************************************************************
#
#    testLmsDynaUnset
#
#      Test performance of the lmsDynaUnset function
#
#	parameters:
#		arrayName = name of the dynamic array to delete
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynaUnset()
{
	lmsDynaUnset "${1}"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# *****************************************************************************
#
#    testLmsDynaKeys
#
#      Test performance of the lmsDynaKeys function
#
#	parameters:
#		arrayName = name of the dynamic array to delete
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynaKeys()
{
	local arrayName="${1}"

	lmsDynaKeys "${arrayName}" lmstst_keys
	[[ $? -eq 0 ]] || return 1

	lmsConioDisplay "lmsDynaKeys: ${arrayName} = $lmstst_keys"
	lmsConioDisplay ""

	return 0
}

# *****************************************************************************
#
#    testLmsDynaGet
#
#      Test performance of the lmsDynaGet function
#
#	parameters:
#		arrayName = name of the dynamic array
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynaGet()
{
	local arrayName="${1}"

	lmsDynaGet "${arrayName}" testContent
	[[ $? -eq 0 ]] || return 1

	lmsConioDisplay "lmsDynaGet: ${arrayName} = $testContent"
	lmsConioDisplay ""

	return 0
}

# *****************************************************************************
#
#    testLmsDynaKeyExists
#
#      Test performance of the lmsDynaKeyExists function
#
#	parameters:
#		arrayName = name of the dynamic array
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynaKeyExists()
{
	local arrayName="${1}"
	lmstst_key="${2}"

	while [ true ]
	do
		lmsConioDisplay "lmsDynaKeyExists: ${lmstst_key} = " n

		lmsDynaKeyExists "${arrayName}" "${lmstst_key}"
		[[ $? -eq 0 ]] && 
		 {
			lmsConioDisplay "FOUND"
			break
		 }

		lmsConioDisplay "NOT found"
		break
	done

	lmsConioDisplay ""
	return 0
}

# *****************************************************************************
#
#    testLmsDynaFind
#
#      Test performance of the lmsDynaFind function
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
function testLmsDynaFind()
{
	local arrayName="${1}"
	local value="${2}"

	lmsConioDisplay "lmsDynaFind: value '${value}' " n

	lmsDynaFind "${arrayName}" "${value}" lmstst_find
	[[ $? -eq 0 ]] || 
	 {
		lmsConioDisplay "NOT found."
		lmsConioDisplay ""
		return 1
	 }

	lmsConioDisplay "FOUND at key = $lmstst_find"
	lmsConioDisplay ""
	return 0
}

# *****************************************************************************
#
#    testLmsDynaCount
#
#      Test performance of the lmsDynaCount function
#
#	parameters:
#		arrayName = name of the dynamic array
#
#	Returns
#		0 = found
#		1 = not found or error
#
# *****************************************************************************
function testLmsDynaCount()
{
	local arrayName="${1}"

	lmsDynaCount "${arrayName}" lmstst_count
	[[ $? -eq 0 ]] || return 1

	lmsConioDisplay "lmsDynaCount: ${arrayName} = $lmstst_count"
	lmsConioDisplay ""

	return 0
}

