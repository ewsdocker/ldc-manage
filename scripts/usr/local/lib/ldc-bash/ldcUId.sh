# ***********************************************************************************************************
# ***********************************************************************************************************
#
#   	ldcUId
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage uniqueIdFunctions
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
#			Version 0.0.1 - 03-05-2016.
#					0.0.2 - 02-09-2017.
#
# ***********************************************************************************************************
# ***********************************************************************************************************

declare -r ldclib_ldcUId="0.0.2"	# version of library

# ***********************************************************************************************************
#
#	dependencies
#
#		the following external functions are required
#
#			errorQueueFunctions
#
# *********************************************************************************

declare -A ldcuid_Unique=()
declare -i ldcuid_MaxLoops=256
declare -i ldcuid_Length=8

# ***********************************************************************************************************
#
#	ldcUIdGenerate
#
#		generate an unique identifier of specified length
#
#	parameters:
#		varName = place to store the result
#		idLength = length (characters) of id
#
#	returns:
#		id = character string of length characters
#
#   *****************************************************************************************************
#
# 		based upon an algorithm from https://coderwall.com/p/4zux3a
#
# ***********************************************************************************************************
function ldcUIdGenerate()
{
	local -i genLen
	local	 genName=${1}

	[[ -n "${2}" ]] && genLen=${2} || genLen=$ldcuid_Length

	local genId=$(cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c $genLen)

	eval $genName="'$genId'"
	return 0
}

# ***********************************************************************************************************
#
#	ldcUIdExists
#
#		check if the identifier is in the table of unique values
#
#	parameters:
#		id = id string to check
#
#	return:
#		0 = found
#		non-zero = not found
#
# ***********************************************************************************************************
function ldcUIdExists()
{
	local uid="${1}"

	[[ " ${ldcuid_Unique[@]} " =~ "${uid}" ]]  &&  return 0
	return 1
}

# ***********************************************************************************************************
#
#	ldcUIdUnique
#
#		generate an unique identifier of specified length
#
#	parameters:
#		varName = variable to store the result in
#		length = (optional) maximum characters in the result, default = ldcuid_Length
#		maxLoops = (optional) maximum loops to find a unique id, default = ldcuid_MaxLoops
#
#	returns:
#		0 = error (maxLoops exceeded)
#		string = unique id
#
# ***********************************************************************************************************
function ldcUIdUnique()
{
	local varName=$1
	local length

	[[ -n "$2" ]] && length=${2} || length=$ldcuid_Length

	local gid=""
	local -i loopCount=0

	local -i maxLoops
	[[ -z "${3}" ]] && maxLoops=${3} || maxLoops=$ldcuid_MaxLoops


	ldcUIdGenerate gid $length

	while true
	do
		ldcUIdExists $gid
		[[ $? -eq 1 ]] && break

		(( loopCount++ ))

		[[ $loopCount > ${maxLoops} ]] && return 1
		ldcUIdGenerate gid $length
	done

	ldcuid_Unique[${#ldcuid_Unique[@]}]="${gid}"

	eval $varName="'$gid'"

	return 0
}

# ***********************************************************************************************************
#
#	ldcUIdRegister
#
#		register an unique identifier
#
#	parameters:
#		uniqueId = unique identifier to register
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ***********************************************************************************************************
function ldcUIdRegister()
{
	local uid

	[[ -z "${1}" ]] && return 1

	uid="${1}"

	ldcUIdExists $uid
	[[ $? -eq 0 ]] &&
	 {
		ldcConioDebug $LINENO "ldcUIdExists" "${uid} already exists"
		return 1
	 }

	ldcuid_Unique[${#ldcuid_Unique[@]}]="${uid}"
	return 0
}

# ***********************************************************************************************************
#
#	ldcUIdGetIndex
#
#		get the index of an unique identifier
#
#	parameters:
#		serachResult = result reference
#		uniqueId = unique identifier to lookup
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ***********************************************************************************************************
function ldcUIdGetIndex()
{
	local searchResult=$1
	local id="${2}"

	local -i searchIndex=0

	[[ -z "${id}" ]] && return 1

	for element in "${ldcuid_Unique[@]}"
	do
		[[ "${element}" == "${id}" ]] &&
		 {
			eval $searchResult="'$searchIndex'"
			return 0
		 }

		(( searchIndex++ ))
	done

	return 1
}

# ***********************************************************************************************************
#
#	ldcUIdDelete
#
#		delete an unique identifier
#
#	parameters:
#		(integer) index = index of UID to delete
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ***********************************************************************************************************
function ldcUIdDelete()
{
	local id="${1}"
	local index

	[[ -z "${id}" ]] || return 1

	ldcUIdGetIndex index "$id"
	[[ $? -eq 0 ]] || return 1

	unset ldcuid_Unique["${index}"]
	return 0
}

