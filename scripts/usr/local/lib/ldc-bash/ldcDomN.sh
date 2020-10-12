# ******************************************************************************
# ******************************************************************************
#
#   ldcDomN.sh
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
#		Version 0.0.1 - 07-16-2016.
#				0.0.2 - 09-06-2016.
#				0.0.3 - 09-15-2016.
#				0.1.0 - 01-17-2017.
#				0.1.1 - 02-10-2017.
#				0.1.2 - 08-25-2018.
#
# ******************************************************************************
# ******************************************************************************

declare -r ldclib_DOMNode="0.1.2"	# version of DOMNode library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare    ldcdom_nodeInitialized=0		# Set to 1 when ldcDomNInit has completed
declare -a ldcdom_tagList=( XPATH XML_ENTITY XML_CONTENT XML_TAG_NAME XML_TAG_TYPE XML_COMMENT XML_PATH XML_ATT_COUNT )

declare    ldcdom_nodeValid=0

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	ldcDomNInit
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
function ldcDomNInit()
{
	declare -p "ldclib_ldcDynArray" > /dev/null 2>&1
	[[ $? -eq 0 ]] || return 1

	ldcdom_nodeInitialized=1
	return 0
}

# ******************************************************************************
#
#	ldcDomNCopyAtt
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
function ldcDomNCopyAtt()
{
	local attName="ldcdom_${1}_att"

	ldcDynaNew "${attName}" "A"
	[[ $? -eq 0 ]] || return 1

	ldcDynnReset ${ldcdom_ArrayName}
	[[ $? -eq 0 ]] || return 1

	ldcDynnValid ${ldcdom_ArrayName} ldcdom_nodeValid

	local key
	local value

	while [[ ldcdom_nodeValid -eq 1 ]]
	do
		ldcDynnMap ${ldcdom_ArrayName} value key
		[[ $? -eq 0 ]] || return 2

		ldcDynaSetAt "${attName}" "${key}" "${value}"
		[[ $? -eq 0 ]] || return 3

		ldcDynnNext ${ldcdom_ArrayName}
		ldcDynn_Valid
		ldcdom_nodeValid=$?
	done

	return 0
}

# ******************************************************************************
#
#	ldcDomNCreate
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
function ldcDomNCreate()
{
	[[ ${ldcdom_nodeInitialized} -eq 1 ]] ||
	 {
		ldcDomNInit
		[[ $? -eq 0 ]] || return 1
	 }

	[[ -z "${1}" ]] && return 2

	local uid=${1}
	local nodeName="ldcdom_${uid}_node"

	ldcDynaNew "${nodeName}" "A"
	[[ $? -eq 0 ]] || return 3

	ldcDynaSetAt ${nodeName} "uid" $uid
	[[ $? -eq 0 ]] || return 4

	ldcDynaSetAt ${nodeName} "attcount" 0
	[[ $? -eq 0 ]] || return 5

	local tag

	for tag in "${ldcdom_tagList[@]}"
	do
		case ${tag} in
		
			"XPATH")
				ldcDynaSetAt ${nodeName} "xpath" "${ldcdom_XPath}"
				ldcerr_result=$?
				;;
	
			"XML_ENTITY")
				ldcDynaSetAt ${nodeName} "tag" "${ldcdom_Entity}"
				ldcerr_result=$?
				;;

			"XML_CONTENT")
				ldcStrTrim "${ldcdom_Content}" ldcdom_Content
				ldcDynaSetAt ${nodeName} "content" "${ldcdom_Content}"
				ldcerr_result=$?
				;;

			"XML_TAG_NAME")
				ldcDynaSetAt ${nodeName} "tagname" "${ldcdom_TagName}"
				ldcerr_result=$?
				;;

			"XML_TAG_TYPE")
				ldcDynaSetAt ${nodeName} "tagtype"  "${ldcdom_TagType}"
				ldcerr_result=$?
				;;

			"XML_COMMENT")
				ldcDynaSetAt ${nodeName} "comment" "${ldcdom_Comment}"
				ldcerr_result=$?
				;;

			"XML_PATH")
				ldcDynaSetAt ${nodeName} "path" "${ldcdom_Path}"
				ldcerr_result=$?
				;;

			"XML_ATT_COUNT")
				ldcDynaSetAt ${nodeName} "attcount" "${ldcdom_attribCount}"
				ldcerr_result=$?
				;;

			*)
				ldcerr_result=1
				;;
		esac

		[[ ${ldcerr_result} -eq 0 ]] || return 1
	done

	[[ ${ldcdom_attribCount} -gt 0 ]] &&
	 {
		ldcDomNCopyAtt ${uid}
		[[ $? -eq 0 ]] || return 1
	 }
	
	ldcdom_curentNode=${uid}
	return 0
}


