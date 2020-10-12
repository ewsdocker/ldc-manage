# *****************************************************************************
# *****************************************************************************
#
#   	lmsRDomD.sh
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

declare -r lmslib_lmsRDomD="0.0.2"		# version of this library

# *****************************************************************************

declare    lmsxml_tempFile
declare    lmsxml_Path				# path to the xml file
declare    lmsxml_EOF				# okay to continue processing

declare    lmsxml_Attributes		# attributes
declare    lmsxml_AttributesParsing	# attribute parsing flag

declare    lmsxml_Entity			# The current XML entity
declare    lmsxml_Content			# Data found after the current XML entity
declare    lmsxml_TagName			# Name of the current tag.  If the current tag is
									#   a close tag, the leading "/" is present in the tag name
declare    lmsxml_TagType			# Type of the current tag. The value can be
									#     "OPEN", "CLOSE", "OPENCLOSE", 
									#     "COMMENT" or "INSTRUCTION"
declare    lmsxml_Comment			# If the current tag is of type "COMMENT",
									#   the text of the comment
declare    lmsxml_XPath				# Full XPath path of the current tag

declare -A lmsxml_AttributesArray	#
declare    lmsxml_AttCount			#
declare -a lmsxml_options

# *******************************************************
#
#	lmsRDomParseAtt
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
function lmsRDomParseAtt()
{
	lmsxml_AttCount=0

	if [[ -z "${lmsxml_Attributes}" ]]
	then
		return 0
	fi

	lmsStrExplode "${lmsxml_Attributes}" " " lmsxml_options

	[[ ${#lmsxml_options[@]} -eq 0 ]] &&
		 {
		lmsConioDebug $LINENO "Debug" "lmsStrExplode failed"
		return 1
	 }

	lmsxml_AttributesArray=()

	local name=""
	local value=""

	for attribute in "${lmsxml_options[@]}"
	do
		lmsStrSplit ${attribute} name value
		[[ $? -eq 0 ]] ||
		 {
			lmsConioDebug $LINENO "ParamError" "lmsStrSplit failed."
			return 2
		 }

		lmsxml_AttributesArray[${name}]="${value}"
	done

	lmsxml_AttCount=${#lmsxml_AttributesArray[@]}

	return 0
}

# ****************************************************************************
#
#	lmsRDomGetAtt
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
function lmsRDomGetAtt()
{
	exec 3>&1 >/dev/tty

	local attributeName=$1
	local attributeValue

	attributeName=$(echo $attributeName | tr "-" "_")

	if [[ -n "${lmsxml_Attributes}" ]]
	then
		lmsxml_AttributesParsing=$( echo $lmsxml_Attributes | tr "-" "_" )
	else
		lmsxml_AttributesParsing=$lmsxml_Attributes
	fi

	eval local echo $lmsxml_AttributesParsing

	attributeValue=$( eval echo \$$attributeName )

	exec >&3
	echo "$attributeValue"
	
	return 0
}

# ****************************************************************************
#
#	lmsRDomHasAtt
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
function lmsRDomHasAtt()
{
	local name=${1}
	local value

	value=$( lmsRDomGetAtt ${name} )

	[[ ${value} ]] && return 1

	return 0
}

# ****************************************************************************
#
#	lmsRDomSetAtt
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
function lmsRDomSetAtt()
{
	local attributeName=$1
	local attributeValue="${2}"

	local attributeName_VAR=$(echo $attributeName | tr "-" "_")
	local currentValue="$(lmsRDomGetAtt $attributeName)"

	lmsxml_Attributes=$(echo $lmsxml_Attributes | sed -e "s/${attributeName}=[\"' ]${currentValue}[\"' ]/${attributeName}=\"${attributeValue}\"/")
 }

# ****************************************************************************
#
#	lmsRDomPrint
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
function lmsRDomPrint()
{
	if [ "$lmsxml_TagType" = "COMMENT" ]
	then
		printf "<!-- %s --" "$lmsxml_Comment"
	elif [ "$lmsxml_TagType" = "INSTRUCTION" ]
	then
		printf "<?%s" "$lmsxml_TagName"

		if [ -n "$lmsxml_Attributes" ]
		then
			printf " %s" "$lmsxml_Attributes"
		fi
	elif [ "$lmsxml_TagType" = "OPENCLOSE" ]
	then
		printf "<%s" "$lmsxml_TagName"

		if [ -n "$lmsxml_Attributes" ]
		then
			printf " %s" "$lmsxml_Attributes"
		fi

		printf "/"
	elif [ "$lmsxml_TagType" = "CLOSE" ]
	then
		printf "<%s" "$lmsxml_TagName"
	else
		printf "<%s" "$lmsxml_TagName"
		if [ -n "$lmsxml_Attributes" ]
		then
			printf " %s" "$lmsxml_Attributes"
		fi
	fi

	printf ">$lmsxml_Content"
}

# ****************************************************************************
#
#	lmsRDomRead
#
# 		Reads the DOM entity, parses it into variables and calls the
#			callback routine to process the entity
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function lmsRDomRead()
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

	if [ "$lmsxml_TagType" = "OPENCLOSE" ]
	then
		lmsxml_XPath=$(echo $lmsxml_XPath | sed -e "s/\/$lmsxml_TagName$//")
	fi

	#
	# Read the XML file to find the next tag
	# 	The output is a string containing the XML entity and the following
	# 		content, separate by a ">"
	#

	xmlData=$(awk 'BEGIN { RS = "<" ; FS = ">" ; OFS=">"; }

	{ printf "" > F }

	NR == 1 { getline ; print $1,$2"x" }
	NR >  2 { printf "<"$0 >> F }' F=${lmsxml_tempFile} ${lmsxml_tempFile})

	if [ ! -s ${lmsxml_tempFile} ]
	then
		lmsxml_EOF=true
	fi

	lmsxml_Entity=$(echo $xmlData | cut -d\> -f1)
	lmsxml_Content=$(printf "$xmlData" | cut -d\> -f2-)
	lmsxml_Content=${lmsxml_Content%x}

	unset lmsxml_Comment
	lmsxml_TagType="UNKNOW"
	lmsxml_TagName=${lmsxml_Entity%% *}
	lmsxml_Attributes=${lmsxml_Entity#* }

	#
	# Determines the type of tag, according to the first or last character
	#	of the XML entity
	#

	xmlTagNameFirst=$(echo $lmsxml_TagName | awk  '{ string=substr($0, 1, 1); print string; }' )
	xmlTagNameLength=${#lmsxml_TagName}
	xmlTagNameNoFirst=$(echo $lmsxml_TagName | awk -v var=$xmlTagNameLength '{ string=substr($0, 2, var - 1); print string; }' )

	#
	# The first character is a "!", the tag is a comment
	#

	if [ "${xmlTagNameFirst}" = "!" ]
	then
		lmsxml_TagType="COMMENT"
		unset lmsxml_Attributes
		unset lmsxml_TagName
		lmsxml_Comment=$(echo "$lmsxml_Entity" | sed -e 's/!-- \(.*\) --/\1/')
	else
		[ "$lmsxml_Attributes" = "$lmsxml_TagName" ] && unset lmsxml_Attributes

		#
		# The first character is a "/", the tag is a close tag
		#

		if [ "$xmlTagNameFirst" = "/" ]
		then
			lmsxml_XPath=$(echo $lmsxml_XPath | sed -e "s/\/$xmlTagNameNoFirst$//")
			lmsxml_TagType="CLOSE"
		elif [ "$xmlTagNameFirst" = "?" ]
		
			then
		
				#
				# The first character is a "?", the tag is an instruction tag
				#

				lmsxml_TagType="INSTRUCTION"
				lmsxml_TagName=$xmlTagNameNoFirst
			else

				#
				# The tag is an open tag
				#

				lmsxml_XPath=$lmsxml_XPath"/"$lmsxml_TagName
				lmsxml_TagType="OPEN"
			fi

		xmlAttributeLast=$(echo "$lmsxml_Attributes"|awk '$0=$NF' FS=)
		
		if [ "$lmsxml_Attributes" != "" ] && [ "${xmlAttributeLast}" = "/" ]
		then

			#
			# 	If the last character of the XML entity is a "/" 
			#		the tag is an "openclose" tag
			#

			lmsxml_Attributes=${lmsxml_Attributes%%?}
			lmsxml_TagType="OPENCLOSE"
		fi

	fi

	if [ "$lmsxml_Attributes" != "" ]
	then
		lmsxml_AttributesParsing=$(echo $lmsxml_Attributes | sed -e 's/\s*=\s*/=/g')
	fi

	lmsRDomParseAtt

	return 0
}

# ****************************************************************************
#
#	lmsRDomParse
#
# 	Parameters:
#  		xmlFile = path to the XML file
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function lmsRDomParse()
{
	local xmlFile=${1}

	[[ -z "${lmsxml_callback}" ]] &&
	 {
		lmsConioDebug $LINENO "RDomError" "no callback function registered"
		return 1
	 }
	
	lmsRDomOpen ${xmlFile}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDebug $LINENO "RDomError" "lmsRDomOpen '${xmlFile}' failed."
		return 2
	 }

	until ${lmsxml_EOF}
	do
		lmsRDomRead
		eval ${lmsxml_callback}
	done

	lmsRDomClose
	
	return 0
}

# ****************************************************************************
#
#	lmsRDomCallback
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
function lmsRDomCallback()
{
	lmsxml_callback=${1}
echo "lmsRDomCallback: $lmsxml_callback"

	[[ -z "${lmsxml_callback}" ]] &&
	 {
		lmsConioDebug $LINENO "RDomError" "Callback function name is missing"
		return 1
	 }

	return 0	
}

# ****************************************************************************
#
#	lmsRDomOpen
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
function lmsRDomOpen()
{
	xmlFile=${1}

	lmsxml_tempFile=$(mktemp)
	cat $xmlFile > $lmsxml_tempFile

	lmsxml_EOF=false
	lmsxml_Path=""

	unset lmsxml_Entity
	unset lmsxml_Content
	unset lmsxml_TagType
	unset lmsxml_TagName
	unset lmsxml_Comment
	unset lmsxml_Attributes
	unset lmsxml_AttributesParsing
}

# ****************************************************************************
#
#	lmsRDomClose
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
function lmsRDomClose()
{
	[ -f $lmsxml_tempFile ] && rm -f $lmsxml_tempFile

	return 0
}

