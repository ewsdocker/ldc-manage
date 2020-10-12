#!/bin/bash

# *********************************************************************************
# *********************************************************************************
#
#   namespaceExt.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 03-08-2016.
#
# *********************************************************************************
# *********************************************************************************

declare -r lmslib_namespaceExt="0.0.1"	# version of library

# *********************************************************************************
#
#	These vars are used to parse new namespaces out prior to commiting to them
#
# *********************************************************************************
declare -a nsxVarNsNames		# new namespace name heirarchy in an array
declare -a nsxVarNsUids			# new namespace uid  heirarchy in an array

declare -i nsxVarNsAbsolute		# 0 = relative (to current) namespace, 1 = absolute

# *********************************************************************************
#
#	These vars are used to access the current namespace
#
# *********************************************************************************

declare nsxVarNs				# current namespace name
declare	nsxVarUid				# current namespace path

declare -a nsxVarNames			# namespace name heirarchy in an array
declare -a nsxVarUids			# namespace uid  heirarchy in an array

# ***********************************************************************************************************
#
#	nsxVersion
#
#		return the version
#
#	attributes:
#
#	returns:
#
# *********************************************************************************
nsxVersion()
{
	eval $1="'${namespaceExt}'"
	return 0
}

# ***********************************************************************************************************
#
#	nsxInitialize
#
#		initialize namespaceExt
#
#	attributes:
#
#	returns:
#
# *********************************************************************************
nsxInitialize()
{
	nsxVarNsNames=()
	nsxVarNsUids=()

	nsxCurrentNamespace=""
	nsxCurrentUid=""

	nsxInitialized=1
}

# ***********************************************************************************************************
#
#	nsxOpenStack
#
#		create/open the extended namespace stack
#
#	parameters:
#		name = (optional) stack name, default = "nsxVarStack"
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
nsxOpenStack()
{
	lmsStackCreate nsxStack
	if [ $? -ne 0 ]
	then
		lmsErrorQWrite $LINENO "NsxStackError" "Unable to create/open stack"
		return 1
	fi

	return 0
}

# ***********************************************************************************************************
#
#	nsxParseNamespace
#
#		parse the namespace into nsxVarNsNames and nsxVarNsUids
#
#	NOTE: changes the nsxNamespace variables dynamically - if an error happens,
#		  the variables most likely will be in an unknown state
#
#	parameters:
#		nsString = the string to parse
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
nsxParseNamespace()
{
	local nsString
	local -a nsElements

	local nsList

	lmsStrTrim " ${1} " nsString
	if [ -z $nsString ]
	then
		lmsErrorQWrite $LINENO "NsxParse" "Namespace string is missing or empty"
		return 1
	fi

	[[ ${nsString:0:1} -eq "_" ]] && nsxVarNsAbsolute=1 || nsxVarNsAbsolute=0

	nsList=$(echo ${nsString} | tr "_" " ")
	nsElements=( " ${nsString} " )

	if [ ${#nsElements[@]} -eq 0 ]
	then
		lmsErrorQWrite $LINENO "NsxParse" "Namespace contains no elements"
		return 1
	fi

	unset nsxVarNsUids
	unset nsxVarNsNames

	for nsElement in ${nsElements[@]}
	do
		namespaceSet element "${nsElement}"
		if [ $? -ne 0 ]
		then
			lmsErrorQWrite $LINENO "NsxParse" "Unable to create/open namespace ${nsElement}"
			return 1
		fi

		nsxVarNsUids=element
	done

	lmsStrTrim nsxCurrentNamespace "_${nsNamespaceNames[@]}"
	nsxCurrentNamespace=$( echo ${nsxCurrentNamespace} | tr " " "_")

	lmsStrTrim nsxCurrentUid "_${nsNamespaceUids[@]}"
	nsxCurrentUid=$( echo ${nsxCurrentUid} | tr " " "_")

	return 0
}


# *********************************************************************************
# *********************************************************************************

# *********************************************************************************
# *********************************************************************************

# ***********************************************************************************************************
#
#	nsxGet
#
#		get the namespaceExt name
#
#	parameters:
#		var = place to store the result
#		ns = the namespaceExt name to search for
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
nsxGet()
{
	local varName=$1
	local ns="${2}"
	local nsKey

	if [ -z "${nsVarTable[$ns]}" ]
	then
		lmsErrorQWrite $LINENO "NsxGet" "Namespace '${ns}' was NOT found"
		return 1
	fi

	eval $varName="'${nsVarTable[$ns]}'"
	return 0
}

# ***********************************************************************************************************
#
#	nsxSet
#
#		set the namespaceExt name
#
#	attributes:
#		var = the generated namespaceExt uid
#		name = the namespaceExt name to set
#		length = the number of characters to return in the namespaceExt uid
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *********************************************************************************
nsxSet()
{
	local varName=$1
	local name="${2}"
	local luid
	local -i nsxLength=${3:-$nsVarLength}

	while true
	do
		nsxGet luid ${name}
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

		lmsErrorQWrite $LINENO "NsxSet" "Unable to generate a new uid"
		return $?
	done

	eval $varName="$luid"
	return 0
}

# *********************************************************************************
# *********************************************************************************

