# *****************************************************************************
# *****************************************************************************
#
#   	ldcRDomD.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage RDOMDocument
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 06-28-2016.
#					0.0.2 - 02-10-2017.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcRDomD="0.0.2"		# version of this library

# *****************************************************************************

declare    ldcxml_tempFile
declare    ldcxml_Path				# path to the xml file
declare    ldcxml_EOF				# okay to continue processing

declare    ldcxml_Attributes		# attributes
declare    ldcxml_AttributesParsing	# attribute parsing flag

declare    ldcxml_Entity			# The current XML entity
declare    ldcxml_Content			# Data found after the current XML entity
declare    ldcxml_TagName			# Name of the current tag.  If the current tag is
									#   a close tag, the leading "/" is present in the tag name
declare    ldcxml_TagType			# Type of the current tag. The value can be
									#     "OPEN", "CLOSE", "OPENCLOSE", 
									#     "COMMENT" or "INSTRUCTION"
declare    ldcxml_Comment			# If the current tag is of type "COMMENT",
									#   the text of the comment
declare    ldcxml_XPath				# Full XPath path of the current tag

declare -A ldcxml_AttributesArray	#
declare    ldcxml_AttCount			#
declare -a ldcxml_options

# *******************************************************
#
#	ldcRDomParseAtt
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
function ldcRDomParseAtt()
{
	ldcxml_AttCount=0

	if [[ -z "${ldcxml_Attributes}" ]]
	then
		return 0
	fi

	ldcStrExplode "${ldcxml_Attributes}" " " ldcxml_options

	[[ ${#ldcxml_options[@]} -eq 0 ]] &&
		 {
		ldcConioDebug $LINENO "Debug" "ldcStrExplode failed"
		return 1
	 }

	ldcxml_AttributesArray=()

	local name=""
	local value=""

	for attribute in "${ldcxml_options[@]}"
	do
		ldcStrSplit ${attribute} name value
		[[ $? -eq 0 ]] ||
		 {
			ldcConioDebug $LINENO "ParamError" "ldcStrSplit failed."
			return 2
		 }

		ldcxml_AttributesArray[${name}]="${value}"
	done

	ldcxml_AttCount=${#ldcxml_AttributesArray[@]}

	return 0
}

# ****************************************************************************
#
#	ldcRDomGetAtt
#
#		Get the Attributes contents from the attribute name
#
#	Parameters:
#		name = attribute name to get
#
#	Output:
#		value = attribute value
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcRDomGetAtt()
{
	exec 3>&1 >/dev/tty

	local attributeName=$1
	local attributeValue

	attributeName=$(echo $attributeName | tr "-" "_")

	if [[ -n "${ldcxml_Attributes}" ]]
	then
		ldcxml_AttributesParsing=$( echo $ldcxml_Attributes | tr "-" "_" )
	else
		ldcxml_AttributesParsing=$ldcxml_Attributes
	fi

	eval local echo $ldcxml_AttributesParsing

	attributeValue=$( eval echo \$$attributeName )

	exec >&3
	echo "$attributeValue"
	
	return 0
}

# ****************************************************************************
#
#	ldcRDomHasAtt
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
function ldcRDomHasAtt()
{
	local name=${1}
	local value

	value=$( ldcRDomGetAtt ${name} )

	[[ ${value} ]] && return 1

	return 0
}

# ****************************************************************************
#
#	ldcRDomSetAtt
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
function ldcRDomSetAtt()
{
	local attributeName=$1
	local attributeValue="${2}"

	local attributeName_VAR=$(echo $attributeName | tr "-" "_")
	local currentValue="$(ldcRDomGetAtt $attributeName)"

	ldcxml_Attributes=$(echo $ldcxml_Attributes | sed -e "s/${attributeName}=[\"' ]${currentValue}[\"' ]/${attributeName}=\"${attributeValue}\"/")
 }

# ****************************************************************************
#
#	ldcRDomPrint
#
#		Print the Attributes contents to stdout
#
#	Parameters:
#		none
#
#	Returns:
#		0 = no error
#
# ****************************************************************************
function ldcRDomPrint()
{
	if [ "$ldcxml_TagType" = "COMMENT" ]
	then
		printf "<!-- %s --" "$ldcxml_Comment"
	elif [ "$ldcxml_TagType" = "INSTRUCTION" ]
	then
		printf "<?%s" "$ldcxml_TagName"

		if [ -n "$ldcxml_Attributes" ]
		then
			printf " %s" "$ldcxml_Attributes"
		fi
	elif [ "$ldcxml_TagType" = "OPENCLOSE" ]
	then
		printf "<%s" "$ldcxml_TagName"

		if [ -n "$ldcxml_Attributes" ]
		then
			printf " %s" "$ldcxml_Attributes"
		fi

		printf "/"
	elif [ "$ldcxml_TagType" = "CLOSE" ]
	then
		printf "<%s" "$ldcxml_TagName"
	else
		printf "<%s" "$ldcxml_TagName"
		if [ -n "$ldcxml_Attributes" ]
		then
			printf " %s" "$ldcxml_Attributes"
		fi
	fi

	printf ">$ldcxml_Content"
}

# ****************************************************************************
#
#	ldcRDomRead
#
# 		Reads the DOM entity, parses it into variables and calls the
#			callback routine to process the entity
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcRDomRead()
{
	local xmlData
	local xmlTagNameFirst
	local xmlTagNameLength
	local xmlTagNameNoFirst
	local xmlAttributeLast

	local NR

	#
	# If the type of the last tag processed was "OPENCLOSE",
	#   update the XPath path before searching the next tag
	#

	if [ "$ldcxml_TagType" = "OPENCLOSE" ]
	then
		ldcxml_XPath=$(echo $ldcxml_XPath | sed -e "s/\/$ldcxml_TagName$//")
	fi

	#
	# Read the XML file to find the next tag
	# 	The output is a string containing the XML entity and the following
	# 		content, separate by a ">"
	#

	xmlData=$(awk 'BEGIN { RS = "<" ; FS = ">" ; OFS=">"; }

	{ printf "" > F }

	NR == 1 { getline ; print $1,$2"x" }
	NR >  2 { printf "<"$0 >> F }' F=${ldcxml_tempFile} ${ldcxml_tempFile})

	if [ ! -s ${ldcxml_tempFile} ]
	then
		ldcxml_EOF=true
	fi

	ldcxml_Entity=$(echo $xmlData | cut -d\> -f1)
	ldcxml_Content=$(printf "$xmlData" | cut -d\> -f2-)
	ldcxml_Content=${ldcxml_Content%x}

	unset ldcxml_Comment
	ldcxml_TagType="UNKNOW"
	ldcxml_TagName=${ldcxml_Entity%% *}
	ldcxml_Attributes=${ldcxml_Entity#* }

	#
	# Determines the type of tag, according to the first or last character
	#	of the XML entity
	#

	xmlTagNameFirst=$(echo $ldcxml_TagName | awk  '{ string=substr($0, 1, 1); print string; }' )
	xmlTagNameLength=${#ldcxml_TagName}
	xmlTagNameNoFirst=$(echo $ldcxml_TagName | awk -v var=$xmlTagNameLength '{ string=substr($0, 2, var - 1); print string; }' )

	#
	# The first character is a "!", the tag is a comment
	#

	if [ "${xmlTagNameFirst}" = "!" ]
	then
		ldcxml_TagType="COMMENT"
		unset ldcxml_Attributes
		unset ldcxml_TagName
		ldcxml_Comment=$(echo "$ldcxml_Entity" | sed -e 's/!-- \(.*\) --/\1/')
	else
		[ "$ldcxml_Attributes" = "$ldcxml_TagName" ] && unset ldcxml_Attributes

		#
		# The first character is a "/", the tag is a close tag
		#

		if [ "$xmlTagNameFirst" = "/" ]
		then
			ldcxml_XPath=$(echo $ldcxml_XPath | sed -e "s/\/$xmlTagNameNoFirst$//")
			ldcxml_TagType="CLOSE"
		elif [ "$xmlTagNameFirst" = "?" ]
		
			then
		
				#
				# The first character is a "?", the tag is an instruction tag
				#

				ldcxml_TagType="INSTRUCTION"
				ldcxml_TagName=$xmlTagNameNoFirst
			else

				#
				# The tag is an open tag
				#

				ldcxml_XPath=$ldcxml_XPath"/"$ldcxml_TagName
				ldcxml_TagType="OPEN"
			fi

		xmlAttributeLast=$(echo "$ldcxml_Attributes"|awk '$0=$NF' FS=)
		
		if [ "$ldcxml_Attributes" != "" ] && [ "${xmlAttributeLast}" = "/" ]
		then

			#
			# 	If the last character of the XML entity is a "/" 
			#		the tag is an "openclose" tag
			#

			ldcxml_Attributes=${ldcxml_Attributes%%?}
			ldcxml_TagType="OPENCLOSE"
		fi

	fi

	if [ "$ldcxml_Attributes" != "" ]
	then
		ldcxml_AttributesParsing=$(echo $ldcxml_Attributes | sed -e 's/\s*=\s*/=/g')
	fi

	ldcRDomParseAtt

	return 0
}

# ****************************************************************************
#
#	ldcRDomParse
#
# 	Parameters:
#  		xmlFile = path to the XML file
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcRDomParse()
{
	local xmlFile=${1}

	[[ -z "${ldcxml_callback}" ]] &&
	 {
		ldcConioDebug $LINENO "RDomError" "no callback function registered"
		return 1
	 }
	
	ldcRDomOpen ${xmlFile}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebug $LINENO "RDomError" "ldcRDomOpen '${xmlFile}' failed."
		return 2
	 }

	until ${ldcxml_EOF}
	do
		ldcRDomRead
		eval ${ldcxml_callback}
	done

	ldcRDomClose
	
	return 0
}

# ****************************************************************************
#
#	ldcRDomCallback
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
function ldcRDomCallback()
{
	ldcxml_callback=${1}
echo "ldcRDomCallback: $ldcxml_callback"

	[[ -z "${ldcxml_callback}" ]] &&
	 {
		ldcConioDebug $LINENO "RDomError" "Callback function name is missing"
		return 1
	 }

	return 0	
}

# ****************************************************************************
#
#	ldcRDomOpen
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
function ldcRDomOpen()
{
	xmlFile=${1}

	ldcxml_tempFile=$(mktemp)
	cat $xmlFile > $ldcxml_tempFile

	ldcxml_EOF=false
	ldcxml_Path=""

	unset ldcxml_Entity
	unset ldcxml_Content
	unset ldcxml_TagType
	unset ldcxml_TagName
	unset ldcxml_Comment
	unset ldcxml_Attributes
	unset ldcxml_AttributesParsing
}

# ****************************************************************************
#
#	ldcRDomClose
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
function ldcRDomClose()
{
	[ -f $ldcxml_tempFile ] && rm -f $ldcxml_tempFile

	return 0
}

