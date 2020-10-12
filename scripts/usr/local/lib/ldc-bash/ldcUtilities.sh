# *****************************************************************************
# *****************************************************************************
#
#   ldcUtilities.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.5
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package ldcUtilities
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/ldc-bash.
#
#   ewsdocker/ldc-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/ldc-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/ldc-bash.  If not, see 
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
declare -r ldclib_ldcUtilities="0.0.5"	# version of library

declare    ldcutl_osString
declare -a ldcutl_wmFields=( window winws winx winy winw winh winmachine wintitle )

# *****************************************************************************
#
#	ldcUtilCommandExists
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
function ldcUtilCommandExists()
{
	local cmnd=${1}

	type ${cmnd} >/dev/null 2>&1
	[[ $? -eq 0 ]] && echo "1" || echo "0"

	return 0
}

# *****************************************************************************
#
#	ldcUtilCmndExists
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
function ldcUtilCmndExists()
{
	local cmnd=${1}

	type ${cmnd} >/dev/null 2>&1
	return $?
}

# *****************************************************************************
#
#	ldcUtilVarExists
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
function ldcUtilVarExists()
{
	local dclString=$( declare -p | grep "${1}" )
	[[ $? -eq 0 ]] || return 1

	[[ -z "${2}" ]] ||
	 {
		ldcDeclareStr "${2}" "${dclString}"
		[[ $? -eq 0 ]] || return 2
	 }

	return 0
}

# *****************************************************************************
#
#	ldcUtilIsArray
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
#		3 = ldcDeclareStr failed
#
# *****************************************************************************
function ldcUtilIsArray()
{
	[[ -z "${1}" || -z "${2}" ]] && return 2

	local aInfo=""

	ldcUtilVarExists "${1}" "aInfo"
	[[ $? -eq 0 ]] || return 2

	local aType=${aInfo:9:1}
	ldcDeclareStr "${2}" "${aType}"
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
#	ldcUtilIsUserType
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
function ldcUtilIsUserType()
{
	local iAm=$( whoami )

    [[ "${USER}" == "root" || "${iAm}" == "root" ]] && return 1
	return 0
}

# *******************************************************
#
#	ldcUtilIsRoot
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
function ldcUtilIsRoot()
{
	local iAm=$( whoami )

	[[ "${iAm}" != "root" ]] && return 1
	return 0
}

# *******************************************************
#
#    ldcUtilIsUser
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
function ldcUtilIsUser()
{
    local iAm=$( whoami )

    [[ "${RUNUSER}" == "root" || "${iAm}" == "root" ]] && return 1
    return 0
}

# *****************************************************************************
#
#	ldcUtilOsInfo
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
function ldcUtilOsInfo()
{
	local arrayName=${1}

	local item
	local itemName
	local itemValue

	ldcDynaNew "${arrayName}" "A"
	[[ $? -eq 0 ]] || return 1

	ldcutl_osString="$( cat /etc/os-release )"
	readarray -t osItems <<< "$ldcutl_osString"

	for item in "${osItems[@]}"
	do
		ldcStrSplit "${item}" itemName itemValue
		[[ $? -eq 0 ]] || return 2

		ldcStrUnquote "${itemValue}" itemValue

		[[ -z "${itemValue}" ]] && return 3

		ldcDynaSetAt ${arrayName} $itemName "${itemValue}"
		[[ $? -eq 0 ]] || return 4

		(( itemNumber++ ))
	done

	return 0
}

# *****************************************************************************
#
#	ldcUtilOsType
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
function ldcUtilOsType()
{
	local aName="${1}"
	local osName="${2}"

	local name=$( uname )

	[[ "${name}" == "^linux*" ]] &&
	 {
		ldcUtilOsInfo "${aName}"
		[[ $? -eq 0 ]] || return 1

		ldcDynaGetAt "${aName}" "ID" name
		[[ $? -eq 0 ]] || return 2

		[[ "${name}" == "linuxmint" ]] &&
		 {
			local like
			ldcDynaGetAt "${aName}" "ID_LIKE" like
			[[ $? -eq 0 ]] || return 3

			[[ -n "${like}" ]] && name="${like}"
		 }
	 }

	ldcDeclareStr "$osName" "${name}"
	[[ $? -eq 0 ]] || return 4

	return 0
}

# ****************************************************************************
#
#	ldcUtilIndent
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
function ldcUtilIndent()
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
#	ldcUtilATS
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
function ldcUtilATS()
{
	local atsName="${1}"
	local atsString="${2}"

	[[ -z "${atsName}" || -z "${atsString}" ]] && return 1

	local arrayType
	ldcUtilIsArray "$atsName" "arrayType"
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

	ldcDeclareStr ${atsString} "${msg}"
	[[ $? -eq 0 ]] || return 3

	return 0
}

# *****************************************************************************
#
#	ldcUtilWMList
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
function ldcUtilWMList()
{
	local wmList="${1}"

	local wmArray
	local wmInfo

	OFS=$IFS
	IFS=$'\n'

	read -d '' -r -a wmArray <<< "$( wmctrl -lG )"

	IFS=$OFS

	ldcDynaNew "${wmList}" "a"
	[[ $? -eq 0 ]] || return 1

	for wmInfo in "${wmArray[@]}"
	do
		ldcDynaAdd "${wmList}" "${wmInfo}"
		[[ $? -eq 0 ]] || return 2

	done

	return 0
}

# *****************************************************************************
#
#	ldcUtilWMParse
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
function ldcUtilWMParse()
{
	local wmParsed="${1}"
	local wmInfo="${2}"

	ldcDynaRegistered "${wmParsed}"
	[[ $? -eq 0 ]] &&
	 {
		ldcDynaNew "${wmParsed}" "A"
		[[ $? -eq 0 ]] || return 1
	 }

	local fieldIndex=0
	local fieldCount=${#ldcutl_wmFields[@]}
	local titleStart=0

	ldcStrExplode "${wmInfo}"

	while [[ ${fieldIndex} -lt ${fieldCount} ]]
	do
		ldcDynaSetAt ${wmParsed} ${ldcutl_wmFields[$fieldIndex]} "${ldcstr_Exploded[$fieldIndex]}"
		[[ $? -eq 0 ]] || return 2

		(( fieldIndex++ ))

		[[ ${fieldIndex} -lt ${fieldCount} ]] &&
		 {
			let titleStart=$titleStart+${#ldcstr_Exploded[$fieldIndex-1]}+1
		 }
	done

	let fieldIndex-=1
	ldcDynaSetAt "${wmParsed}" "${ldcutl_wmFields[$fieldIndex]}" "${wmInfo:$titleStart}"

	return 0
}


