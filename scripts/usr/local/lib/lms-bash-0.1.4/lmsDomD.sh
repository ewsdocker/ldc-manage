# *****************************************************************************
# *****************************************************************************
#
#   lmsDomD.sh
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
#			Version 0.0.1 - 06-28-2016.
#					0.0.2 - 09-06-2016.
#					0.0.3 - 09-15-2016.
#					0.1.0 - 01-17-2017.
#					0.1.1 - 02-10-2017.
#					0.1.2 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r lmslib_lmsDomD="0.1.2"	# version of this library

# *******************************************************
# *******************************************************

declare    lmsdom_ArrayName			# name of the lmsdom_attArray
declare    lmsdom_attribCount		# number of items in the AttributesArray

declare    lmsdom_attribs			# attributes
declare    lmsdom_attribsParsing	# attribute parsing flag

# *******************************************************

declare    lmsdom_TagType			# Type of the current tag. The value can be
									#     "OPEN", "CLOSE", "OPENCLOSE", 
									#     "COMMENT" or "INSTRUCTION"
declare    lmsdom_Entity			# The current XML entity
declare    lmsdom_Content			# Data found after the current XML entity
declare    lmsdom_TagName			# Name of the current tag.  If the current tag is
									#   a close tag, the leading "/" is present in the tag name
declare    lmsdom_Comment			# If the current tag is of type "COMMENT",
									#   the text of the comment
declare    lmsdom_XPath				# Full XPath path of the current tag

# *******************************************************

declare -i lmsdom_docInit=0			# docInit = non-zero if initialization complete

declare    lmsdom_docXMLFile		# the xml file to convert to DOM format in memory

declare    lmsdom_docStackUid		# uid of the processing stack
declare    lmsdom_docLevel			# the name to use for the level stack

declare    lmsdom_docTree=""		# root of the document Tree

declare    lmsdom_docTemp
declare    lmsdom_docPath			# path to the xml file
declare    lmsdom_docEOF			# okay to continue processing

declare    lmsdom_xData
declare    lmsdom_xTagFirst
declare    lmsdom_xTagLen
declare    lmsdom_xTagNoF
declare    lmsdom_xAttLast

declare -a lmsdom_pAttribs=()


