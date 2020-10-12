#!/bin/sh
# ******************************************************************************
# ******************************************************************************
#
#   lmsXPath.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 06-01-2016.
#					0.0.2 - 06-16-2016.
#
#	Provides access to a subset of XPath queries via xmllint (in libxml2)
#
# ******************************************************************************
# ******************************************************************************
#
#	Dependencies:
#			xmllint (libxml2)
#			errorQueueFunctions
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_XPath="0.0.2"	# version of XPath library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -A lmsxp_QueryFile=()					# query name lookup table
declare    lmsxp_Selected=""					# selected query name
declare    lmsxp_FileName=""					# name of the xml file to query

declare    lmsxp_Xmllint="/usr/bin/xmllint"		# path to xmllint

declare    lmsxp_Path=""						# the currently selected query path
declare    lmsxp_Query=""						# the current (or last executed) query
declare    lmsxp_QueryResult=""					# the result of the last executed query

declare    lmsxp_Result=0						# status returned from xmllint

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsXPathReset
#
#		reset query vars
#
#	parameters:
#		none
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function lmsXPathReset()
{
	set -o pipefail

	lmsxp_Query=""
	lmsxp_QueryResult=""

	lmsxp_Selected=""
	lmsxp_FileName=""
}

# ******************************************************************************
#
#	lmsXPathSelect
#
#		select the xpath query file
#
#	parameters:
#		name = name of the xpath query file to select
#		file = path to the query file
#
#	returns:
#		0 => no error
#		non-zero => error code
#
# ******************************************************************************
function lmsXPathSelect()
{
	local name="${1}"
	local file="${2}"

	lmsXPathReset

	[[ -z "${name}" ]] &&
	 {
		lmsConioDisplay "Missing file name"
		return 1
	 }

	[[ -n "${file}" ]] &&
	 {
		lmsXPathUnset "${name}"

		if [ ! -f $file ]; then
			lmsConioDisplay "xml file '${file}' was not found"
			return 2
		fi

		lmsxp_QueryFile["$name"]="${file}"
	 }

	[[ " ${!lmsxp_QueryFile[@]} " =~ "${name}" ]] ||
	 {
		lmsConioDisplay "XPath file '${name}' was not found in the select index"
		return 3
	 }

	lmsxp_FileName="${lmsxp_QueryFile["$name"]}"
	lmsxp_Selected="${name}"

	return 0
}

# ******************************************************************************
#
#	lmsXPathUnset
#
#		Deselect the xpath query file
#
#	parameters:
#		name = name of the xpath query file to select
#
#	returns:
#		0 => no error
#		non-zero => error code
#
# ******************************************************************************
function lmsXPathUnset()
{
	local name="${1}"
	
	[[ " ${lmsxp_QueryFile[@]} " =~ "${name}" ]] &&
	 {
		unset lmsxp_QueryFile["$name"]
	 }

	lmsxp_FileName=""
}

# ******************************************************************************
#
#	lmsXPathInit
#
#		initialize query vars and set the xml file to query
#
#	parameters:
#		name = name of the file to use
#		file = absolute path to the xml file to query
#		xmllint = (optional) path to the xmllint program
#
#	returns:
#		0 => no error
#		1 => xml file error
#		2 => xmllint error
#
# ******************************************************************************
function lmsXPathInit()
{
	local name=${1}
	local file=${2}
	local xmllint=${3}

	lmsXPathSelect "${name}" "${file}"	
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "lmsXPathSelect failed - name: ${name}, file: ${file}"
		return 1
	}

	if [[ "$xmllint" != "$lmsxp_Xmllint" ]] ; then
		if [ ! -f $xmllint ]; then
			lmsConioDisplay  "xmllint '${xmllint}' was not found"
			return 2
		fi

		lmsxp_Xmllint=$xmllint
	fi

	return 0
}

# ******************************************************************************
#
#	lmsXPathQuery
#
#		execute a query and set the lmsxp_QueryResult value
#
#	parameters:
#		query = query to execute
#		raw = 0 ==> process query as is, 1 ==> apply current cd before processing
#
#	outputs:
#		result = query result
#
#	returns:
#		0 => no error
#		1 => query error
#
# ******************************************************************************
function lmsXPathQuery()
{
	local query="${1}"

	[[ -z "${query}" ]] &&
	 {
		lmsErrorQWrite $LINENO "XPathError" "Empty XPath query"
		echo "NO XPath query provided"
		return 1
	 }

	lmsxp_Query=${query}
	lmsxp_QueryResult=""
	lmsxp_Result=0

	lmsxp_QueryResult=$( echo "cat ${lmsxp_Query}" | ${lmsxp_Xmllint} --shell "${lmsxp_FileName}"  | grep -v "/ >" )
	#result=$( echo "cat query" | "${lmsxp_Xmllint}" --shell ${lmsxp_FileName}  | grep -v "/ >" )

echo "xpQueryResult = $lmsxp_QueryResult"
return 1

	[[ $? -eq 0 ]] ||
	 {
		lmsxp_Result=$?
		lmsErrorQWriteX $LINENO "XPathInfo" "XPath query failed: $?"
		echo "XPath query failed: $?"
		return $?
	 }

	[[ -z "${lmsxp_QueryResult}" ]] &&
	 {
		lmsErrorQWriteX $LINENO "XPathInfo"  "XPath query returned empty result"
		echo "XPath query returned empty result"
		return 1
	 }

	echo "${lmsxp_QueryResult}"
	return 0
}

# ******************************************************************************
#
#	lmsXPathCommand
#
#		execute an xpath command and set the lmsxp_QueryResult value
#
#	parameters:
#		command = command to execute
#
#	Outputs
#		result = command result
#
#	returns:
#		0 => no error
#		1 => query error
#
# ******************************************************************************
function lmsXPathCommand()
{
	local lmsxp_Command="${1}"
	local lmsxp_CommandResult=""

	[[ -z "${lmsxp_Command}" ]] &&
	 {
		lmsErrorQWrite $LINENO "XPathError" "XPath query not set"
		echo "Not set"
		return 1
	 }

	lmsxp_Result=0

	lmsxp_CommandResult=$( $lmsxp_Xmllint --xpath ${lmsxp_Command} ${lmsxp_FileName} )
	echo "${lmsxp_CommandResult}"
exit 1
	return 0
}

# ******************************************************************************
# ******************************************************************************
#
#				END
#
# ******************************************************************************
# ******************************************************************************


