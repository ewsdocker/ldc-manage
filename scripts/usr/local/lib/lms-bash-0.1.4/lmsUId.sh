# ***********************************************************************************************************
# ***********************************************************************************************************
#
#   	lmsUId
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

declare -r lmslib_lmsUId="0.0.2"	# version of library

# ***********************************************************************************************************
#
#	dependencies
#
#		the following external functions are required
#
#			errorQueueFunctions
#
# *********************************************************************************

declare -A lmsuid_Unique=()
declare -i lmsuid_MaxLoops=256
declare -i lmsuid_Length=8

# ***********************************************************************************************************
#
#	lmsUIdGenerate
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
function lmsUIdGenerate()
{
	local -i genLen
	local	 genName=${1}

	[[ -n "${2}" ]] && genLen=${2} || genLen=$lmsuid_Length

	local genId=$(cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c $genLen)

	eval $genName="'$genId'"
	return 0
}

# ***********************************************************************************************************
#
#	lmsUIdExists
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
function lmsUIdExists()
{
	local uid="${1}"

	[[ " ${lmsuid_Unique[@]} " =~ "${uid}" ]]  &&  return 0
	return 1
}

# ***********************************************************************************************************
#
#	lmsUIdUnique
#
#		generate an unique identifier of specified length
#
#	parameters:
#		varName = variable to store the result in
#		length = (optional) maximum characters in the result, default = lmsuid_Length
#		maxLoops = (optional) maximum loops to find a unique id, default = lmsuid_MaxLoops
#
#	returns:
#		0 = error (maxLoops exceeded)
#		string = unique id
#
# ***********************************************************************************************************
function lmsUIdUnique()
{
	local varName=$1
	local length

	[[ -n "$2" ]] && length=${2} || length=$lmsuid_Length

	local gid=""
	local -i loopCount=0

	local -i maxLoops
	[[ -z "${3}" ]] && maxLoops=${3} || maxLoops=$lmsuid_MaxLoops


	lmsUIdGenerate gid $length

	while true
	do
		lmsUIdExists $gid
		[[ $? -eq 1 ]] && break

		(( loopCount++ ))

		[[ $loopCount > ${maxLoops} ]] && return 1
		lmsUIdGenerate gid $length
	done

	lmsuid_Unique[${#lmsuid_Unique[@]}]="${gid}"

	eval $varName="'$gid'"

	return 0
}

# ***********************************************************************************************************
#
#	lmsUIdRegister
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
function lmsUIdRegister()
{
	local uid

	[[ -z "${1}" ]] && return 1

	uid="${1}"

	lmsUIdExists $uid
	[[ $? -eq 0 ]] &&
	 {
		lmsConioDebug $LINENO "lmsUIdExists" "${uid} already exists"
		return 1
	 }

	lmsuid_Unique[${#lmsuid_Unique[@]}]="${uid}"
	return 0
}

# ***********************************************************************************************************
#
#	lmsUIdGetIndex
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
function lmsUIdGetIndex()
{
	local searchResult=$1
	local id="${2}"

	local -i searchIndex=0

	[[ -z "${id}" ]] && return 1

	for element in "${lmsuid_Unique[@]}"
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
#	lmsUIdDelete
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
function lmsUIdDelete()
{
	local id="${1}"
	local index

	[[ -z "${id}" ]] || return 1

	lmsUIdGetIndex index "$id"
	[[ $? -eq 0 ]] || return 1

	unset lmsuid_Unique["${index}"]
	return 0
}

