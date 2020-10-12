# ******************************************************************************
# ******************************************************************************
#
#   	lmsXPath.sh
#
#		Provides access to a subset of XPath queries via xmllint (in libxml2)
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage XPath
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
#			Version 0.0.1 - 06-01-2016.
#					0.0.2 - 01-09-2017.
#					0.0.3 - 02-09-2017.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_lmsXPath="0.0.3"	# version of XPath library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -A lmsxp_QueryFile=()					# query name lookup table
declare    lmsxp_Selected=""					# selected query name
declare    lmsxp_FileName=""					# name of the xml file to query

declare -i lmsxp_Initialized=false				# true if initialized (first time)

declare    lmsxp_File=""						# name of the xml file to query
declare -i lmsxp_FileExists=0					# true if the file in lmsxp_File exists

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
#	lmsXPathQuery
#
#		execute a query and set the lmsxp_QueryResult value
#
#	parameters:
#		query = query to execute
#		raw = 0 ==> process query as is, 1 ==> apply current cd before processing
#
#	returns:
#		0 => no error
#		1 => query error
#
# ******************************************************************************
function lmsXPathQuery()
{
	[[ -z "${1}" ]] && return 1

	local query=${1}
	local raw=${2:-0}

	lmsxp_Query=${query}
	lmsxp_QueryResult=""
	lmsxp_Result=0

	[[ -n "${lmsxp_Path}" && "${raw}" == "0" ]] &&
	 {
		lmsStrTrim "${lmsxp_Query}" lmsxp_Query
		[[ "${lmsxp_Query:0:1}" != "/" ]] && lmsxp_Query="${lmsxp_Path}/${lmsxp_Query}"
	 }

	lmsxp_QueryResult=$( echo "cat ${lmsxp_Query}" | ${lmsxp_Xmllint} --shell ${lmsxp_FileName}  | grep -v "/ >" )
	[[ $? -eq 0 ]] ||
	 {
		lmsxp_Result=$?
		return 2
	 }

	[[ -z "${lmsxp_QueryResult}" ]] &&
	 {
		lmsxp_Result=$?
		return 3
	 }

	return 0
}

# ******************************************************************************
#
#	lmsXPathCommand
#
#		execute an lmsxp_ath command and set the lmsxp_QueryResult value
#
#	parameters:
#		command = command to execute
#
#	returns:
#		0 => no error
#		1 => Missing command
#		2 => xmllint error, result is in lmsxp_Result
#
# ******************************************************************************
function lmsXPathCommand()
{
	local command=${1}

	[[ -z "${command}" ]] && return 1

	lmsxp_Command=${command}
	lmsxp_CommandResult=""
	lmsxp_Result=0

	lmsxp_CommandResult=$( ${lmsxp_Xmllint} --xpath ${command} ${lmsxp_FileName} )
	[[ $? -eq 0 ]] ||
	 {
		lmsxp_Result=$?
		return 2
	 }

	return 0
}

# ******************************************************************************
#
#	lmsXPathCD
#
#		set the query path
#
#	parameters:
#		path = the path expression to set
#
#	returns:
#		0 => no error
#		1 => query path not set
#
# ******************************************************************************
function lmsXPathCD()
{
	local path="${1}"

	[[ -z "${path}" ]] &&
	 {
		[[ -z "${lmsxp_Path}" ]] && return 1
		path=${lmsxp_Path}
	 }

	lmsxp_Path=${path}
	return 0
}

# ******************************************************************************
#
#	lmsXPathSelect
#
#		select the lmsxp_Path query file
#
#	parameters:
#		xpsName = name of the lmsxp_ath query file to select
#		xpsFile = path to the query file
#
#	returns:
#		0 => no error
#		non-zero => error code
#
# ******************************************************************************
function lmsXPathSelect()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local xpsName=${1}
	local xpsFile=${2}

	[[ " ${!lmsxp_QueryFile[@]} " =~ "${xpsName}" ]] || 
	 {
		[[ -f $xpsFile ]] || return 2
		lmsxp_QueryFile[${xpsName}]=${xpsFile}
	 }

	lmsXPathReset

	lmsxp_FileName=${lmsxp_QueryFile[${xpsName}]}
	lmsxp_Selected=${xpsName}

	return 0
}

# ******************************************************************************
#
#	lmsXPathInit
#
#		initialize query vars and set the xml file to query
#
#	parameters:
#		name = internal name of the xml file
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
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local name="${1}"
	local file="${2}"
	local xmllint=${3:-""}

	lmsxp_Result=0
	lmsxp_Initialized=0

	lmsXPathReset

	lmsXPathSelect ${name} ${file}
	[[ $? -eq 0 ]] || 
	 {
		lmsxp_Result=$?
		return 1
	 }
	
	[[ -n "${xmllint}" ]] &&
	 {
		[[ -f "${xmllint}" ]] || 
		 {
			lmsxp_Result=$?
			return 2
		 }

		lmsxp_Xmllint=${xmllint}
	 }

	lmsxp_Initialized=1
	return 0
}

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

	lmsxp_Path=""
	lmsxp_Query=""
	lmsxp_QueryResult=""

	lmsxp_Selected=""
	lmsxp_FileName=""
}

# ******************************************************************************
#
#	lmsXPathUnset
#
#		unset the requested name if found in the xpQueryFile array
#
#	parameters:
#		unsetName = name of the entry to unset
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function lmsXPathUnset()
{
	unset lmsxp_QueryFile[${1}]
	return 0
}

