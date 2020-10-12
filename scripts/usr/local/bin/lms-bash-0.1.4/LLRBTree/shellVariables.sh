#!/bin/bash

# *********************************************************************************
# *********************************************************************************
#
#   lmsDeclare.sh
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
lmsDeclareSet()
{
    local  svName=$1
    local  svValue=$2

    eval $svName="'$svValue'"
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
	local svBuffer="${1} ${2}"
	lmsStrTrim "${svBuffer}" svBuffer

	lmsErrorQWriteX $LINENO "XmlInfo" "${svBuffer}"
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
	svName=${1}
	svContent=${2}

	declare -gi "$svName"

	lmsDeclareSet ${svName} ${svContent}
	if [ $? != 0 ]
	then
    	lmsErrorQWrite $LINENO DeclareError  "Unable to declare ${svName}"
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
	svName=${1}
	svContent="${2}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$svName = ${svContent}"

	lmsDeclareSet ${svName} "${svContent}"
	if [ $? != 0 ]
	then
		lmsErrorQWrite $LINENO "XmlError" "Unable to declare ${svName}"
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
	svName=${1}
	svContent="${2}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$svName = ${svContent}"

	svContent=$( echo -n ${svContent} | base64 )

	lmsDeclareSet ${svName} "${svContent}"
	if [ $? != 0 ]
	then
		lmsErrorQWrite $LINENO "XmlError" "Unable to declare ${svName}"
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
	svName="${1}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$svName"
	declare -gA "$svName"
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
	svName="${1}"
	lmsErrorQWriteX $LINENO "XmlInfo" "$svName"

	declare -ga "${svName}"
}

# *********************************************************************************
#
#	lmsDeclareArrayEl
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
lmsDeclareArrayEl()
{
	svParent="${1}"
	svName="${2}"
	svValue="${3:-0}"

	lmsErrorQWriteX $LINENO "XmlInfo" "$svParent [$svName] = $svValue"
	eval "$svParent[$svName]='${svValue}'"

}

# *********************************************************************************
# *********************************************************************************


