#!/bin/bash

# *******************************************************
# *******************************************************
#
#   stackExternal.bash
#
#	  by Brian Clapper
#
#	  http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/
#
# *******************************************************
# *******************************************************

declare -r lmslib_stackExternal="0.0.1"	# version of library

# *******************************************************
# *******************************************************
#
#    	External Scripts
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
# 	A stack, using bash arrays.
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#	stack_new
#
#		Create a new stack.
#
# Usage: stack_new name
#
# *******************************************************
#
# Example: stack_new x
#
# *******************************************************
function stack_new
{
#    : ${1?'Missing stack name'}
	if [[ -z "$1" ]]
	then
		lmsConioDebug "stack_new" "Missing required parameter"
		return 1
	fi

    if stack_exists $1
    then
        lmsConioDebug "stack_new" "Stack already exists -- $1"
        return 2
    fi

    eval "declare -ag _stack_$1"
    eval "declare -ig _stack_$1_i"
    eval "let _stack_$1_i=0"
    return 0
}

# *******************************************************
#
# 	Destroy a stack
#
# Usage: stack_destroy name
#
# *******************************************************
function stack_destroy
{
#    : ${1?'Missing stack name'}
 	if [[ -z "$1" ]]
	then
		lmsConioDebug "stack_destroy" "Missing required parameter"
		return 1
	fi

	eval "unset _stack_$1 _stack_$1_i"
    return 0
}

# *******************************************************
#
#	stack_push
#
# 		Push one or more items onto a stack.
#
#	parameters:
#		stackName = the name of the stack to use
#		value(s) = item(s) to push
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# Usage: stack_push stack item ...
#
# *******************************************************
function stack_push
{
#    : ${1?'Missing stack name'}
#    : ${2?'Missing item(s) to push'}

	if [[ -z "$1" || -z "$2" ]]
	then
		lmsConioDebug "stack_push" "Missing required parameters"
		return 1
	fi

    if no_such_stack $1
    then
        lmsConioDebug "stack_push" "No such stack -- $1"
        return 2
    fi

    stack=$1
    shift 1

    while (( $# > 0 ))
    do
        eval '_i=$'"_stack_${stack}_i"
        eval "_stack_${stack}[$_i]='$1'"
        eval "let _stack_${stack}_i+=1"
        shift 1
    done

    unset _i
    return 0
}

# *******************************************************
#
#	stack_print
#
# 		Print a stack to stdout.
#
#	parameters:
#		stackName = the name of the stack to use
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# Usage: stack_print name
#
# *******************************************************
function stack_print
{
#    : ${1?'Missing stack name'}

	if [[ -z "$1" ]]
	then
		lmsConioDebug "stack_print" "Missing required parameter"
		return 1
	fi

    if no_such_stack $1
    then
        lmsConioDebug "stack_print" "No such stack -- $1"
        return 2
    fi

    tmp=""
    eval 'let _i=$'_stack_$1_i
    while (( $_i > 0 ))
    do
        let _i=${_i}-1
        eval 'e=$'"{_stack_$1[$_i]}"
        tmp="$tmp $e"
    done
    echo "(" $tmp ")"
}

# *******************************************************
#
#	stack_size
#
# 		Get the size of a stack
#
#	parameters:
#		stackName = the name of the stack to use
#		size = name of the variable to store size in
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# Usage: stack_size name var
#
# *******************************************************
#
# Example:
#    stack_size mystack n
#    echo "Size is $n"
#
# *******************************************************
function stack_size
{
#    : ${1?'Missing stack name'}
#    : ${2?'Missing name of variable for stack size result'}

	if [[ -z "$1" || -z "$2" ]]
	then
		lmsConioDebug "stack_size" "Missing required parameters"
		return 1
	fi

    if no_such_stack $1
    then
        lmsConioDebug "stack_size" "No such stack -- $1"
        return 2
    fi
    eval "$2"='$'"{#_stack_$1[*]}"
}

# *******************************************************
#
#	stack_pop
#
# 		Pop the top element from the stack.
#
#	parameters:
#		stackName = the name of the stack to use
#		popped = name of the variable to store popped value in
#
#	returns:
#		0 = successful
#		1 = error (no stack) or empty stack
#
# Usage: stack_pop name var
#
# *******************************************************
#
# Example:
#    stack_pop mystack top
#    echo "Got $top"
#
# *******************************************************
function stack_pop
{
#    : ${1?'Missing stack name'}
#    : ${2?'Missing name of variable for popped result'}

	if [[ -z "$1" || -z "$2" ]]
	then
		lmsConioDebug "stack_pop" "Missing required parameter"
		return 1
	fi

    eval 'let _i=$'"_stack_$1_i"
    if no_such_stack $1
    then
        lmsConioDebug "stack_pop"  "No such stack -- $1"
        return 1
    fi

    if [[ "$_i" -eq 0 ]]
    then
        lmsConioDebug "stack_pop" "Empty stack -- $1"
        return 2
    fi

    let _i-=1
    eval "$2"='$'"{_stack_$1[$_i]}"
    eval "unset _stack_$1[$_i]"
    eval "_stack_$1_i=$_i"
    unset _i
    return 0
}

# *******************************************************
#
#	no_such_stack
#
#	parameters:
#		stackName = name of the stack to check
#
# *******************************************************
function no_such_stack
{
#    : ${1?'Missing stack name'}
	if [[ -z "$1" ]]
	then
		lmsConioDebug "no_such_stack" "Missing required parameter"
		return 1
	fi

    stack_exists $1
    ret=$?
    declare -i x
    let x="1-$ret"
    return $x
}

# *******************************************************
#
#	stack_exists
#
#	parameters:
#		stackName = name of the stack to check
#
#	return:
#		 0 if stack exists
#		 1 if stack does not exist
#
# *******************************************************
function stack_exists
{
#    : ${1?'Missing stack name'}

	if [[ -z "$1" ]]
	then
		lmsConioDebug "stack_exists" "Missing required parameter"
		return 1
	fi

    eval '_i=$'"_stack_$1_i"
    if [[ -z "$_i" ]]
    then
        return 1
    else
        return 0
    fi
}
