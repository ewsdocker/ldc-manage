#!/bin/bash

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#   dynamicStackFunctions.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.2 - 03-15-2016.
#
#	Dependencies:
#
#		dynamicArrayFunctions.bash
#		lmsUId
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r lmslib_dynamicStackFunctions="0.0.2"	# version of lmsscr_Name library

declare -A dynStackTable		# stack name => stack uid
declare -i dynStackLength=6		# Number of characters in an unique id (uid)

declare -i dynStackError		# Error code (0 = none)
declare dynStackErrorFunction	# Function name recording the error
declare dynStackErrorMessage	# Printable error code string

# ***********************************************************************************************************
#
#	dynStackNew
#
#		Create a new stack
#
#	Parameters:
#		name = new stack name
#
#	Returns:
#		(integer) result = 0 => no error
#						 = -1 => error
#
# ***********************************************************************************************************
function dynStackNew()
{
	local uid
	local name="${1}"

	_dynStackResetError

	if [[ -z "$name"  ]]
	then
		_dynStackError "dynStackNew" "Missing required parameter"
		return 1
	fi

	dynStackSet $name uid
	if [ $? -ne 0 ]
	then
		return 1
	fi

	dynArrayNew stack_$uid
	if [ $? -ne 0 ]
	then
		_dynStackError "dynStackNew" "$(dynArrayGetError)"
		return 1
	fi

    return 0
}

# ***********************************************************************************************************
#
#	dynStackGet
#
#		get the stack name
#
#	parameters:
#		stack   = the stack name to search for
#
#	outputs:
#		varName = place to store the result
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function dynStackGet()
{
	local stack="${1}"
	local var=$2

	_dynStackResetError

	if [ -z "${dynStackTable[$stack]}" ]
	then
		_dynStackError "dynStackGet" "Stack '${stack}' was NOT found"
		return 1
	fi

	eval $var="'${dynStackTable[$stack]}'"
	return 0
}

# ***********************************************************************************************************
#
#	dynStackSet
#
#		set the stack name
#
#	attributes:
#		name = the stack name to set
#		var = the generated stack uid
#		length = (optional) the number of characters to return in the stack uid
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *********************************************************************************
function dynStackSet()
{
	local var=$2
	local name="${1}"
	local luid

	local -i length

	_dynStackResetError

	[ -n "$3" ] && length=${3} || length=$dynStackLength

	luid=$(dynStackGet $name)
	if [ $? -eq 0 ]
	then
		_dynStackError "dynStackSet" "Stack '${name}' already exists, uid = '${luid}'"
		return 2
	fi

	lmsUIdUnique luid $length
	if [ $? -ne 0 ]
	then
		_dynStackError "dynStackSet" "Unable to generate a new uid"
		return 1
	fi

	dynStackTable["${name}"]="$luid"

	eval $var="$luid"
	return 0
}


# ***********************************************************************************************************
#
#	dynStackPush
#
# 		Push one or more items onto a stack.
#
#	parameters:
#		stackName = the name of the stack to use
#		value = item to push
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function dynStackPush()
{
 	_dynStackResetError

 	if [[ -z "$1" || -z "$2" ]]
	then
		_dynStackError "dynStackPush" "Missing required parameters"
		return 1
	fi

	local name=$1
	local value="${2}"

    dynStackGet "$name" uid
    if [ $? -eq 1 ]
    then
        return 1
    fi

	dynArrayInsert stack_$uid $value
	[[ $? -ne 0 ]] &&
	 {
        _dynStackError "dynStackPush" "$(dynArrayGetError)"
        return 1
	 }

    return 0
}


# ***********************************************************************************************************
#
#	dynStackPop
#
# 		Pop the top element from the stack.
#
#	parameters:
#		stackName = the name of the stack to use
#
#	outputs:
#		(mixed) value = the value removed from the top of the stack
#
#	returns:
#		0 = successful
#		1 = error (no stack) or invalid parameters
#		2 = empty stack
#
# ***********************************************************************************************************
function dynStackPop()
{
	_dynStackResetError

	if [[ -z "$1" || -z "$2" ]]
	then
		_dynStackError "dynStackPop" "Missing required parameters"
		return 1
	fi

	value=$2
	name="${1}"

	local uid=""
	local stackValue=""
	local -i count

	dynStackGet $name uid
	if [ $? -ne 0 ]
    then
        return 1
    fi

	count=$(dynArrayCount stack_$uid)
	if [ $? -ne 0 ]
	then
        _dynStackError "dynStackPop"  "$(dynArrayGetError)"
        return 2
	fi

	if [ $count -lt 1 ]
	then
        _dynStackError "dynStackPop"  "Empty stack '${name}'"
		return 2
	fi

	let count-=1
	value=$(dynArrayGetAt stack_$uid $count)

	unset stack_$uid[$count]
	echo $value

    return 0
}