# *******************************************************
#
#	lmsDomDParseAtt
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
function lmsDomDParseAtt()
{
	lmsdom_attribCount=0

	lmsStrExplode "${lmsdom_attribs}" " " lmsdom_pAttribs
	[[ ${#lmsdom_pAttribs[@]} -eq 0 ]] && return 1

	lmsDynaUnset "${lmsdom_ArrayName}"
	lmsDynaNew "${lmsdom_ArrayName}" "A"
	[[ $? -eq 0 ]] || return 2

	local attrib
	local name
	local value

	for attrib in "${lmsdom_pAttribs[@]}"
	do
		lmsStrSplit ${attrib} name value
		[[ $? -eq 0 ]] || return 3

		lmsDyna_SetAt "${name}" "${value}"
		[[ $? -eq 0 ]] || return 4
		
		(( lmsdom_attribCount++ ))
	done

	return 0
}

# ****************************************************************************
#
#	lmsDomDGetAtt
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
function lmsDomDGetAtt()
{
	[[ -z "${1}" || -z "${2}" ]] || return 1
	
	exec 3>&1 >/dev/tty

	local name="${1}"
	local value

	name=$(echo $name | tr "-" "_")

	if [[ -n "${lmsdom_attribs}" ]]
	then
		lmsdom_attribsParsing=$( echo $lmsdom_attribs | tr "-" "_" )
	else
		lmsdom_attribsParsing=$lmsdom_attribs
	fi

	eval local echo $lmsdom_attribsParsing

	value=$( eval echo \$$name )

	exec >&3

	lmsDeclareStr ${2} "$value"
	[[ $? -eq 0 ]] || return 1
	
	return 0
}

# ****************************************************************************
#
#	lmsDomDHasAtt
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
function lmsDomDHasAtt()
{
	local name=${1}
	local value

	lmsDomDGetAtt ${name} value
	[[ ${value} -eq 0 ]] || return 1

	return 0
}

# ****************************************************************************
#
#	lmsDomDSetAtt
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
function lmsDomDSetAtt()
{
	local attName=$1
	local attValue="${2}"

	local attName_VAR=$(echo $attName | tr "-" "_")
	local cValue

	lmsDomDGetAtt $attName cValue
	[[ $? -eq 0 ]] || return 1

	lmsdom_attribs=$(echo $lmsdom_attribs | sed -e "s/${attName}=[\"' ]${cValue}[\"' ]/${attName}=\"${attValue}\"/")
 }

# ****************************************************************************
#
#	lmsDomDRead
#
# 		Reads the DOM entity, parses it into variables and calls the
#			callback routine to process the entity
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function lmsDomDRead()
{
	local NR

	#
	# If the type of the last tag processed was "OPENCLOSE",
	#   update the XPath path before searching the next tag
	#

	if [ "$lmsdom_TagType" = "OPENCLOSE" ]
	then
		lmsdom_XPath=$(echo $lmsdom_XPath | sed -e "s/\/$lmsdom_TagName$//")
	fi

	#
	# Read the XML file to find the next tag
	# 	The output is a string containing the XML entity and the following
	# 		content, separate by a ">"
	#

	lmsdom_xData=$(awk 'BEGIN { RS = "<" ; FS = ">" ; OFS=">"; }

	{ printf "" > F }

	NR == 1 { getline ; print $1,$2"x" }
	NR >  2 { printf "<"$0 >> F }' F=${lmsdom_docTemp} ${lmsdom_docTemp})

	if [ ! -s ${lmsdom_docTemp} ]
	then
		lmsdom_docEOF=true
	fi

	unset lmsdom_Entity
	lmsdom_Entity=$(echo $lmsdom_xData | cut -d\> -f1)
	lmsdom_Content=$(printf "$lmsdom_xData" | cut -d\> -f2-)
	lmsdom_Content=${lmsdom_Content%x}

	unset lmsdom_Comment
	lmsdom_TagType="UNKNOW"
	lmsdom_TagName=${lmsdom_Entity%% *}
	lmsdom_attribs=${lmsdom_Entity#* }

	#
	# Determines the type of tag, according to the first or last character
	#	of the XML entity
	#

	lmsdom_xTagFirst=$(echo $lmsdom_TagName | awk  '{ string=substr($0, 1, 1); print string; }' )
	lmsdom_xTagLen=${#lmsdom_TagName}
	lmsdom_xTagNoF=$(echo $lmsdom_TagName | awk -v var=$lmsdom_xTagLen '{ string=substr($0, 2, var - 1); print string; }' )

	#
	# The first character is a "!", the tag is a comment
	#

	if [ "${lmsdom_xTagFirst}" = "!" ]
	then
		lmsdom_TagType="COMMENT"
		unset lmsdom_attribs
		unset lmsdom_TagName
		lmsdom_Comment=$(echo "$lmsdom_Entity" | sed -e 's/!-- \(.*\) --/\1/')
	else
		[ "$lmsdom_attribs" = "$lmsdom_TagName" ] && unset lmsdom_attribs

		#
		# The first character is a "/", the tag is a close tag
		#

		if [ "$lmsdom_xTagFirst" = "/" ]
		then
			lmsdom_XPath=$(echo $lmsdom_XPath | sed -e "s/\/$lmsdom_xTagNoF$//")
			lmsdom_TagType="CLOSE"
		elif [ "$lmsdom_xTagFirst" = "?" ]

			then
		
				#
				# The first character is a "?", the tag is an instruction tag
				#

				lmsdom_TagType="INSTRUCTION"
				lmsdom_TagName=$lmsdom_xTagNoF
			else

				#
				# The tag is an open tag
				#

				lmsdom_XPath=$lmsdom_XPath"/"$lmsdom_TagName
				lmsdom_TagType="OPEN"
			fi

		lmsdom_xAttLast=$(echo "$lmsdom_attribs"|awk '$0=$NF' FS=)
		
		if [ "$lmsdom_attribs" != "" ] && [ "${lmsdom_xAttLast}" = "/" ]
		then

			#
			# 	If the last character of the XML entity is a "/" 
			#		the tag is an "openclose" tag
			#

			lmsdom_attribs=${lmsdom_attribs%%?}
			lmsdom_TagType="OPENCLOSE"
		fi

	fi

	if [[ "$lmsdom_attribs" != "" ]] 
	then
		[[ "${lmsdom_TagType}" == "INSTRUCTION" ]] &&
		{
			lmsStrTrim "$lmsdom_attribs" lmsdom_attribs
			lmsdom_attribs=${lmsdom_attribs%?}
		}
		
		lmsdom_attribsParsing=$(echo $lmsdom_attribs | sed -e 's/\s*=\s*/=/g')
	fi

	lmsDomDParseAtt
	return 0
}

# ****************************************************************************
#
#	lmsDomDParse
#
# 	Parameters:
#  		xmlFile = path to the XML file
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function lmsDomDParse()
{
	[[ -z "${1}" ]] && return 1

	local xmlFile="${1}"

	[[ -z "${lmsdom_callback}" ]] && return 2
	
	lmsDomDOpen ${xmlFile} "lmsdom_attArray"
	[[ $? -eq 0 ]] || return 3

	until ${lmsdom_docEOF}
	do
		lmsDomDRead
		eval ${lmsdom_callback}
	done

	lmsDomDClose
	return 0
}

# ****************************************************************************
#
#	lmsDomDCallback
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
function lmsDomDCallback()
{
	lmsdom_callback=${1:-"lmsDomDRead"}
	return 0	
}

# ****************************************************************************
#
#	lmsDomDOpen
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
function lmsDomDOpen()
{
	xmlFile="${1}"

	lmsdom_ArrayName=${2:-"$lmsdom_ArrayName"}

	lmsDynaNew "lmsdom_attArray" 'A'
	[[ $? -eq 0 ]] || return 1

	lmsdom_docTemp=$(mktemp)
	lmsdom_docEOF=false

	cat $xmlFile > $lmsdom_docTemp

	lmsdom_docPath=""
	
	unset lmsdom_Entity
	unset lmsdom_Content
	unset lmsdom_TagType
	unset lmsdom_TagName
	unset lmsdom_Comment
	unset lmsdom_attribs
	unset lmsdom_attribsParsing
}

# ****************************************************************************
#
#	lmsDomDClose
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
function lmsDomDClose()
{
	[ -f $lmsdom_docTemp ] && rm -f $lmsdom_docTemp
}

