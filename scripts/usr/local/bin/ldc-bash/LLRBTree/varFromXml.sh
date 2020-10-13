#!/bin/bash

# *********************************************************************************
# *********************************************************************************
#
#   varFromXml.sh
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.1.0 - 03-31-2016.
#
# *********************************************************************************
# *********************************************************************************

declare -r ldclib_varFromXml="0.1.0"	# version of library

declare -ar varTypes=( integer string password associative array element )
declare -ar attributeNames=( entity name type parent value ns password )

	# *******************************************************************************************************
	#
	# do not change the order of the following 2 statements
	#
	# *******************************************************************************************************

declare -A varParts=( [name]="" [type]="" [parent]="" [content]="" [password]="" )
declare -ar varKeys=("${!varParts[@]}")

declare xmlAttribute=""
declare xmlValue=""

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
		ldcErrorQWrite $LINENO "XmlError" "Empty attribute array"
		return 5
	fi

	xmlAttribute=""
	xmlValue=""

	local xmlAttributeErrors=0

	attributeArray[0]="entity=\"${attributeArray[0]}\""

	for attrib in "${attributeArray[@]}"
	do
		ldcErrorQWriteX $LINENO "XmlInfo" "attribute: '${attrib}'"

		ldcStrSplit "${attrib}" xmlAttribute xmlValue "="

		ldcErrorQWriteX $LINENO "XmlInfo" "attribute: ${xmlAttribute}, value    : ${xmlValue}"

		case "${xmlAttribute}" in

			"entity")
				ldcErrorQWriteX $LINENO "XmlInfo" "Entity '$xmlValue}'"
				;;

			"name")
				varParts[name]=$xmlValue
				ldcErrorQWriteX $LINENO "XmlInfo" "Name '${varParts[name]}'"
				;;

			"password")
				varParts[name]=$xmlValue
				ldcErrorQWriteX $LINENO "XmlInfo" "Password ${varParts[name]}"
				;;

			"element")
				varParts[name]=$xmlValue
				ldcErrorQWriteX $LINENO "XmlInfo" "Element '${varParts[name]}'"
				;;

			"type")
				varParts[type]=$xmlValue
				ldcErrorQWriteX $LINENO "XmlInfo" "Type '${varParts[type]}'"

				if [[ ${varTypes[@]} =~ ${type} ]]
				then
					continue
				fi
				;;

			"parent")
				varParts[parent]=$xmlValue
				ldcErrorQWriteX $LINENO "XmlInfo" "Parent '${varParts[parent]}'"
				;;

			"value")
				varParts[content]=$xmlValue
				ldcErrorQWriteX $LINENO "XmlInfo" "Value '${varParts[content]}'"
				;;

			"namespace")
				ldcErrorQWriteX $LINENO "XmlInfo" "Namespace '${xmlValue}'"
				;;

			*)
				ldcErrorQWriteX $LINENO "XmlError" "Unknown attribute: '$xmlAttribute', value: '$xmlValue'"
				xmlAttributeErrors+=1
				;;

		esac
	done

	if [ $xmlAttributeErrors != 0 ]
	then
		ldcErrorQWrite $LINENO "XmlError" "${xmlAttributeErrors} attribute errors were detected."
		return 1
	fi

	if [ -z "${varParts[content]}" ]
	then
		varParts[content]="${XML_CONTENT}"
	fi

	if [ ! -z "${varParts[content]}" ]
	then
		ldcStrUnquote "${varParts[content]}" content
	fi

	xmltype="${varParts[type]}"
	case $xmltype in

		"password")
			ldcDeclarePwd "${varParts[name]}" "${varParts[content]}"
			;;

		"string")
			ldcDeclareStr "${varParts[name]}" "${varParts[content]}"
			;;

		"integer")
			ldcDeclareInt "${varParts[name]}" "${varParts[content]}"
			;;

		"element")
			if [[ -z "${varParts[parent]}" || -z "${varParts[name]}" ]]
			then
    			ldcErrorQWrite $LINENO "XmlError" "Unknown XML parent (${varParts[parent]}) and/or name (${varParts[name]})"
			else
				ldcDeclareArrayEl "${varParts[parent]}" "${varParts[name]}" "${varParts[content]}"
			fi
			;;

		"associative")
			ldcDeclareAssoc "${varParts[name]}"
			;;

		"array")
			ldcDeclareArray "${varParts[name]}"
			;;

		"namespace")
			ldcDeclareNs "${varParts[name]}" "${varParts[content]}"

			;;

		*)
    		ldcErrorQWrite $LINENO "XmlError" "Unknown XML Type: '$xmltype'"
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
	ldcErrorQWriteX $LINENO "XmlInfo" "Entity:   ${XML_ENTITY}"
	ldcErrorQWriteX $LINENO "XmlInfo" "Content:  ${XML_CONTENT}"
	ldcErrorQWriteX $LINENO "XmlInfo" "TAG_NAME: ${XML_TAG_NAME}"
	ldcErrorQWriteX $LINENO "XmlInfo" "TAG_TYPE: ${XML_TAG_TYPE}"
	ldcErrorQWriteX $LINENO "XmlInfo" "COMMENT:  ${XML_COMMENT}"
	ldcErrorQWriteX $LINENO "XmlInfo" "XML_PATH: ${XML_PATH}"
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
				ldcErrorQWrite $LINENO "XmlError" "OPEN Parse data entity error"
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
				ldcErrorQWrite $LINENO "XmlError" "OPENCLOSE Parse data entity error"
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
