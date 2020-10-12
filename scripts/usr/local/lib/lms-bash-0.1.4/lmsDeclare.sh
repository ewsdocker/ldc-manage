# *********************************************************************************
# *********************************************************************************
#
#   lmsDeclare.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.0
# @copyright © 2016-2019. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsDeclare
#
# *****************************************************************************
#
#	Copyright © 2016-2019. EarthWalk Software
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
#			Version 0.0.1 - 02-29-2016.
#			        0.0.2 - 03-31-2016.
#					0.0.3 - 06-28-2016.
#					0.1.0 - 01-10-2017.
#					0.1.1 - 08-25-2018.
#					0.2.0 - 07-06-2019.
#
# *********************************************************************************

declare -r lmslib_lmsDeclare="0.1.1"	# version of library

# *********************************************************************************
#
#	lmsDeclareSet
#
#		sets the value of a global variable
#
#	parameters:
#		name = name of global variable
#		value = value to set
#
#	returns:
#		0 = no error
#		1 = variable name is a number
#		2 = unable to set value
#
# *********************************************************************************
function lmsDeclareSet()
{
	local svName=${1:-""}
    local svValue=${2:-""}

	[[ -z "${svName}" ]] && return 1

	lmsStrIsInteger "${svName}"
	[[ $? -eq 0 ]] && return 1

	eval ${svName}="'${svValue}'"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *********************************************************************************
#
# Pre-release.
#
#	lmsDeclareNs
#
#		creates a global variable namespace
#
#	parameters:
#		name = name of global variable
#		location = (optional) location to place the result
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
function lmsDeclareNs()
{
	[[ -z "${1}" ]] && return 1

	local svBuffer="${1} ${2}"
	lmsStrTrim "${svBuffer}" svBuffer
	
	return 0
}

# *********************************************************************************
#
#	lmsDeclareInt
#
#		creates a global integer variable and sets it's value
#
#	parameters:
#		name = name of global variable
#		content = value to set
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
function lmsDeclareInt()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1
	declare -gi "${1}"

	lmsDeclareSet ${1} "${2}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *********************************************************************************
#
#	lmsDeclareStr
#
#		creates a global string variable and sets it's value
#
#	parameters:
#		name = name of global variable
#		value = value to set
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
function lmsDeclareStr()
{
	[[ -z "${1}" ]] && return 1
	declare -g "${1}"

	lmsDeclareSet ${1} "${2}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *********************************************************************************
#
#	lmsDeclarePwd
#
#		creates a global string password variable and sets it's value
#
#	parameters:
#		name = name of global variable
#		value = value to set
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
function lmsDeclarePwd()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local svName=${1}
	local svContent="${2}"

	svContent=$( echo -n "${svContent}" | base64 )

	lmsDeclareStr ${svName} "${svContent}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# *********************************************************************************
#
#	lmsDeclareAssoc
#
#		creates a global associative array variable
#
#	parameters:
#		name = name of global variable
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
function lmsDeclareAssoc()
{
	[[ -z "${1}" ]] && return 1

	local svName="${1}"
	declare -gA "$svName"

	return 0
}

# *********************************************************************************
#
#	lmsDeclareArray
#
#		creates a global array variable
#
#	parameters:
#		name = name of global variable
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
function lmsDeclareArray()
{
	[[ -z "${1}" ]] && return 1

	local svName="${1}"
	declare -ga "${svName}"

	return 0
}

# *********************************************************************************
#
#	lmsDeclareArrayEl
#
#		Adds an element to a (global) associative array variable
#
#	parameters:
#		parent = global array variable
#		name = element name or index number
#		value = value to set
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsDeclareArrayEl()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local svParent="${1}"
	local svName="${2}"
	local svValue=${3:-""}

	eval "$svParent[$svName]='${svValue}'"

	return 0
}

