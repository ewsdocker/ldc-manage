#!/bin/bash

# *********************************************************************************
# *********************************************************************************
#
#   lmsDeclare.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 02-29-2016.
#			        1.1 - 03-31-2016.
#
# *********************************************************************************
# ***********************************************************************************************************
#
#	dependencies
#
#		the following external functions are required
#
#			lmsConio
#				lmsConioDebug
#				lmsConioDisplay
#
#			lmsString
#				lmsStrSplit
#
#			xmlParser
#				parse_xml
#
# *********************************************************************************
# *********************************************************************************

declare -r lmslib_shellVariables="0.0.1"	# version of library

declare xmlAttribute=""
declare xmlValue=""

declare -ar varTypes=( integer string password associative array element )
declare -ar attributeNames=( entity name type parent value ns password )

	# *******************************************************************************************************
	#
	# do not change the order of the following 2 statements
	#
	# *******************************************************************************************************

declare -A varParts=( [name]="" [type]="" [parent]="" [content]="" [password]="" )
declare -ar varKeys=("${!varParts[@]}")

# ***********************************************************************************************************
#
#	dumpNameTable
#
#		dump the name table for debug purposes
#
#	attributes:
#
#	returns:
#
# *********************************************************************************
dumpNameTable()
{
	eval declare -p |
	{
		local -i lineNumber=0

		while IFS= read -r line
		do
    		printf "% 5u : %s\n" $lineNumber "$line"
			let lineNumber+=1
		done
	}
}

# *********************************************************************************
#
#	lmsDeclareSet
#
#		creates a global variable and sets it's value
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
setGlobal()
{
    local  varName=$1
    local  varValue=$2

    eval $varName="'$varValue'"
	return $?
}

# *********************************************************************************
#
#	lmsDeclareNs
#
#		creates a global variable namespace
#
#	parameters:
#		name = name of global variable
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
lmsDeclareNs()
{
	local tempBuffer="${1} ${2}"
	lmsStrTrim "${tempBuffer}" tempBuffer

	lmsErrorQWriteX $LINENO "XmlInfo" "${tempBuffer}"
}

