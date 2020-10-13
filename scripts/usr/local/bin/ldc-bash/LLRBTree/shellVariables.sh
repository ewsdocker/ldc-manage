#!/bin/bash

# *********************************************************************************
# *********************************************************************************
#
#   ldcDeclare.sh
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
#			ldcConio
#				ldcConioDebug
#				ldcConioDisplay
#
#			ldcString
#				ldcStrSplit
#
#			xmlParser
#				parse_xml
#
# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
#
#	ldcDeclareSet
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
ldcDeclareSet()
{
    local  svName=$1
    local  svValue=$2

    eval $svName="'$svValue'"
	return $?
}

# *********************************************************************************
#
#	ldcDeclareNs
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
ldcDeclareNs()
{
	local svBuffer="${1} ${2}"
	ldcStrTrim "${svBuffer}" svBuffer

	ldcErrorQWriteX $LINENO "XmlInfo" "${svBuffer}"
}

# *********************************************************************************
#
#	ldcDeclareInt
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
ldcDeclareInt()
{
	svName=${1}
	svContent=${2}

	declare -gi "$svName"

	ldcDeclareSet ${svName} ${svContent}
	if [ $? != 0 ]
	then
    	ldcErrorQWrite $LINENO DeclareError  "Unable to declare ${svName}"
		return 1
	fi

	return 0
}

# *********************************************************************************
#
#	ldcDeclareStr
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
ldcDeclareStr()
{
	svName=${1}
	svContent="${2}"

	ldcErrorQWriteX $LINENO "XmlInfo" "$svName = ${svContent}"

	ldcDeclareSet ${svName} "${svContent}"
	if [ $? != 0 ]
	then
		ldcErrorQWrite $LINENO "XmlError" "Unable to declare ${svName}"
		return 1
	fi

	return 0
}

# *********************************************************************************
#
#	ldcDeclarePwd
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
ldcDeclarePwd()
{
	svName=${1}
	svContent="${2}"

	ldcErrorQWriteX $LINENO "XmlInfo" "$svName = ${svContent}"

	svContent=$( echo -n ${svContent} | base64 )

	ldcDeclareSet ${svName} "${svContent}"
	if [ $? != 0 ]
	then
		ldcErrorQWrite $LINENO "XmlError" "Unable to declare ${svName}"
		return 1
	fi

	return 0
}

# *********************************************************************************
#
#	ldcDeclareAssoc
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
ldcDeclareAssoc()
{
	svName="${1}"

	ldcErrorQWriteX $LINENO "XmlInfo" "$svName"
	declare -gA "$svName"
}

# *********************************************************************************
#
#	ldcDeclareArray
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
ldcDeclareArray()
{
	svName="${1}"
	ldcErrorQWriteX $LINENO "XmlInfo" "$svName"

	declare -ga "${svName}"
}

# *********************************************************************************
#
#	ldcDeclareArrayEl
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
ldcDeclareArrayEl()
{
	svParent="${1}"
	svName="${2}"
	svValue="${3:-0}"

	ldcErrorQWriteX $LINENO "XmlInfo" "$svParent [$svName] = $svValue"
	eval "$svParent[$svName]='${svValue}'"

}

# *********************************************************************************
# *********************************************************************************


