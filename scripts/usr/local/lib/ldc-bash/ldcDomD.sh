# *****************************************************************************
# *****************************************************************************
#
#   ldcDomD.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage DOMDoc
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
#			Version 0.0.1 - 06-28-2016.
#					0.0.2 - 09-06-2016.
#					0.0.3 - 09-15-2016.
#					0.1.0 - 01-17-2017.
#					0.1.1 - 02-10-2017.
#					0.1.2 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcDomD="0.1.2"	# version of this library

# *******************************************************
# *******************************************************

declare    ldcdom_ArrayName			# name of the ldcdom_attArray
declare    ldcdom_attribCount		# number of items in the AttributesArray

declare    ldcdom_attribs			# attributes
declare    ldcdom_attribsParsing	# attribute parsing flag

# *******************************************************

declare    ldcdom_TagType			# Type of the current tag. The value can be
									#     "OPEN", "CLOSE", "OPENCLOSE", 
									#     "COMMENT" or "INSTRUCTION"
declare    ldcdom_Entity			# The current XML entity
declare    ldcdom_Content			# Data found after the current XML entity
declare    ldcdom_TagName			# Name of the current tag.  If the current tag is
									#   a close tag, the leading "/" is present in the tag name
declare    ldcdom_Comment			# If the current tag is of type "COMMENT",
									#   the text of the comment
declare    ldcdom_XPath				# Full XPath path of the current tag

# *******************************************************

declare -i ldcdom_docInit=0			# docInit = non-zero if initialization complete

declare    ldcdom_docXMLFile		# the xml file to convert to DOM format in memory

declare    ldcdom_docStackUid		# uid of the processing stack
declare    ldcdom_docLevel			# the name to use for the level stack

declare    ldcdom_docTree=""		# root of the document Tree

declare    ldcdom_docTemp
declare    ldcdom_docPath			# path to the xml file
declare    ldcdom_docEOF			# okay to continue processing

declare    ldcdom_xData
declare    ldcdom_xTagFirst
declare    ldcdom_xTagLen
declare    ldcdom_xTagNoF
declare    ldcdom_xAttLast

declare -a ldcdom_pAttribs=()


