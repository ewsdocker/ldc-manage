# *****************************************************************************
#
#    testLdcDynnNew
#
#      Test performance of the ldcDynnNew function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnNew()
{
	local arrayName=${1}
	ldcerr_result=0

	ldcDynnNew $arrayName
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnNew ERROR ($?)"
		return 1
	}
	
	ldcConioDisplay "testLdcDynnNew ----- successful"
	return 0
}

# ******************************************************************************
#
#	testLdcDynnToStr
#
#		Create a printable string representation of the node arrays
#
#	parameters:
#		name = the name of the array parent
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function testLdcDynnToStr()
{
	ldcConioDisplay ""
	ldcConioDisplay "ldcDynnToStr: ${1}"

	local nodeString
	ldcDynnToStr ${1} nodeString
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDisplay "ldcDynnToStr exited with error number '$?'"
		return 1
	 }

	ldcConioDisplay "${nodeString}"
	
	return 0
}

# *****************************************************************************
#
#    testLdcDynnDestruct
#
#      Test performance of the ldcDynnDestruct function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnDestruct()
{
	local arrayName=${1}
	ldcerr_result=0

	ldcDynnDestruct $arrayName
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnDestruct ERROR ($?)"
		return 1
	}
	
	ldcConioDisplay "testLdcDynnDestruct ----- successful"
	return 0
}

# *****************************************************************************
#
#    testLdcDynnReset
#
#      Test performance of the ldcDynnReset function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnReset()
{
	local arrayName=${1}
	ldcerr_result=0

	ldcDynnReset $arrayName
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnReset ERROR ($?)"
		return 1
	}
	
	ldcConioDisplay "testLdcDynnReset ----- successful"
	return 0
}

# *****************************************************************************
#
#    testLdcDynnReload
#
#      Test performance of the ldcDynnReload function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnReload()
{
	local arrayName=${1}
	ldcerr_result=0

	ldcDynnReload $arrayName
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnReload ERROR ($?)"
		return 1
	}

	ldcConioDisplay "testLdcDynnReload ----- successful"
	return 0
}

# *****************************************************************************
#
#    testLdcDynnValid
#
#      Test performance of the ldcDynnValid function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnValid()
{
	local arrayName=${1}

	ldcDynnValid $arrayName ldctst_valid
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnValid ERROR ($?)"
		return 1
	}
	
	ldcConioDisplay "testLdcDynnValid ----- valid = '${ldctst_valid}'"
	return 0
}

# *****************************************************************************
#
#    testLdcDynnCount
#
#      Test performance of the ldcDynnCount function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnCount()
{
	local arrayName="${1}"
	
	ldcDynnCount $arrayName ldctst_count
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnCount ERROR ($?)"
		return 1
	}

	ldcConioDisplay "testLdcDynnCount ----- count = '${ldctst_count}'"

	return 0
}

# *****************************************************************************
#
#    testLdcDynnCurrent
#
#      Test performance of the ldcDynnCurrent function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnCurrent()
{
	local arrayName="${1}"

	ldcDynnCurrent $arrayName ldctst_current
	[[ $? -eq 0 ]] || 
	 {
		ldcLogDisplay "testLdcDynnCurrent ERROR ($?)"
		return 1
	}

	ldcConioDisplay "testLdcDynnCurrent ----- current = '${ldctst_current}'"

	return 0
}

# *****************************************************************************
#
#    testLdcDynnNext
#
#      Test performance of the ldcDynnNext function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnNext()
{
	local arrayName="${1}"

	testLdcDynnCurrent $arrayName
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnNext ERROR ($?)"
		return $?
	}

	ldcDynnNext $arrayName
	[[ $? -eq 0 ]] || 
	{
		ldcLogDisplay "testLdcDynnNext ERROR ($?)"
		return $?
	}

	[[ ${ldcdyna_index} -eq $ldctst_current ]] && 
	{
		ldcLogDisplay "testLdcDynnNext ERROR index was ($ldcdyna_current), now ($ldcdyna_index)"
		return 1
	}

	ldcConioDisplay "testLdcDynnNext ----- index = '${ldcdyna_index}'"
	return 0
}

