# *****************************************************************************
# *****************************************************************************
#
#   lmsUtilities.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.5
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package lmsUtilities
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/lms-bash.
#
#   ewsdocker/lms-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/lms-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/lms-bash.  If not, see 
#   <http://www.gnu.org/licenses/>.
#
# *****************************************************************************
#
#	version 0.0.1 - 08-24-2016.
#           0.0.2 - 08-26-2016.
#			0.0.3 - 12-18-2016.
#			0.0.4 - 02-08-2017.
#			0.0.5 - 08-26-2018.
#
# *****************************************************************************
# *****************************************************************************
declare -r lmslib_lmsUtilities="0.0.5"	# version of library

declare    lmsutl_osString
declare -a lmsutl_wmFields=( window winws winx winy winw winh winmachine wintitle )

# *****************************************************************************
#
#	lmsUtilCommandExists
#
#		check if the given external command has been installed
#
#	parameters:
#		cmnd = command to check for
#
#	outputs:
#		1 = found
#		0 = not found
#
#	returns:
#		0 = no errors
#
# *****************************************************************************
function lmsUtilCommandExists()
{
	local cmnd=${1}

	type ${cmnd} >/dev/null 2>&1
	[[ $? -eq 0 ]] && echo "1" || echo "0"

	return 0
}

# *****************************************************************************
#
#	lmsUtilCmndExists
#
#		check if the given external command has been installed
#
#	parameters:
#		cmnd = command to check for
#
#	returns:
#		0 = found
#		1 = not found
#
# *****************************************************************************
function lmsUtilCmndExists()
{
	local cmnd=${1}

	type ${cmnd} >/dev/null 2>&1
	return $?
}

# *****************************************************************************
#
#	lmsUtilVarExists
#
#		check if the given variable exists
#
#	parameters:
#		dclVar = name of variable to check for
#		dclString = (optional) location to store the declare information string
#
#	returns:
#		0 = found
#		1 = not found
#       2 = unable to store dclString
#
# *****************************************************************************
function lmsUtilVarExists()
{
	local dclString=$( declare -p | grep "${1}" )
	[[ $? -eq 0 ]] || return 1

	[[ -z "${2}" ]] ||
	 {
		lmsDeclareStr "${2}" "${dclString}"
		[[ $? -eq 0 ]] || return 2
	 }

	return 0
}

# *****************************************************************************
#
#	lmsUtilIsArray
#
#		check if the given variable is an array
#
#	parameters:
#		name = name of variable to check
#		type = location to place the type
#				"A" = associative array
#				"a" = indexed array
#				"s" = scalar (string or integer)
#				"-" = unknown variable name
#
#	returns:
#		0 = is an array
#		1 = scalar (not an array)
#		2 = not declared
#		3 = lmsDeclareStr failed
#
# *****************************************************************************
function lmsUtilIsArray()
{
	[[ -z "${1}" || -z "${2}" ]] && return 2

	local aInfo=""

	lmsUtilVarExists "${1}" "aInfo"
	[[ $? -eq 0 ]] || return 2

	local aType=${aInfo:9:1}
	lmsDeclareStr "${2}" "${aType}"
	[[ $? -eq 0 ]] || return 3

	case "${aType}" in
		A | a)
			return 0
			;;

		s)
		    return 1
		    ;;

		*)
		    ;;
	esac

	return 2
}

# *******************************************************
#
#	lmsUtilIsUserType
#
#		outputs 1 for root (or sudoer) and 0 for user
#
#	parameters:
#		none
#
#	returns:
#		0 = user
#		1 = root / sudoer
#
# *******************************************************
function lmsUtilIsUserType()
{
	local iAm=$( whoami )

    [[ "${USER}" == "root" || "${iAm}" == "root" ]] && return 1
	return 0
}

# *******************************************************
#
#	lmsUtilIsRoot
#
#		return 0 if root, 1 if user
#
#	parameters:
#		none
#
#	returns:
#		0 = root
#       non-zero = not root
#
# *******************************************************
function lmsUtilIsRoot()
{
	local iAm=$( whoami )

	[[ "${iAm}" != "root" ]] && return 1
	return 0
}

# *******************************************************
#
#    lmsUtilIsUser
#
#		return 0 if user, 1 if not
#
#	parameters:
#		none
#
#	returns:
#		0 = user
#		non-zero = not user (root)
#
# *******************************************************
function lmsUtilIsUser()
{
    local iAm=$( whoami )

    [[ "${RUNUSER}" == "root" || "${iAm}" == "root" ]] && return 1
    return 0
}

# *****************************************************************************
#
#	lmsUtilOsInfo
#
#		parse the os-release data into a dynamic array
#
#	parameters:
#		arrayName = dynamic array name to create
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function lmsUtilOsInfo()
{
	local arrayName=${1}

	local item
	local itemName
	local itemValue

	lmsDynaNew "${arrayName}" "A"
	[[ $? -eq 0 ]] || return 1

	lmsutl_osString="$( cat /etc/os-release )"
	readarray -t osItems <<< "$lmsutl_osString"

	for item in "${osItems[@]}"
	do
		lmsStrSplit "${item}" itemName itemValue
		[[ $? -eq 0 ]] || return 2

		lmsStrUnquote "${itemValue}" itemValue

		[[ -z "${itemValue}" ]] && return 3

		lmsDynaSetAt ${arrayName} $itemName "${itemValue}"
		[[ $? -eq 0 ]] || return 4

		(( itemNumber++ ))
	done

	return 0
}