# ***********************************************************************************************************
#
#	dynStackDelete
#
# 		Delete a stack
#
#	parameter:
#		name = the name of the stack to delete
#
#	returns:
#		0 = successful
#		1 = error (no stack) or invalid parameters
#		2 = empty stack
#
# ***********************************************************************************************************
function dynStackDelete()
{
 	_dynStackResetError

 	if [[ -z "$1" ]]
	then
		_dynStackError "dynStackDelete" "Missing required parameter"
		return 1
	fi

	dynStackGet "$1" uid
	if [ $? -ne 0 ]
	then
		return 1
	fi

	dynArrayUnset stack_$uid
	unset dynStackTable[$name]

	return 0
}

# ***********************************************************************************************************
#
#	dynStackExists
#
#	parameters:
#		stackName = name of the stack to check for
#
#	return:
#		 0 = stack exists
#		 non-zero = stack does not exist
#
# ***********************************************************************************************************
function dynStackExists()
{
	local uid

	dynStackGet "$1" uid
	return $?
}

# ***********************************************************************************************************
#
#	dynStackSize
#
# 		Get the size of a stack
#
#	parameters:
#		stackName = the name of the stack to use
#
#	returns:
#		(integer) size = name of the variable to store size in
#					   = -1 if no stack name
#					   = -2 if unknown stack
#
# ***********************************************************************************************************
function dynStackSize()
{
	_dynStackResetError

	if [[ -z "$1" ]]
	then
		_dynStackError "dynStackSize" "Missing required parameter"
		return -1
	fi

	dynStackGet "$1" uid
	if [ $? -ne 0 ]
    then
        return -2
    fi

	echo $(dynArrayCount stack_$uid)
}

# ***********************************************************************************************************
#
#	dynStackPeek
#
# 		Return the requested element, relative to the top of the stack
#
#	parameters:
#		name = the name of the stack to use
#		value = the place to put the indexed value
#		index = offset into the stack (from the top)
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#		2 = invalid index or stack empty
#
# ***********************************************************************************************************
function dynStackPeek()
{
	_dynStackResetError

	if [[ -z "$1" || -z "$2" ]]
	then
		_dynStackError "dynStackPeek" "Missing required parameters"
		return 1
	fi

	local name="${1}"
	local value=$2
	local index=$3
	local -i sizeStack

	dynStackGet "$name" uid
	if [ $? -ne 0 ]
    then
        return 1
    fi

	let sizeStack=dynArrayCount stack_$uid
	let sizeStack-=1

	if ((  $sizeStack < 0  ||  $index >= $sizeStack  ))
	then
		_dynStackError "dynStackPeek" "Index = '$index' is invalid"
		return 1
	fi

	value=$(dynArrayGetAt stack_$uid $index)

	return 0
}

# ***********************************************************************************************************
#
#	dynStackToString
#
# 		Create a buffer containing stack data in printable form
#
#	parameters:
#		stackBuffer = the buffer to store the string in
#		stackName = the name of the stack to use
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function dynStackToString()
{
	_dynStackResetError

	if [[ -z "$1" || -z "$2" ]]
	then
		_dynStackError "dynStackToString" "Missing required parameters"
		return 1
	fi

	local stackName="${1}"
	local retBuffer=$2

	local buffer=""
	local line=""

	dynStackGet $stackName uid
	if [ $? -ne 0 ]
	then
		return 1
	fi

	printf -v buffer "%s:\n" "$stackName"
	for item in $(dynArrayGet stack_$uid)
	{
		printf -v line "    %s\n" "$item"
		buffer="$buffer$line"
	}

	eval $retBuffer="'${buffer}'"
	return 0
}

# ***********************************************************************************************************
#
#	_dynStackError
#
#		Set the stack error function and message
#
#	Parameters:
#		function = stack error function generating the error message
#		message = stack error message
#
# ***********************************************************************************************************
_dynStackError()
{
	dynStackError=1
	dynStackErrorFunction="$1"
	dynStackErrorMessage="$2"
}

# ***********************************************************************************************************
#
#	_dynStackResetError
#
#		Reset the stack error function and message
#
# ***********************************************************************************************************
_dynStackResetError()
{
	dynStackError=0
	dynStackErrorFunction=""
	dynStackErrorMessage=""
}

# ***********************************************************************************************************
#
#	dynStackGetError
#
#		Get the stack error function and message as a printable string
#
#	Returns:
#		function = stack error function generating the error message
#		message = stack error message
#
# ***********************************************************************************************************
function dynStackGetError()
{
	echo "${dynStackErrorFunction}: ${dynStackErrorMessage}"
}

# ***********************************************************************************************************
# ***********************************************************************************************************


# ***********************************************************************************************************
# ***********************************************************************************************************

