# ***********************************************************************************************************
# ***********************************************************************************************************
#
#   ldcStack.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.1
# @copyright © 2016-2021. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package ewsdocker/ldcFramework
# @subpackage library/ldcStack
#
# =========================================================================================
#
#	Copyright © 2016-2021. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/ldcFramework.
#
#   ewsdocker/ldcFramework is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/ldcFramework is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/ldcFramework.  If not, see 
#   <http://www.gnu.org/licenses/>.
#
# =========================================================================================
#
#			Version 0.0.1 - 03-11-2016.
#					0.0.2 - 03-24-2016.
#					0.0.3 - 07-19-2016.
#					0.0.4 - 07-25-2016.
#					0.0.5 - 08-04-2016.
#					0.1.0 - 01-14-2017.
#					0.1.1 - 01-24-2017.
#					0.1.2 - 02-08-2017.
#                   0.2.0 - 10-14-2020.
#                   0.2.1 - 01-14-2021.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r ldclib_ldcStackFunctions="0.2.1"	# version of library

# ***********************************************************************************************************

declare -A ldcstk_table				# stack name => stack uid
declare	   ldcstk_name=""			# current stack name, if ldcstk_uid not empty

declare -i ldcstk_uidLength=6		# Number of characters in an unique id (uid)
declare	   ldcstk_uid=""			# current stack uid or empty if not assigned

declare	   ldcstk_stackName			# current ldcstku stack name (ldcstk_name + ldcstk_uid)
declare -i ldcstk_head				# current stack head
declare -i ldcstk_tail				# current stack tail

# ***********************************************************************************************************
#
#	ldcStackCreate
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
function ldcStackCreate()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local cName="${1}"
	local -i cLength=${3:-"$ldcstk_uidLength"}

	local cUid=""

	_ldcStackSet "$cName" ${cLength} cUid
	[[ $? -eq 0 ]] || return 2

	eval "declare -ag ldcstku_${cUid}"
	eval "declare -ig ldcstku_${cUid}_head"	# head of stack, start of queue
	eval "declare -ig ldcstku_${cUid}_tail"	# end of queue, not used for stack

	eval "ldcstku_${cUid}_head=0"
	eval "ldcstku_${cUid}_tail=0"

	ldcstk_name="$cName"
	ldcstk_uid="${cUid}"

	ldcstk_head=0
	ldcstk_tail=0

	ldcDeclareStr ${2} "${cUid}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	_ldcStackSet
