# *****************************************************************************
# *****************************************************************************
#
#   ldcDomR.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage ldcDomRRead
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
#			Version 0.0.1 - 07-17-2016.
#                   0.0.2 - 07-29-2016.
#                   0.0.3 - 08-02-2016.
#					0.0.4 - 09-06-2016.
#					0.1.0 - 01-15-2017.
#					0.1.1 - 02-10-2017.
#					0.1.2 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcDomR="0.1.2"	# version of this library

declare    ldcdom_docReadCallback	# storage for the ldcDomRRead callback name
declare -a ldcdom_tagTypes=( OPEN OPENCLOSE CLOSE INSTRUCTION )
declare	   ldcdom_docLevel="ldcdom_levelStack"

# ****************************************************************************
#
#	ldcDomROpenTag
#
#		Process the open tag contents
#
#	parameters:
#		uidLength = (optional) number of characters in the uid (default=12)
#
#	returns:
#		0 = no errors
#		non-zero = error number
#
# ****************************************************************************
function ldcDomROpenTag()
{
	local uidLength=${1:-12}
	local uid
	local parentUid

	local stackLevel=0
	
	ldcUIdUnique uid ${uidLength}
	[[ $? -eq 0 ]] || return 1

	ldcDynaSetAt "ldcdom_tags" "${uid}" ${ldcdom_TagName}
	[[ $? -eq 0 ]] || return 1

    ldcDynaNew "ldcdom_${uid}" "a"
	[[ $? -eq 0 ]] || return 1

	ldcDomNCreate "${uid}"
	[[ $? -eq 0 ]] || return 1

	ldcStackSize ${ldcdom_docLevel} stackLevel
	[[ $? -eq 0 ]] || return 1

	if [[ ${stackLevel} -eq 0 ]]
	then
		[[ -n "${ldcdom_docTree}" ]] && return 1
		ldcdom_docTree=$uid
	else
		ldcStackPeek ${ldcdom_docLevel} parentUid
		[[ $? -eq 0 ]] || return 1

		ldcDynaAdd "ldcdom_${parentUid}" "${uid}"
		[[ $? -eq 0 ]] || return 1
	fi

	[[ "${ldcdom_TagType}" == "OPEN" ]] &&
	 {
		ldcStackWrite "${ldcdom_docLevel}" "${uid}"
		[[ $? -eq 0 ]] || return 1
	 }
	
	return 0
}

# ****************************************************************************
#
#	ldcDomRRead
#
#		Load the xml file into a DOM tree structure
#
# 	Parameters:
#  		xmlFile = path to the XML file
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomRRead()
{
	local uid

	[[ ${ldcdom_docInit} -eq 0 ]] && return 1

	[[ ! "${ldcdom_tagTypes[@]}" =~ "${ldcdom_TagType}" ]] && return 0

	local result=0

	case ${ldcdom_TagType} in

		"INSTRUCTION")
			[[ "${ldcdom_TagName}" == "xml" && -z "${ldcdom_docTree}" ]]  &&
			 {
				ldcDomRCreateRoot
				ldcDomROpenTag 8
				[[ $? -eq 0 ]] || result=1
			 }
			;;

		"OPEN" | "OPENCLOSE")
			ldcDomROpenTag 8
			[[ $? -eq 0 ]] || result=2
			;;

		"CLOSE")
			ldcStackRead ${ldcdom_docLevel} uid
			[[ $? -eq 0 ]] || result=3
			;;

		*)
			result=0
			;;
	esac

	return ${result}
}

# ****************************************************************************
#
#	ldcDomRCreateRoot
#
#		Set dummy DOM variables to use as the tree root.
#
# 	Parameters:
#		None
#
#	Returns:
#		0 = no error
#
# ****************************************************************************
function ldcDomRCreateRoot()
{
	ldcdom_XPath=""
	ldcdom_Entity="document"
	ldcdom_Content=""
	ldcdom_TagName="document"
	ldcdom_TagType="OPEN"
	ldcdom_Comment=""
	ldcdom_Path="document"
	ldcdom_attribCount=2
}

# ****************************************************************************
#
#	ldcDomRSearchTags
#
#		Search the tags table for the first occurrence of a given value
#
# 	Parameters:
#  		searchName = value to search for
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomRSearchTags()
{
	local searchName=${1:-""}
	local searchUid

	ldcDynaFind "ldcdom_tags" ${searchName} searchUid
	[[ $? -eq 0 ]] || return 1

	ldcDeclareStr ${2} "${searchUid}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ****************************************************************************
#
#	ldcDomRCallback
#
#		Register the name of the callback function to process each xml element
#
#	parameters:
#		callback = name of the callback function
#
#	returns:
#		0 = no errors
#		non-zero = error number
#
# ****************************************************************************
function ldcDomRCallback()
{
	[[ -z "${1}" ]] && return 1

	ldcdom_docReadCallback="${1}"

	ldcDomDCallback "${ldcdom_docReadCallback}"
	[[ $? -eq 0 ]] || return 2

	return 0	
}

# ****************************************************************************
#
#	ldcDomRReset
#
#		Register the name of the callback function to process each xml element
#
#	parameters:
#		callback = name of the callback function
#
#	returns:
#		0 = no errors
#		non-zero = error number
#
# ****************************************************************************
function ldcDomRReset()
{
	[[ -n "${ldcdom_rdomCallback}" ]] &&
	 {
		DOMRegisterCallback ${ldcdom_rdomCallback}
		[[ $? -eq 0 ]] || return 1
	 }

	return 0	
}

# ****************************************************************************
#
#	ldcDomRInit
#
#		Initialize the DOM read variables and set the callback function
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error number
#
# ****************************************************************************
function ldcDomRInit()
{
	[[ ${ldcdom_docInit} -ne 0 ]]  &&  ldcDomRReset

	ldcdom_docInit=0
	ldcStackCreate ${ldcdom_docLevel} ldcdom_docStackUid 12
	[[ $? -eq 0 ]] || return 1

	ldcDynaNew "ldcdom_tags" "A"
	[[ $? -eq 0 ]] || return 2

	ldcDomRCallback "ldcDomRRead"
	[[ $? -eq 0 ]] || return 3

	ldcdom_docTree=""
	ldcdom_docInit=1

	return 0	
}