# *****************************************************************************
#
#	lmsUtilOsType
#
#		return the operating system type string
#
#	parameters:
#		arrayName = dynamic array name to create
#		osName = location to place short name of the operating system
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function lmsUtilOsType()
{
	local aName="${1}"
	local osName="${2}"

	local name=$( uname )

	[[ "${name}" == "^linux*" ]] &&
	 {
		lmsUtilOsInfo "${aName}"
		[[ $? -eq 0 ]] || return 1

		lmsDynaGetAt "${aName}" "ID" name
		[[ $? -eq 0 ]] || return 2

		[[ "${name}" == "linuxmint" ]] &&
		 {
			local like
			lmsDynaGetAt "${aName}" "ID_LIKE" like
			[[ $? -eq 0 ]] || return 3

			[[ -n "${like}" ]] && name="${like}"
		 }
	 }

	lmsDeclareStr "$osName" "${name}"
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ****************************************************************************
#
#	lmsUtilIndent
#
#		Add spaces (indentation) to the buffer
#
# 	Parameters:
#  		index = how many 'blocks' to indent
#		buffer = buffer to add the spaces to
#		bSize = (optional) number of spaces in a block (default=4)
#
#	Returns:
#		0 = no error
#
# ****************************************************************************
function lmsUtilIndent()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local -i indent=${1}
	local -i bSize=${3:-4}

	(( bSize+=${indent}*${bSize} ))

	[[ ${indent} -gt 0 ]]  &&  printf -v ${2} "%s%*s" "${2}" ${bSize}
	return 0
}

# *****************************************************************************
#
#	lmsUtilATS
#
#		Create a printable string representation of a single array
#
#	parameters:
#		name = the name of the GLOBAL array to turn into a string
#		string = location to place the string
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsUtilATS()
{
	local atsName="${1}"
	local atsString="${2}"

	[[ -z "${atsName}" || -z "${atsString}" ]] && return 1

	local arrayType
	lmsUtilIsArray "$atsName" "arrayType"
	[[ $? -eq 0 ]] || return 2

	local contents
	local key
	local keys

	eval 'keys=$'"{!$atsName[@]}"

	local msg=""
	printf -v msg "   %s:\n" ${atsName}

	for key in ${keys}
	do
		eval 'contents=$'"{$atsName[$key]}"

		[[ "${arrayType}" == "A" ]] &&
		 {
			printf -v msg "%s      [ %s ] = %s\n" "${msg}" "${key}" "${contents}"
			continue
		 }

		printf -v msg "%s      [ % 5u ] = %s\n" "${msg}" "${key}" "${contents}"
	done

	lmsDeclareStr ${atsString} "${msg}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# *****************************************************************************
#
#	lmsUtilWMList
#
#		returns an array of current windows and information
#
#	parameters:
#		wmList = Dynamic sequential array name to be created
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function lmsUtilWMList()
{
	local wmList="${1}"

	local wmArray
	local wmInfo

	OFS=$IFS
	IFS=$'\n'

	read -d '' -r -a wmArray <<< "$( wmctrl -lG )"

	IFS=$OFS

	lmsDynaNew "${wmList}" "a"
	[[ $? -eq 0 ]] || return 1

	for wmInfo in "${wmArray[@]}"
	do
		lmsDynaAdd "${wmList}" "${wmInfo}"
		[[ $? -eq 0 ]] || return 2

	done

	return 0
}

# *****************************************************************************
#
#	lmsUtilWMParse
#
#		parses window information record into an associative dynamic array
#
#	parameters:
#		wmParsed = the name of an  associative dynamic array to populate
#		wmInfo   = record to be parsed
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function lmsUtilWMParse()
{
	local wmParsed="${1}"
	local wmInfo="${2}"

	lmsDynaRegistered "${wmParsed}"
	[[ $? -eq 0 ]] &&
	 {
		lmsDynaNew "${wmParsed}" "A"
		[[ $? -eq 0 ]] || return 1
	 }

	local fieldIndex=0
	local fieldCount=${#lmsutl_wmFields[@]}
	local titleStart=0

	lmsStrExplode "${wmInfo}"

	while [[ ${fieldIndex} -lt ${fieldCount} ]]
	do
		lmsDynaSetAt ${wmParsed} ${lmsutl_wmFields[$fieldIndex]} "${lmsstr_Exploded[$fieldIndex]}"
		[[ $? -eq 0 ]] || return 2

		(( fieldIndex++ ))

		[[ ${fieldIndex} -lt ${fieldCount} ]] &&
		 {
			let titleStart=$titleStart+${#lmsstr_Exploded[$fieldIndex-1]}+1
		 }
	done

	let fieldIndex-=1
	lmsDynaSetAt "${wmParsed}" "${lmsutl_wmFields[$fieldIndex]}" "${wmInfo:$titleStart}"

	return 0
}


