# *****************************************************************************
# *****************************************************************************
#
#   lmsCliNode.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage lmsCli
#
# *****************************************************************************
#
#	Copyright © 2017. EarthWalk Software
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
#			Version 0.0.1 - 02-12-2017.
#					0.0.2 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    lmslib_lmsCliNode="0.0.2"			# library version number

declare    lmsclin_valid=0						# validity of the current argument pointer
declare    lmsclin_node=""						# node name

# ******************************************************************************
# ******************************************************************************
#
#		Functions - general purpose user functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsClinName
#
#		Return the current cli command argument name and value
#
#	parameters:
#		command = the cli command
#		cmndNum = command stack level
#		name = location to place the name
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsClinName()
{
	[[ -z "${1}" || -z "${2}" | -z "${3}" ]] && return 1

	printf -v ${3} "lmsclin_%s%05u" ${1} ${2}
	return 0
}

# ******************************************************************************
#
#	lmsClinCurrent
#
#		Return the current cli command argument name and value
#
#	parameters:
#		node = the name of the cli command node
#		value = location to place the value at the mapped iterator key
#		name = location to place the iterator key
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsClinCurrent()
{
	[[ -z "${1}" || -z "${2}" | -z "${3}" ]] && return 1

	lmsDynnMap ${1} ${2} ${3} 
	[[ $? -eq 0 ]] && return 0

	return 2
}

# ******************************************************************************
#
#	lmsClinNext
#
#		Advance to the next argument
#
#	parameters:
#		nodeName = the name of the cli command to create
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsClinNext()
{
	[[ -z "${1}" ]] && return 1

	lmsDynnNext ${1}
	[[ $? -eq 0 ]] && return 0

	return 2
}

# ******************************************************************************
#
#	lmsClinReset
#
#		Reset the iterator to the first argument
#
#	parameters:
#		nodeName = the name of the cli command to create
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsClinReset()
{
	[[ -z "${1}" ]] && return 1

	lmsDynnReset ${lmsclin_node}
	[[ $? -eq 0 ]] && return 0

	return 2
}

# ******************************************************************************
#
#	lmsClinValid
#
#		check the validity of the current argument pointer
#
#	parameters:
#		node = the name of the cli command to create
#		valid = location to store the result
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsClinValid()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	lmsDynnValid ${1} ${2}
	[[ $? -eq 0 ]] && return 0

	return 2
}


