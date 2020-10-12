# ***********************************************************************************************************
# ***********************************************************************************************************
#
#   lmsStack.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsDomToStr
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 03-11-2016.
#					0.0.2 - 03-24-2016.
#					0.0.3 - 07-19-2016.
#					0.0.4 - 07-25-2016.
#					0.0.5 - 08-04-2016.
#					0.1.0 - 01-14-2017.
#					0.1.1 - 01-24-2017.
#					0.1.2 - 02-08-2017.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r lmslib_lmsStackFunctions="0.1.2"	# version of library

# ***********************************************************************************************************

declare -A lmsstk_table				# stack name => stack uid
declare	lmsstk_name=""				# current stack name, if lmsstk_uid not empty

declare -i lmsstk_uidLength=6		# Number of characters in an unique id (uid)
declare	lmsstk_uid=""				# current stack uid or empty if not assigned

declare	lmsstk_stackName			# current lmsstku stack name (lmsstk_name + lmsstk_uid)
declare -i lmsstk_head				# current stack head
declare -i lmsstk_tail				# current stack tail

# ***********************************************************************************************************
#
#	lmsStackCreate
#
#		Create a new stack
#
#	Parameters:
#		name = new stack name
#		uid = location to return uid to
#		uidLength = (optional) unique id character length
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ***********************************************************************************************************
function lmsStackCreate()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local cName="${1}"
	local -i cLength=${3:-"$lmsstk_uidLength"}

	local cUid=""

	_lmsStackSet "$cName" ${cLength} cUid
	[[ $? -eq 0 ]] || return 2

	eval "declare -ag lmsstku_${cUid}"
	eval "declare -ig lmsstku_${cUid}_head"	# head of stack, start of queue
	eval "declare -ig lmsstku_${cUid}_tail"	# end of queue, not used for stack

	eval "lmsstku_${cUid}_head=0"
	eval "lmsstku_${cUid}_tail=0"

	lmsstk_name="$cName"
	lmsstk_uid="${cUid}"

	lmsstk_head=0
	lmsstk_tail=0

	lmsDeclareStr ${2} "${cUid}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	_lmsStackSet
