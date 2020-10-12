# ******************************************************************************
# ******************************************************************************
#
#   lmsDomN.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage DOMNode
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
#		Version 0.0.1 - 07-16-2016.
#				0.0.2 - 09-06-2016.
#				0.0.3 - 09-15-2016.
#				0.1.0 - 01-17-2017.
#				0.1.1 - 02-10-2017.
#				0.1.2 - 08-25-2018.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_DOMNode="0.1.2"	# version of DOMNode library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare    lmsdom_nodeInitialized=0		# Set to 1 when lmsDomNInit has completed
declare -a lmsdom_tagList=( XPATH XML_ENTITY XML_CONTENT XML_TAG_NAME XML_TAG_TYPE XML_COMMENT XML_PATH XML_ATT_COUNT )

declare    lmsdom_nodeValid=0

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsDomNInit
#
#		Initialize the node
#
#	parameters:
#		None
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDomNInit()
{
	declare -p "lmslib_lmsDynArray" > /dev/null 2>&1
	[[ $? -eq 0 ]] || return 1

	lmsdom_nodeInitialized=1
	return 0
}

# ******************************************************************************
#
#	lmsDomNCopyAtt
#
#		Copy attribute array to node's attribute array
#
#	parameters:
#		uid = uid for the node to load attributes for
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDomNCopyAtt()
{
	local attName="lmsdom_${1}_att"

	lmsDynaNew "${attName}" "A"
	[[ $? -eq 0 ]] || return 1

	lmsDynnReset ${lmsdom_ArrayName}
	[[ $? -eq 0 ]] || return 1

	lmsDynnValid ${lmsdom_ArrayName} lmsdom_nodeValid

	local key
	local value

	while [[ lmsdom_nodeValid -eq 1 ]]
	do
		lmsDynnMap ${lmsdom_ArrayName} value key
		[[ $? -eq 0 ]] || return 2

		lmsDynaSetAt "${attName}" "${key}" "${value}"
		[[ $? -eq 0 ]] || return 3

		lmsDynnNext ${lmsdom_ArrayName}
		lmsDynn_Valid
		lmsdom_nodeValid=$?
	done

	return 0
}

# ******************************************************************************
#
#	lmsDomNCreate
#
#		Set the DOMNode values
#
#	parameters:
#		nodeName = uid node name
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsDomNCreate()
{
	[[ ${lmsdom_nodeInitialized} -eq 1 ]] ||
	 {
		lmsDomNInit
		[[ $? -eq 0 ]] || return 1
	 }

	[[ -z "${1}" ]] && return 2

	local uid=${1}
	local nodeName="lmsdom_${uid}_node"

	lmsDynaNew "${nodeName}" "A"
	[[ $? -eq 0 ]] || return 3

	lmsDynaSetAt ${nodeName} "uid" $uid
	[[ $? -eq 0 ]] || return 4

	lmsDynaSetAt ${nodeName} "attcount" 0
	[[ $? -eq 0 ]] || return 5

	local tag

	for tag in "${lmsdom_tagList[@]}"
	do
		case ${tag} in
		
			"XPATH")
				lmsDynaSetAt ${nodeName} "xpath" "${lmsdom_XPath}"
				lmserr_result=$?
				;;
	
			"XML_ENTITY")
				lmsDynaSetAt ${nodeName} "tag" "${lmsdom_Entity}"
				lmserr_result=$?
				;;

			"XML_CONTENT")
				lmsStrTrim "${lmsdom_Content}" lmsdom_Content
				lmsDynaSetAt ${nodeName} "content" "${lmsdom_Content}"
				lmserr_result=$?
				;;

			"XML_TAG_NAME")
				lmsDynaSetAt ${nodeName} "tagname" "${lmsdom_TagName}"
				lmserr_result=$?
				;;

			"XML_TAG_TYPE")
				lmsDynaSetAt ${nodeName} "tagtype"  "${lmsdom_TagType}"
				lmserr_result=$?
				;;

			"XML_COMMENT")
				lmsDynaSetAt ${nodeName} "comment" "${lmsdom_Comment}"
				lmserr_result=$?
				;;

			"XML_PATH")
				lmsDynaSetAt ${nodeName} "path" "${lmsdom_Path}"
				lmserr_result=$?
				;;

			"XML_ATT_COUNT")
				lmsDynaSetAt ${nodeName} "attcount" "${lmsdom_attribCount}"
				lmserr_result=$?
				;;

			*)
				lmserr_result=1
				;;
		esac

		[[ ${lmserr_result} -eq 0 ]] || return 1
	done

	[[ ${lmsdom_attribCount} -gt 0 ]] &&
	 {
		lmsDomNCopyAtt ${uid}
		[[ $? -eq 0 ]] || return 1
	 }
	
	lmsdom_curentNode=${uid}
	return 0
}