# *******************************************************
#
#	ldcDomDParseAtt
#
#		Parse the Attributes contents and create an
#		  associative array of attribute names and values
#
#	Parameters:
#		none
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *******************************************************
function ldcDomDParseAtt()
{
	ldcdom_attribCount=0

	ldcStrExplode "${ldcdom_attribs}" " " ldcdom_pAttribs
	[[ ${#ldcdom_pAttribs[@]} -eq 0 ]] && return 1

	ldcDynaUnset "${ldcdom_ArrayName}"
	ldcDynaNew "${ldcdom_ArrayName}" "A"
	[[ $? -eq 0 ]] || return 2

	local attrib
	local name
	local value

	for attrib in "${ldcdom_pAttribs[@]}"
	do
		ldcStrSplit ${attrib} name value
		[[ $? -eq 0 ]] || return 3

		ldcDyna_SetAt "${name}" "${value}"
		[[ $? -eq 0 ]] || return 4
		
		(( ldcdom_attribCount++ ))
	done

	return 0
}

# ****************************************************************************
#
#	ldcDomDGetAtt
#
#		Get the Attributes contents from the attribute name
#
#	Parameters:
#		name = name of attribute to get
#		value = location to store the value of the attribute
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDGetAtt()
{
	[[ -z "${1}" || -z "${2}" ]] || return 1
	
	exec 3>&1 >/dev/tty

	local name="${1}"
	local value

	name=$(echo $name | tr "-" "_")

	if [[ -n "${ldcdom_attribs}" ]]
	then
		ldcdom_attribsParsing=$( echo $ldcdom_attribs | tr "-" "_" )
	else
		ldcdom_attribsParsing=$ldcdom_attribs
	fi

	eval local echo $ldcdom_attribsParsing

	value=$( eval echo \$$name )

	exec >&3

	ldcDeclareStr ${2} "$value"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# ****************************************************************************
#
#	ldcDomDHasAtt
#
#		check for attribute name in the attribute list
#
#	Parameters:
#		name = attribute name to get
#
#	Returns:
#		0 = not found
#		1 = found
#
# ****************************************************************************
function ldcDomDHasAtt()
{
	local name=${1}
	local value

	ldcDomDGetAtt ${name} value
	[[ ${value} -eq 0 ]] || return 1

	return 0
}

# ****************************************************************************
#
#	ldcDomDSetAtt
#
#		Set the Attributes contents
#
#	Parameters:
#		name = attribute name to set
#		value = attribute value
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDSetAtt()
{
	local attName=$1
	local attValue="${2}"

	local attName_VAR=$(echo $attName | tr "-" "_")
	local cValue

	ldcDomDGetAtt $attName cValue
	[[ $? -eq 0 ]] || return 1

	ldcdom_attribs=$(echo $ldcdom_attribs | sed -e "s/${attName}=[\"' ]${cValue}[\"' ]/${attName}=\"${attValue}\"/")
 }

# ****************************************************************************
#
#	ldcDomDRead
#
# 		Reads the DOM entity, parses it into variables and calls the
#			callback routine to process the entity
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDRead()
{
	local NR

	#
	# If the type of the last tag processed was "OPENCLOSE",
	#   update the XPath path before searching the next tag
	#

	if [ "$ldcdom_TagType" = "OPENCLOSE" ]
	then
		ldcdom_XPath=$(echo $ldcdom_XPath | sed -e "s/\/$ldcdom_TagName$//")
	fi

	#
	# Read the XML file to find the next tag
	# 	The output is a string containing the XML entity and the following
	# 		content, separate by a ">"
	#

	ldcdom_xData=$(awk 'BEGIN { RS = "<" ; FS = ">" ; OFS=">"; }

	{ printf "" > F }

	NR == 1 { getline ; print $1,$2"x" }
	NR >  2 { printf "<"$0 >> F }' F=${ldcdom_docTemp} ${ldcdom_docTemp})

	if [ ! -s ${ldcdom_docTemp} ]
	then
		ldcdom_docEOF=true
	fi

	unset ldcdom_Entity
	ldcdom_Entity=$(echo $ldcdom_xData | cut -d\> -f1)
	ldcdom_Content=$(printf "$ldcdom_xData" | cut -d\> -f2-)
	ldcdom_Content=${ldcdom_Content%x}

	unset ldcdom_Comment
	ldcdom_TagType="UNKNOW"
	ldcdom_TagName=${ldcdom_Entity%% *}
	ldcdom_attribs=${ldcdom_Entity#* }

	#
	# Determines the type of tag, according to the first or last character
	#	of the XML entity
	#

	ldcdom_xTagFirst=$(echo $ldcdom_TagName | awk  '{ string=substr($0, 1, 1); print string; }' )
	ldcdom_xTagLen=${#ldcdom_TagName}
	ldcdom_xTagNoF=$(echo $ldcdom_TagName | awk -v var=$ldcdom_xTagLen '{ string=substr($0, 2, var - 1); print string; }' )

	#
	# The first character is a "!", the tag is a comment
	#

	if [ "${ldcdom_xTagFirst}" = "!" ]
	then
		ldcdom_TagType="COMMENT"
		unset ldcdom_attribs
		unset ldcdom_TagName
		ldcdom_Comment=$(echo "$ldcdom_Entity" | sed -e 's/!-- \(.*\) --/\1/')
	else
		[ "$ldcdom_attribs" = "$ldcdom_TagName" ] && unset ldcdom_attribs

		#
		# The first character is a "/", the tag is a close tag
		#

		if [ "$ldcdom_xTagFirst" = "/" ]
		then
			ldcdom_XPath=$(echo $ldcdom_XPath | sed -e "s/\/$ldcdom_xTagNoF$//")
			ldcdom_TagType="CLOSE"
		elif [ "$ldcdom_xTagFirst" = "?" ]

			then
		
				#
				# The first character is a "?", the tag is an instruction tag
				#

				ldcdom_TagType="INSTRUCTION"
				ldcdom_TagName=$ldcdom_xTagNoF
			else

				#
				# The tag is an open tag
				#

				ldcdom_XPath=$ldcdom_XPath"/"$ldcdom_TagName
				ldcdom_TagType="OPEN"
			fi

		ldcdom_xAttLast=$(echo "$ldcdom_attribs"|awk '$0=$NF' FS=)
		
		if [ "$ldcdom_attribs" != "" ] && [ "${ldcdom_xAttLast}" = "/" ]
		then

			#
			# 	If the last character of the XML entity is a "/" 
			#		the tag is an "openclose" tag
			#

			ldcdom_attribs=${ldcdom_attribs%%?}
			ldcdom_TagType="OPENCLOSE"
		fi

	fi

	if [[ "$ldcdom_attribs" != "" ]] 
	then
		[[ "${ldcdom_TagType}" == "INSTRUCTION" ]] &&
		{
			ldcStrTrim "$ldcdom_attribs" ldcdom_attribs
			ldcdom_attribs=${ldcdom_attribs%?}
		}
		
		ldcdom_attribsParsing=$(echo $ldcdom_attribs | sed -e 's/\s*=\s*/=/g')
	fi

	ldcDomDParseAtt
	return 0
}

# ****************************************************************************
#
#	ldcDomDParse
#
# 	Parameters:
#  		xmlFile = path to the XML file
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDParse()
{
	[[ -z "${1}" ]] && return 1

	local xmlFile="${1}"

	[[ -z "${ldcdom_callback}" ]] && return 2
	
	ldcDomDOpen ${xmlFile} "ldcdom_attArray"
	[[ $? -eq 0 ]] || return 3

	until ${ldcdom_docEOF}
	do
		ldcDomDRead
		eval ${ldcdom_callback}
	done

	ldcDomDClose
	return 0
}

# ****************************************************************************
#
#	ldcDomDCallback
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
function ldcDomDCallback()
{
	ldcdom_callback=${1:-"ldcDomDRead"}
	return 0	
}

# ****************************************************************************
#
#	ldcDomDOpen
#
# 		This function is called once for each file. It initialize the parser
#
#	Parameters:
#		xmlFile = path to the xml file to parse
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDOpen()
{
	xmlFile="${1}"

	ldcdom_ArrayName=${2:-"$ldcdom_ArrayName"}

	ldcDynaNew "ldcdom_attArray" 'A'
	[[ $? -eq 0 ]] || return 1

	ldcdom_docTemp=$(mktemp)
	ldcdom_docEOF=false

	cat $xmlFile > $ldcdom_docTemp

	ldcdom_docPath=""
	
	unset ldcdom_Entity
	unset ldcdom_Content
	unset ldcdom_TagType
	unset ldcdom_TagName
	unset ldcdom_Comment
	unset ldcdom_attribs
	unset ldcdom_attribsParsing
}

# ****************************************************************************
#
#	ldcDomDClose
#
# 		Close the xml DOM file
#
#	Parameters:
#		none
#
#	returns:
#		0 = no error
#
# ****************************************************************************
function ldcDomDClose()
{
	[ -f $ldcdom_docTemp ] && rm -f $ldcdom_docTemp
}