# *****************************************************************************
#
#    testLdcDynnKey
#
#      Test performance of the ldcDynnKey function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnKey()
{
	local arrayName="${1}"

	ldcDynnKey $arrayName ldctst_key
	[[ $? -eq 0 ]] || 
	 {
		ldcLogDisplay "testLdcDynnKey ERROR ($?)"
		return 1
	 }

	ldcConioDisplay "testLdcDynnKey ----- key = '${ldctst_key}'"
	return 0
}

# *****************************************************************************
#
#    testLdcDynnMap
#
#      Test performance of the ldcDynnMap function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnMap()
{
	local arrayName="${1}"

	ldcDynnMap $arrayName ldctst_value
	[[ $? -eq 0 ]] || 
	 {
		ldcLogDisplay "testLdcDynnMap ERROR ($?)"
		return 1
	 }

	ldcConioDisplay "testLdcDynnMap ----- value = '${ldctst_value}'"
	return 0
}

# *****************************************************************************
#
#    testDynaNodeItLabel
#
#      Test performance of the dynaNode Iterate functions
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testDynaNodeItLabel()
{
	local arrayName="${1}"

	ldctst_error=0

	ldctst_name="ldcDynnCount"
	testLdcDynnCount ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		ldctst_error=$?
		return 1
	 }

	ldcConioDisplay " ${arrayName} contains $ldctst_count items."
	ldcConioDisplay ""
	ldcConioDisplay "    Field           Value"
	ldcConioDisplay " ============   ============="
	
	return 0
}

# *****************************************************************************
#
#    testLdcDynnGetElement
#
#      Test performance of the ldcDynnGetElement function
#
#	parameters:
#		none
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLdcDynnGetElement()
{
	ldcDynn_GetElement
	[[ $? -eq 0 ]] || 
	 {
		ldcLogDisplay "testLdcDynnGetElement ERROR ($?)"
		return 1
	}

	ldcConioDisplay "testLdcDynnGetElement ----- key = '${ldcdyna_key}', value = '${ldcdyna_value}'"

	return 0
}

# *****************************************************************************
#
#    testDynaNodeIteration
#
#      Test performance of the ldcDynn_GetNext and iteration functions
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testDynaNodeIteration()
{
	local arrayName="${1}"

	testLdcDynnReset ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		ldctst_error=$?
		ldcLogDisplay "testLdcDynnReset ERROR ldctst_error = '${ldctst_error}'"
		return 1
	 }

	testLdcDynnReload ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		ldctst_error=$?
		ldcLogDisplay "DynaNodeInfo" "testLdcDynnReload ERROR ldctst_error = '${ldctst_error}'"
		return 1
	 }

	testDynaNodeItLabel ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		ldctst_error=$?
		ldcLogDisplay "testDynaNodeITLabel ERROR ldctst_error = '${ldctst_error}'"
		return 1
	 }

	while [ true ]
	do
		testLdcDynnGetElement ${arrayName}
		[[ $? -eq 0 ]] ||
		 {
			ldctst_error=$?
			[[ $ldcdyna_valid -eq 0 ]] &&
			 {
				ldcLogDisplay "testLdcDynnGetNext ----- end of iteration, valid = '${ldcdyna_valid}'"
				ldctst_error=0
				return 0
			 }

			ldcLogDisplay "testLdcDynnGetNext ERROR ldctst_error = '${ldctst_error}'"
			break
		 }

		ldcConioDisplay "testDynaNodeIteration ----- ldctst_key = '${ldcdyna_key}'"
		ldcConioDisplay "testDynaNodeIteration ----- ldctst_value = '${ldcdyna_value}'"

		printf "% 12s     %s\n" ${ldcdyna_key} ${ldcdyna_value}

		ldctst_name="ldcDynnNext"
		testLdcDynnNext ${arrayName}
	done

	return 1
}

