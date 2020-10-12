# *****************************************************************************
#
#    testLmsDynnNew
#
#      Test performance of the lmsDynnNew function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnNew()
{
	local arrayName=${1}
	lmserr_result=0

	lmsDynnNew $arrayName
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnNew ERROR ($?)"
		return 1
	}
	
	lmsConioDisplay "testLmsDynnNew ----- successful"
	return 0
}

# ******************************************************************************
#
#	testLmsDynnToStr
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
function testLmsDynnToStr()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsDynnToStr: ${1}"

	local nodeString
	lmsDynnToStr ${1} nodeString
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDisplay "lmsDynnToStr exited with error number '$?'"
		return 1
	 }

	lmsConioDisplay "${nodeString}"
	
	return 0
}

# *****************************************************************************
#
#    testLmsDynnDestruct
#
#      Test performance of the lmsDynnDestruct function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnDestruct()
{
	local arrayName=${1}
	lmserr_result=0

	lmsDynnDestruct $arrayName
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnDestruct ERROR ($?)"
		return 1
	}
	
	lmsConioDisplay "testLmsDynnDestruct ----- successful"
	return 0
}

# *****************************************************************************
#
#    testLmsDynnReset
#
#      Test performance of the lmsDynnReset function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnReset()
{
	local arrayName=${1}
	lmserr_result=0

	lmsDynnReset $arrayName
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnReset ERROR ($?)"
		return 1
	}
	
	lmsConioDisplay "testLmsDynnReset ----- successful"
	return 0
}

# *****************************************************************************
#
#    testLmsDynnReload
#
#      Test performance of the lmsDynnReload function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnReload()
{
	local arrayName=${1}
	lmserr_result=0

	lmsDynnReload $arrayName
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnReload ERROR ($?)"
		return 1
	}

	lmsConioDisplay "testLmsDynnReload ----- successful"
	return 0
}

# *****************************************************************************
#
#    testLmsDynnValid
#
#      Test performance of the lmsDynnValid function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnValid()
{
	local arrayName=${1}

	lmsDynnValid $arrayName lmstst_valid
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnValid ERROR ($?)"
		return 1
	}
	
	lmsConioDisplay "testLmsDynnValid ----- valid = '${lmstst_valid}'"
	return 0
}

# *****************************************************************************
#
#    testLmsDynnCount
#
#      Test performance of the lmsDynnCount function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnCount()
{
	local arrayName="${1}"
	
	lmsDynnCount $arrayName lmstst_count
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnCount ERROR ($?)"
		return 1
	}

	lmsConioDisplay "testLmsDynnCount ----- count = '${lmstst_count}'"

	return 0
}

# *****************************************************************************
#
#    testLmsDynnCurrent
#
#      Test performance of the lmsDynnCurrent function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnCurrent()
{
	local arrayName="${1}"

	lmsDynnCurrent $arrayName lmstst_current
	[[ $? -eq 0 ]] || 
	 {
		lmsLogDisplay "testLmsDynnCurrent ERROR ($?)"
		return 1
	}

	lmsConioDisplay "testLmsDynnCurrent ----- current = '${lmstst_current}'"

	return 0
}

# *****************************************************************************
#
#    testLmsDynnNext
#
#      Test performance of the lmsDynnNext function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnNext()
{
	local arrayName="${1}"

	testLmsDynnCurrent $arrayName
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnNext ERROR ($?)"
		return $?
	}

	lmsDynnNext $arrayName
	[[ $? -eq 0 ]] || 
	{
		lmsLogDisplay "testLmsDynnNext ERROR ($?)"
		return $?
	}

	[[ ${lmsdyna_index} -eq $lmstst_current ]] && 
	{
		lmsLogDisplay "testLmsDynnNext ERROR index was ($lmsdyna_current), now ($lmsdyna_index)"
		return 1
	}

	lmsConioDisplay "testLmsDynnNext ----- index = '${lmsdyna_index}'"
	return 0
}

# *****************************************************************************
#
#    testLmsDynnKey
#
#      Test performance of the lmsDynnKey function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnKey()
{
	local arrayName="${1}"

	lmsDynnKey $arrayName lmstst_key
	[[ $? -eq 0 ]] || 
	 {
		lmsLogDisplay "testLmsDynnKey ERROR ($?)"
		return 1
	 }

	lmsConioDisplay "testLmsDynnKey ----- key = '${lmstst_key}'"
	return 0
}

# *****************************************************************************
#
#    testLmsDynnMap
#
#      Test performance of the lmsDynnMap function
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnMap()
{
	local arrayName="${1}"

	lmsDynnMap $arrayName lmstst_value
	[[ $? -eq 0 ]] || 
	 {
		lmsLogDisplay "testLmsDynnMap ERROR ($?)"
		return 1
	 }

	lmsConioDisplay "testLmsDynnMap ----- value = '${lmstst_value}'"
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

	lmstst_error=0

	lmstst_name="lmsDynnCount"
	testLmsDynnCount ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		lmstst_error=$?
		return 1
	 }

	lmsConioDisplay " ${arrayName} contains $lmstst_count items."
	lmsConioDisplay ""
	lmsConioDisplay "    Field           Value"
	lmsConioDisplay " ============   ============="
	
	return 0
}

# *****************************************************************************
#
#    testLmsDynnGetElement
#
#      Test performance of the lmsDynnGetElement function
#
#	parameters:
#		none
#
#	Returns
#		0 = no error
#		1 = error
#
# *****************************************************************************
function testLmsDynnGetElement()
{
	lmsDynn_GetElement
	[[ $? -eq 0 ]] || 
	 {
		lmsLogDisplay "testLmsDynnGetElement ERROR ($?)"
		return 1
	}

	lmsConioDisplay "testLmsDynnGetElement ----- key = '${lmsdyna_key}', value = '${lmsdyna_value}'"

	return 0
}

# *****************************************************************************
#
#    testDynaNodeIteration
#
#      Test performance of the lmsDynn_GetNext and iteration functions
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

	testLmsDynnReset ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		lmstst_error=$?
		lmsLogDisplay "testLmsDynnReset ERROR lmstst_error = '${lmstst_error}'"
		return 1
	 }

	testLmsDynnReload ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		lmstst_error=$?
		lmsLogDisplay "DynaNodeInfo" "testLmsDynnReload ERROR lmstst_error = '${lmstst_error}'"
		return 1
	 }

	testDynaNodeItLabel ${arrayName}
	[[ $? -eq 0 ]] || 
	 {
		lmstst_error=$?
		lmsLogDisplay "testDynaNodeITLabel ERROR lmstst_error = '${lmstst_error}'"
		return 1
	 }

	while [ true ]
	do
		testLmsDynnGetElement ${arrayName}
		[[ $? -eq 0 ]] ||
		 {
			lmstst_error=$?
			[[ $lmsdyna_valid -eq 0 ]] &&
			 {
				lmsLogDisplay "testLmsDynnGetNext ----- end of iteration, valid = '${lmsdyna_valid}'"
				lmstst_error=0
				return 0
			 }

			lmsLogDisplay "testLmsDynnGetNext ERROR lmstst_error = '${lmstst_error}'"
			break
		 }

		lmsConioDisplay "testDynaNodeIteration ----- lmstst_key = '${lmsdyna_key}'"
		lmsConioDisplay "testDynaNodeIteration ----- lmstst_value = '${lmsdyna_value}'"

		printf "% 12s     %s\n" ${lmsdyna_key} ${lmsdyna_value}

		lmstst_name="lmsDynnNext"
		testLmsDynnNext ${arrayName}
	done

	return 1
}