# *********************************************************************************
#
#	lmsDeclareInt
#
#		creates a global integer variable and sets it's value
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
lmsDeclareInt()
{
	name=${1}
	content=${2}

	declare -gi "$name"

	setGlobal ${name} ${content}
	if [ $? != 0 ]
	then
    	lmsErrorQWrite $LINENO DeclareError  "Unable to declare ${name}"
		return 1
	fi

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
lmsDeclareStr()
{
	name=${1}
	content="${2}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$name = ${content}"

	setGlobal ${name} "${content}"
	if [ $? != 0 ]
	then
		lmsErrorQWrite $LINENO "XmlError" "Unable to declare ${name}"
		return 1
	fi

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
lmsDeclarePwd()
{
	name=${1}
	content="${2}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$name = ${content}"

	content=$( echo -n ${xmlValue} | base64 )

	setGlobal ${name} "${content}"
	if [ $? != 0 ]
	then
		lmsErrorQWrite $LINENO "XmlError" "Unable to declare ${name}"
		return 1
	fi

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
#		value = value to set
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
lmsDeclareAssoc()
{
	local name="${1}"
	lmsErrorQWriteX $LINENO "XmlInfo" "$name"
	declare -gA "$name"
}

# *********************************************************************************
#
#	lmsDeclareArray
#
#		creates a global array variable
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
lmsDeclareArray()
{
	name="${1}"
	lmsErrorQWriteX $LINENO "XmlInfo" "$name"

	declare -ga "${name}"
}

# *********************************************************************************
#
#	declareElement
#
#		Adds an element to a global array variable
#
#	parameters:
#		parent = global array variable
#		name = element name or index number
#		value = value to set
#
#	returns:
#		result = 0 if set ok
#			   = 1 if set error
#
# *********************************************************************************
declareElement()
{
	parent="${1}"
	name="${2}"
	value="${3}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$parent [$name] = $value"

#	eval $parent["$name"]="${value}"

	eval "$parent[${name}]='${value}'"
}

# *********************************************************************************
#
#	parseDataEntity
#
#		load data definitions from the provided xml fields
#
#	parameters:
#		entity = xml data entity string
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
parseDataEntity()
{
	local xmlEntity="${1}"

	local attrib
	local -a attributeArray

	varParts[name]=""
	varParts[type]=""
	varParts[parent]=""
	varParts[content]=""
	varParts[password]=""

	attributeArray=( ${xmlEntity// / } )  		# split entity at blank into array

	if [ ${#attributeArray[@]} == 0 ]
	then
		lmsErrorQWrite $LINENO "XmlError" "Empty attribute array"
		return 5
	fi

	xmlAttribute=""
	xmlValue=""

	local xmlAttributeErrors=0

	attributeArray[0]="entity=\"${attributeArray[0]}\""

	for attrib in "${attributeArray[@]}"
	do
		lmsErrorQWriteX $LINENO "XmlInfo" "attribute: '${attrib}'"

		lmsStrSplit "${attrib}" xmlAttribute xmlValue "="

		lmsErrorQWriteX $LINENO "XmlInfo" "attribute: ${xmlAttribute}, value    : ${xmlValue}"

		case "${xmlAttribute}" in

			"entity")
				;;

			"name")
				varParts[name]=$xmlValue
				lmsErrorQWriteX $LINENO "XmlInfo" "Name '${varParts[name]}'"
				;;

			"password")
				varParts[name]=$xmlValue
				lmsErrorQWriteX $LINENO "XmlInfo" "Password ${varParts[name]}"
				;;

			"element")
				varParts[name]=$xmlValue
				lmsErrorQWriteX $LINENO "XmlInfo" "Element '${varParts[name]}'"
				;;

			"type")
				varParts[type]=$xmlValue
				lmsErrorQWriteX $LINENO "XmlInfo" "Type '${varParts[type]}'"

				if [[ ${varTypes[@]} =~ ${type} ]]
				then
					continue
				fi
				;;

			"parent")
				varParts[parent]=$xmlValue
				lmsErrorQWriteX $LINENO "XmlInfo" "Parent '${varParts[parent]}'"
				;;

			"value")
				varParts[content]=$xmlValue
				lmsErrorQWriteX $LINENO "XmlInfo" "Value '${varParts[content]}'"
				;;

			"namespace")
				;;

			*)
				lmsErrorQWriteX $LINENO "XmlError" "Unknown attribute: '$attribute'"
				;;

		esac
	done

	if [ $xmlAttributeErrors != 0 ]
	then
		lmsErrorQWrite $LINENO "XmlError" "${xmlAttributeErrors} attribute errors were detected. *********"
		return 1
	fi

	if [ -z "${varParts[content]}" ]
	then
		varParts[content]="${XML_CONTENT}"
	fi

	if [ ! -z "${varParts[content]}" ]
	then
		lmsStrUnquote "${varParts[content]}" content
	fi

	xmltype="${varParts[type]}"
	case $xmltype in

		"password")
			lmsDeclarePwd "${varParts[name]}" "${varParts[content]}"
			;;

		"string")
			lmsDeclareStr "${varParts[name]}" "${varParts[content]}"
			;;

		"integer")
			lmsDeclareInt "${varParts[name]}" "${varParts[content]}"
			;;

		"element")
			if [[ -z "${varParts[parent]}" || -z "${varParts[name]}" ]]
			then
    			lmsErrorQWrite $LINENO "XmlError" "Unknown XML parent (${varParts[parent]}) and/or name (${varParts[name]})"
			else
				declareElement "${varParts[parent]}" "${varParts[name]}" "${varParts[content]}"
			fi

			;;

		"associative")
			lmsDeclareAssoc "${varParts[name]}"
			;;

		"array")
			lmsDeclareArray "${varParts[name]}"
			;;

		"namespace")
			lmsDeclareNs "${varParts[name]}" "${varParts[content]}"

			;;

		*)
    		lmsErrorQWrite $LINENO "XmlError" "Unknown XML Type: '$xmltype'"
			;;

	esac

	return 0
}

# *********************************************************************************
#
#	displayXmlEntities
#
# *********************************************************************************
displayXmlEntities()
{
	lmsErrorQWriteX $LINENO "XmlInfo" "Entity:   ${XML_ENTITY}"
	lmsErrorQWriteX $LINENO "XmlInfo" "Content:  ${XML_CONTENT}"
	lmsErrorQWriteX $LINENO "XmlInfo" "TAG_NAME: ${XML_TAG_NAME}"
	lmsErrorQWriteX $LINENO "XmlInfo" "TAG_TYPE: ${XML_TAG_TYPE}"
	lmsErrorQWriteX $LINENO "XmlInfo" "COMMENT:  ${XML_COMMENT}"
	lmsErrorQWriteX $LINENO "XmlInfo" "XML_PATH: ${XML_PATH}"
}

# *********************************************************************************
#
#	loadVariables
#
#		load data definitions from the provided xml fields
#
#	parameters:
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
loadVariables()
{
	case $XML_TAG_TYPE in

		"INSTRUCTION")
			;;

		"OPEN")
			displayXmlEntities
			parseDataEntity "${XML_ENTITY}"
			if [ $? -ne 0 ]
			then
				lmsErrorQWrite $LINENO "XmlError" "OPEN Parse data entity error"
				return $?
			fi
			;;

		"CLOSE")
			;;

		"OPENCLOSE")
			displayXmlEntities
			parseDataEntity "${XML_ENTITY}"
			if [ $? -ne 0 ]
			then
				lmsErrorQWrite $LINENO "XmlError" "OPENCLOSE Parse data entity error"
				return $?
			fi
			;;

		"COMMENT")
			;;

		*)
			;;
	esac

	return 0
}

# *********************************************************************************
#
#	loadXmlData
#
#		load data definitions from the provided xml file
#
#	parameters:
#		xmlFile = path to the xml file
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
loadXmlData()
{
	local xmlFile=$1
	parse_xml loadVariables ${xmlFile}
}

# *********************************************************************************
# *********************************************************************************

