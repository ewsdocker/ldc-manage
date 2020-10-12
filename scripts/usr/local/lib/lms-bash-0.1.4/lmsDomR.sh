# *****************************************************************************
# *****************************************************************************
#
#   lmsDomR.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsDomRRead
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

declare -r lmslib_lmsDomR="0.1.2"	# version of this library

declare    lmsdom_docReadCallback	# storage for the lmsDomRRead callback name
declare -a lmsdom_tagTypes=( OPEN OPENCLOSE CLOSE INSTRUCTION )
declare	   lmsdom_docLevel="lmsdom_levelStack"

# ****************************************************************************
#
#	lmsDomROpenTag
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
function lmsDomROpenTag()
{
	local uidLength=${1:-12}
	local uid
	local parentUid

	local stackLevel=0
	
	lmsUIdUnique uid ${uidLength}
	[[ $? -eq 0 ]] || return 1

	lmsDynaSetAt "lmsdom_tags" "${uid}" ${lmsdom_TagName}
	[[ $? -eq 0 ]] || return 1

    lmsDynaNew "lmsdom_${uid}" "a"
	[[ $? -eq 0 ]] || return 1

	lmsDomNCreate "${uid}"
	[[ $? -eq 0 ]] || return 1

	lmsStackSize ${lmsdom_docLevel} stackLevel
	[[ $? -eq 0 ]] || return 1

	if [[ ${stackLevel} -eq 0 ]]
	then
		[[ -n "${lmsdom_docTree}" ]] && return 1
		lmsdom_docTree=$uid
	else
		lmsStackPeek ${lmsdom_docLevel} parentUid
		[[ $? -eq 0 ]] || return 1

		lmsDynaAdd "lmsdom_${parentUid}" "${uid}"
		[[ $? -eq 0 ]] || return 1
	fi

	[[ "${lmsdom_TagType}" == "OPEN" ]] &&
	 {
		lmsStackWrite "${lmsdom_docLevel}" "${uid}"
		[[ $? -eq 0 ]] || return 1
	 }
	
	return 0
}

# ****************************************************************************
#
#	lmsDomRRead
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
function lmsDomRRead()
{
	local uid

	[[ ${lmsdom_docInit} -eq 0 ]] && return 1

	[[ ! "${lmsdom_tagTypes[@]}" =~ "${lmsdom_TagType}" ]] && return 0

	local result=0

	case ${lmsdom_TagType} in

		"INSTRUCTION")
			[[ "${lmsdom_TagName}" == "xml" && -z "${lmsdom_docTree}" ]]  &&
			 {
				lmsDomRCreateRoot
				lmsDomROpenTag 8
				[[ $? -eq 0 ]] || result=1
			 }
			;;

		"OPEN" | "OPENCLOSE")
			lmsDomROpenTag 8
			[[ $? -eq 0 ]] || result=2
			;;

		"CLOSE")
			lmsStackRead ${lmsdom_docLevel} uid
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
#	lmsDomRCreateRoot
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
function lmsDomRCreateRoot()
{
	lmsdom_XPath=""
	lmsdom_Entity="document"
	lmsdom_Content=""
	lmsdom_TagName="document"
	lmsdom_TagType="OPEN"
	lmsdom_Comment=""
	lmsdom_Path="document"
	lmsdom_attribCount=2
}

# ****************************************************************************
#
#	lmsDomRSearchTags
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
function lmsDomRSearchTags()
{
	local searchName=${1:-""}
	local searchUid

	lmsDynaFind "lmsdom_tags" ${searchName} searchUid
	[[ $? -eq 0 ]] || return 1

	lmsDeclareStr ${2} "${searchUid}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# ****************************************************************************
#
#	lmsDomRCallback
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
function lmsDomRCallback()
{
	[[ -z "${1}" ]] && return 1

	lmsdom_docReadCallback="${1}"

	lmsDomDCallback "${lmsdom_docReadCallback}"
	[[ $? -eq 0 ]] || return 2

	return 0	
}

# ****************************************************************************
#
#	lmsDomRReset
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
function lmsDomRReset()
{
	[[ -n "${lmsdom_rdomCallback}" ]] &&
	 {
		DOMRegisterCallback ${lmsdom_rdomCallback}
		[[ $? -eq 0 ]] || return 1
	 }

	return 0	
}

# ****************************************************************************
#
#	lmsDomRInit
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
function lmsDomRInit()
{
	[[ ${lmsdom_docInit} -ne 0 ]]  &&  lmsDomRReset

	lmsdom_docInit=0
	lmsStackCreate ${lmsdom_docLevel} lmsdom_docStackUid 12
	[[ $? -eq 0 ]] || return 1

	lmsDynaNew "lmsdom_tags" "A"
	[[ $? -eq 0 ]] || return 2

	lmsDomRCallback "lmsDomRRead"
	[[ $? -eq 0 ]] || return 3

	lmsdom_docTree=""
	lmsdom_docInit=1

	return 0	
}