#
#		set the stack name
#
#	DO NOT CALL DIRECTLY, CALL ldcStackCreate instead
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
function _ldcStackSet()
{
	local sName="${1}"
	local -i sLength=${2}
	local sUid

	[[ ${sLength} -eq 0 ]] && sLength=${ldcstk_uidLength}

	while [[ true ]]
	do
		ldcStackLookup "${sName}" sUid
		[[ $? -eq 0 ]] && break

		ldcUIdUnique sUid $sLength
		[[ $? -eq 0 ]] || return 1

		ldcstk_table["${sName}"]="${sUid}"
		break
	done

	ldcDeclareStr ${3} "${sUid}"
	[[ $? -eq 0 ]] || return 1

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackDestroy
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
ldcStackDestroy()
{
 	[[ -z "${1}" ]] && return 1

	local sName="${1}"
	local sUid=""

	ldcStackLookup "${sName}" sUid
	[[ $? -eq 0 ]] || return 2

	eval "unset ldcstku_${sUid} ldcstku_${sUid}_head ldcstku_${sUid}_tail"
	unset ldcstk_table["${sName}"]

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
#	ldcStackWrite
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
function ldcStackWrite()
{
	[[ -z "${1}" ]] && return 1

	local writeName=${1}
	
	local empty=""
	local writeValue="${2:-$empty}"

	ldcStackLookup "${writeName}" wUid
	[[ $? -eq 0 ]] || return 2

	eval "ldcstku_$ldcstk_uid[${ldcstk_head}]='${writeValue}'"
	eval "let ldcstku_${ldcstk_uid}_head+=1"

	(( ldcstk_head++ ))

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackRead
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
function ldcStackRead()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local stackName="${1}"
	local -i readSize

	ldcStackSize "${stackName}" readSize
	[[ $? -eq 0 ]] || 
	{
		[[ $? -eq 1 ]] && return 2 || return 3
	}

	[[ $readSize -lt 1 ]] && return 4

	(( ldcstk_head-- ))

	local valueRead=""
	eval 'valueRead=$'"{ldcstku_$ldcstk_uid[$ldcstk_head]}"

	eval "(( ldcstku_${ldcstk_uid}_head-- ))"

	ldcDeclareStr ${2} "${valueRead}"
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackReadQueue
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
function ldcStackReadQueue()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local qName="${1}"
	local qValue=""

	ldcStackPeekQueue "${qName}" qValue 0
	[[ $? -eq 0 ]] || return 2

	eval "(( ldcstku_${ldcstk_uid}_tail++ ))"
	(( ldcstk_tail++ ))

	ldcDeclareStr ${2} "${qValue}"

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackPeek
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
function ldcStackPeek()
{
	[[ -z "$1" || -z "$2" ]] && return 1

	local sName="${1}"
#	local sValue="$2"
	local sOffset=${3:-0}
	local sPointer

	ldcStackPointer ${sName} ${sOffset} sPointer
	[[ $? -eq 0 ]] || return 2

	local value
	eval 'value=$'"{ldcstku_$ldcstk_uid[$sPointer]}"

	ldcDeclareStr ${2} ${value}
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackPeekQueue
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
function ldcStackPeekQueue()
{
	[[ -z "$1" || -z "$2" ]] && return 1

	local qName="${1}"
#	local qResult="$2"
	local qOffset=${3:-0}
	local qPointer=0

	ldcStackPointerQueue ${qName} ${qOffset} qPointer
	[[ $? -eq 0 ]] || return 2

	local result
	eval 'result=$'"{ldcstku_$ldcstk_uid[$qPointer]}"

	ldcDeclareStr ${2} "${result}"
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
#	ldcStackExists
#
#	parameters:
#		stackName = name of the stack to check for
#
#	return:
#		 0 = stack exists
#		 non-zero = stack does not exist
#
# ***********************************************************************************************************
function ldcStackExists()
{
	local xUid

	ldcStackLookup "${1}" xUid
	return $?
}

# ***********************************************************************************************************
#
#	ldcStackLookup
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
function ldcStackLookup()
{
	local lookupStack="${1}"

	[[ ! "${!ldcstk_table[@]}" =~ "${lookupStack}" ]] && return 1

	ldcstk_name=$lookupStack
	ldcstk_uid="${ldcstk_table[$ldcstk_name]}"

	ldcstk_stackName="ldcstku_${ldcstk_uid}"

	eval "let ldcstk_head=ldcstku_${ldcstk_uid}_head"
	eval "let ldcstk_tail=ldcstku_${ldcstk_uid}_tail"

	ldcDeclareStr ${2} "$ldcstk_uid"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackSize
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
function ldcStackSize()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local stackName="${1}"
	local -i size=0
	local luid

	ldcStackLookup "$stackName" luid
	[[ $? -eq 0 ]] || return 2

	let size=${ldcstk_head}-${ldcstk_tail}

	[[ $size -lt 1 ]] &&
	 {
		size=0
		ldcStackReset ${stackName} ${luid}
	 }

	ldcDeclareStr ${2} "${size}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackPointer
#
# 		Compute the stack head + offset
#
#	parameters:
#		name = the name of the stack to use
#		offset = offset into the stack (from the top) (default = 0)
#		pointer = location to store the value of the ldcStackPointer
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function ldcStackPointer()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local sName="${1}"
	local sOffset=${2}

	local pointer=0
	local sSize=0

	ldcStackSize "${sName}" sSize
	[[ $? -eq 0 ]] || return 2

	[[ ${sSize} -lt 1  ||  ${sOffset} -ge ${sSize} ]]  &&  return 3

	let pointer=${ldcstk_head}-${sOffset}-1

	[[ ${pointer} -lt 0 ]] && return 4

	ldcDeclareStr ${3} "${pointer}"
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackPointerQueue
#
# 		Compute the stack tail + offset (a.k.a. queue head + offset)
#
#	parameters:
#		qName = the name of the stack to use
#		qOffset = offset into the queue (from the top, or the tail of the queue) (default = 0)
#		qPointer = location to store the value of the ldcStackPointerQueue
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function ldcStackPointerQueue()
{
	[[ -z "${1}" || -z "${2}" || -z "${3}" ]] && return 1

	local qName="${1}"
	local qOffset=${2}

	local qHead=0
	local qSize=0

	ldcStackSize "${qName}" qSize
	[[ $? -eq 0 ]] || return 2

	[[ ${qSize} -lt 1  ||  ${qOffset} -ge ${qSize} ]]  &&  return 3

	let qHead=${ldcstk_tail}+${qOffset}

	[[ ${qHead} -ge ${ldcstk_head} ]] && return 4

	ldcDeclareStr ${3} ${qHead}
	[[ $? -eq 0 ]] || return 5

	return 0
}

# ***********************************************************************************************************
#
#	ldcStackReset
#
# 		Empty the stack and reset pointers
#
#	parameters:
#		stsName = the name of the stack to reset
#
#	returns:
#		0 = successful
#		1 = error (no stack)
#
# ***********************************************************************************************************
function ldcStackReset()
{
	local lname=${1}
	local luid="${2}"

	[[ -z "${luid}" ]] &&
	 {
		ldcStackLookup "$lname" luid
		[[ $? -eq 0 ]] || return 1
	 }

	eval "let ldcstku_${luid}_head=0"
	eval "let ldcstku_${luid}_tail=0"

	let ldcstk_head=0
	let ldcstk_tail=0

	eval "unset ldcstku_${luid}"
	eval "declare -ag ldcstku_${luid}"
	
	return 0
}

# ***********************************************************************************************************
#
#	ldcStackToString
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
function ldcStackToString
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local	sName="${1}"
	local	sFormat=${3:-"1"}

	local	sLine=""
	local	sBuffer=""
	local -i sSize=0
	local	sElement=""
	local -i sPointer=0
	local -i sIndex=0


	ldcStackSize "$sName" sSize
	[[ $? -eq 0 ]] ||
	 {
		[[ $? -eq 3 ]] && return 3 || return 3
	 }

	[[ $sSize -lt 1 ]] && return 0

	[[ $sFormat -eq 1 ]] && sBuffer="${sName} = $sSize elements"

	sPointer=${ldcstk_head}-1

	while [[ $sPointer -ge $ldcstk_tail ]]
	do
		eval 'sElement=$'"{ldcstku_$ldcstk_uid[$sPointer]}"

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

	ldcDeclareStr ${2} "${sBuffer}"
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ***********************************************************************************************************
# ***********************************************************************************************************