#
#		set the stack name
#
#	DO NOT CALL DIRECTLY, CALL lmsStackCreate instead
#
#	attributes:
#		name = the stack name to set
#		length = (optional) the number of characters to return in the stack uid
#		var = the generated stack uid
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *********************************************************************************
function _lmsStackSet()
{
	local sName="${1}"
	local -i sLength=${2}
	local sUid

	[[ ${sLength} -eq 0 ]] && sLength=${lmsstk_uidLength}

	while [[ true ]]
	do
		lmsStackLookup "${sName}" sUid
		[[ $? -eq 0 ]] && break

		lmsUIdUnique sUid $sLength
		[[ $? -eq 0 ]] || return 1

		lmsstk_table["${sName}"]="${sUid}"
		break
	done

	lmsDeclareStr ${3} "${sUid}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackDestroy
# 		Delete a stack
#
#	parameter:
#		name = the name of the stack to delete
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ***********************************************************************************************************
lmsStackDestroy()
{
 	[[ -z "${1}" ]] && return 1

	local sName="${1}"
	local sUid=""

	lmsStackLookup "${sName}" sUid
	[[ $? -eq 0 ]] || return 2

	eval "unset lmsstku_${sUid} lmsstku_${sUid}_head lmsstku_${sUid}_tail"
	unset lmsstk_table["${sName}"]

	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#					Stack operations
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	lmsStackWrite
#
# 		Write (Push) an item onto the head of the stack.
#
#	parameters:
#		stackName = the name of the stack to use
#		value = item to write
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackWrite()
{
	[[ -z "${1}" ]] && return 1

	local writeName=${1}
	
	local empty=""
	local writeValue="${2:-$empty}"

	lmsStackLookup "${writeName}" wUid
	[[ $? -eq 0 ]] || return 2

	eval "lmsstku_$lmsstk_uid[${lmsstk_head}]='${writeValue}'"
	eval "let lmsstku_${lmsstk_uid}_head+=1"

	(( lmsstk_head++ ))

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackRead
#
# 		Read ( Pop ) the top element from the stack.
#
#	parameters:
#		stackName = the name of the stack to use
#		value = the value removed from the top of the stack
#
#	returns:
#		0 = successful
#		1 = error (no stack) 
#		2 = empty stack
#
# ***********************************************************************************************************
function lmsStackRead()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local stackName="${1}"
	local -i readSize

	lmsStackSize "${stackName}" readSize
	[[ $? -eq 0 ]] || 
	{
		[[ $? -eq 1 ]] && return 2 || return 3
	}

	[[ $readSize -lt 1 ]] && return 4

	(( lmsstk_head-- ))

	local valueRead=""
	eval 'valueRead=$'"{lmsstku_$lmsstk_uid[$lmsstk_head]}"

	eval "(( lmsstku_${lmsstk_uid}_head-- ))"

	lmsDeclareStr ${2} "${valueRead}"
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackReadQueue
#
# 		Read (Pop) the stack queue.
#
#	parameters:
#		queueName = the name of the queue (stack)
#		value = location to place the read value
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#		2 = empty stack
#
# ***********************************************************************************************************
function lmsStackReadQueue()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local qName="${1}"
	local qValue=""

	lmsStackPeekQueue "${qName}" qValue 0
	[[ $? -eq 0 ]] || return 2

	eval "(( lmsstku_${lmsstk_uid}_tail++ ))"
	(( lmsstk_tail++ ))

	lmsDeclareStr ${2} "${qValue}"

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackPeek
#
# 		Return the requested element, relative to the top of the stack
#
#	parameters:
#		name = the name of the stack to use
#		result = the place to put the indexed value
#		offset = (optional) offset into the stack (from the top) (default = 0)
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackPeek()
{
	[[ -z "$1" || -z "$2" ]] && return 1

	local sName="${1}"
#	local sValue="$2"
	local sOffset=${3:-0}
	local sPointer

	lmsStackPointer ${sName} ${sOffset} sPointer
	[[ $? -eq 0 ]] || return 2

	local value
	eval 'value=$'"{lmsstku_$lmsstk_uid[$sPointer]}"

	lmsDeclareStr ${2} ${value}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackPeekQueue
#
# 		Return the requested element, relative to the top of the stack
#
#	parameters:
#		qName = the name of the stack to use
#		qResult = the place to put the indexed value
#		qOffset = (optional) offset into the queue (from the top, or the tail of the queue) (default = 0)
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackPeekQueue()
{
	[[ -z "$1" || -z "$2" ]] && return 1

	local qName="${1}"
#	local qResult="$2"
	local qOffset=${3:-0}
	local qPointer=0

	lmsStackPointerQueue ${qName} ${qOffset} qPointer
	[[ $? -eq 0 ]] || return 2

	local result
	eval 'result=$'"{lmsstku_$lmsstk_uid[$qPointer]}"

	lmsDeclareStr ${2} "${result}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
#
#					Stack properties
#
# ***********************************************************************************************************
# ***********************************************************************************************************

# ***********************************************************************************************************
#
#	lmsStackExists
#
#	parameters:
#		stackName = name of the stack to check for
#
#	return:
#		 0 = stack exists
#		 non-zero = stack does not exist
#
# ***********************************************************************************************************
function lmsStackExists()
{
	local xUid

	lmsStackLookup "${1}" xUid
	return $?
}

# ***********************************************************************************************************
#
#	lmsStackLookup
#
#		get the stack uid of the provided stack name
#
#	parameters:
#		stack   = the stack name to search for
#		uid 	= place to store the result
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsStackLookup()
{
	local lookupStack="${1}"

	[[ ! "${!lmsstk_table[@]}" =~ "${lookupStack}" ]] && return 1

	lmsstk_name=$lookupStack
	lmsstk_uid="${lmsstk_table[$lmsstk_name]}"

	lmsstk_stackName="lmsstku_${lmsstk_uid}"

	eval "let lmsstk_head=lmsstku_${lmsstk_uid}_head"
	eval "let lmsstk_tail=lmsstku_${lmsstk_uid}_tail"

	lmsDeclareStr ${2} "$lmsstk_uid"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackSize
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
# ***********************************************************************************************************
function lmsStackSize()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local stackName="${1}"
	local -i size=0
	local luid

	lmsStackLookup "$stackName" luid
	[[ $? -eq 0 ]] || return 2

	let size=${lmsstk_head}-${lmsstk_tail}

	[[ $size -lt 1 ]] &&
	 {
		size=0
		lmsStackReset ${stackName} ${luid}
	 }

	lmsDeclareStr ${2} "${size}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackPointer
#
# 		Compute the stack head + offset
#
#	parameters:
#		name = the name of the stack to use
#		offset = offset into the stack (from the top) (default = 0)
#		pointer = location to store the value of the lmsStackPointer
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackPointer()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local sName="${1}"
	local sOffset=${2}

	local pointer=0
	local sSize=0

	lmsStackSize "${sName}" sSize
	[[ $? -eq 0 ]] || return 2

	[[ ${sSize} -lt 1  ||  ${sOffset} -ge ${sSize} ]]  &&  return 3

	let pointer=${lmsstk_head}-${sOffset}-1

	[[ ${pointer} -lt 0 ]] && return 4

	lmsDeclareStr ${3} "${pointer}"
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackPointerQueue
#
# 		Compute the stack tail + offset (a.k.a. queue head + offset)
#
#	parameters:
#		qName = the name of the stack to use
#		qOffset = offset into the queue (from the top, or the tail of the queue) (default = 0)
#		qPointer = location to store the value of the lmsStackPointerQueue
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackPointerQueue()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local qName="${1}"
	local qOffset=${2}

	local qHead=0
	local qSize=0

	lmsStackSize "${qName}" qSize
	[[ $? -eq 0 ]] || return 2

	[[ ${qSize} -lt 1  ||  ${qOffset} -ge ${qSize} ]]  &&  return 3

	let qHead=${lmsstk_tail}+${qOffset}

	[[ ${qHead} -ge ${lmsstk_head} ]] && return 4

	lmsDeclareStr ${3} ${qHead}
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***********************************************************************************************************
#
#	lmsStackReset
#
# 		Empty the stack and reeet pointers
#
#	parameters:
#		stsName = the name of the stack to reset
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackReset()
{
	local lname=${1}
	local luid="${2}"

	[[ -z "${luid}" ]] &&
	 {
		lmsStackLookup "$lname" luid
		[[ $? -eq 0 ]] || return 1
	 }

	eval "let lmsstku_${luid}_head=0"
	eval "let lmsstku_${luid}_tail=0"

	let lmsstk_head=0
	let lmsstk_tail=0

	eval "unset lmsstku_${luid}"
	eval "declare -ag lmsstku_${luid}"
	
	return 0
}

# ***********************************************************************************************************
#
#	lmsStackToString
#
# 		Create a buffer containing stack data in printable form
#
#	parameters:
#		stsName = the name of the stack to use
#		stsRetBuffer = the buffer to store the string in
#		stsFormat = 0 ==> unformatted output, 1 ==> formatted for printing
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function lmsStackToString
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local	sName="${1}"
	local	sFormat=${3:-1}

	local	sLine=""
	local	sBuffer=""
	local -i sSize=0
	local	sElement=""
	local -i sPointer=0
	local -i sIndex=0


	lmsStackSize "$sName" sSize
	[[ $? -eq 0 ]] ||
	 {
		[[ $? -eq 3 ]] && return 3 || return 3
	 }

	[[ $sSize -lt 1 ]] && return 0

	[[ $sFormat -eq 1 ]] && sBuffer="${sName} = $sSize elements"

	sPointer=${lmsstk_head}-1

	while [[ $sPointer -ge $lmsstk_tail ]]
	do
		eval 'sElement=$'"{lmsstku_$lmsstk_uid[$sPointer]}"

		if [[ $sFormat -eq 1 ]]
		then
			printf -v sLine "\n    % 4u - %s" ${sIndex} "${sElement}"
		else
			printf -v sLine "\n    %04u:%s" ${sIndex} "${sElement}"
		fi

		sBuffer="${sBuffer}${sLine}"

		(( sPointer-- ))
		(( sIndex++ ))
	done

	lmsDeclareStr ${2} "${sBuffer}"
	[[ $? -eq 0 ]] || return 4

	return 0
}

