#!/bin/bash

# *********************************************************************************
# *********************************************************************************
#
#   namespace.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 03-05-2016.
#
# *********************************************************************************

declare -r lmslib_namespace="0.0.1"	# version of library

declare -A nsVarTable=()			# maps namespace name to a uid

declare nsVarCurrent=""				# the current namespace name
declare nxVarNumber=0				# the current namespace uid

declare -i nsVarLength=6			# default namespace name length (chars)

# ***********************************************************************************************************
#
#	namespaceVersion
#
#		return the version
#
#	attributes:
#
#	returns:
#
# *********************************************************************************
namespaceVersion()
{
	eval $1="'${namespace}"
	return 0
}

# ***********************************************************************************************************
#
#	namespaceDumpTable
#
#		dump the namespace table for debug purposes
#
#	attributes:
#
#	returns:
#
# *********************************************************************************
namespaceDumpTable()
{
	local nsName

	lmsConioDisplay "namespace table:"
	for nsName in "${!nsVarTable[@]}"
	do
		lmsConioDisplay "    ${nsName} = ${nsVarTable[$nsName]}"
	done
}

# ***********************************************************************************************************
#
#	namespaceLength
#
#		get/set the namespace length
#
#	parameters:
#		varName = place to store the result
#		nsLen = the namespace length
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
namespaceLength()
{
	local varName=$1

	if [ -n "$2" ]
	then
		nsVarLength=${2}
	fi

    lmsErrorQWrite $LINENO "NSLength" "Namespace length = ${nsVarLength}"
	eval $varName="'${nsVarLength}'"

	return 0
}

# ***********************************************************************************************************
#
#	namespaceGet
#
#		get the namespace name
#
#	parameters:
#		var = place to store the result
#		ns = the namespace name to search for
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
namespaceGet()
{
	local varName=$1
	local ns="${2}"
	local nsKey

	if [ -z "${nsVarTable[$ns]}" ]
	then
    	lmsErrorQWrite $LINENO "NSGet" "Namespace '${ns}' was NOT found"
		return 1
	fi

	eval $varName="'${nsVarTable[$ns]}'"

	return 0
}

# ***********************************************************************************************************
#
#	namespaceSet
#
#		set the namespace name
#
#	attributes:
#		var = the generated namespace uid
#		name = the namespace name to set
#		length = the number of characters to return in the namespace uid
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *********************************************************************************
namespaceSet()
{
	local varName=$1
	local name="${2}"
	local luid
	local -i length

	[ -n "$3" ] && length=${3} || length=$nsVarLength

	while true
	do
		namespaceGet luid ${name}
		if [ $? -eq 0 ]
		then
			break
		fi

		lmsUIdUnique luid $length
		if [ $? -eq 0 ]
		then
			nsVarTable["${name}"]="$luid"
			break
		fi

    	lmsErrorQWrite $LINENO "NSGenUid" "Unable to generate a new uid"
		return $?
	done

	eval $varName="$luid"
	return 0
}

# *********************************************************************************
# *********************************************************************************
