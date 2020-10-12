# ******************************************************************************
# ******************************************************************************
#
#   	ldcXPath.sh
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

declare -r ldclib_ldcXPath="0.0.3"	# version of XPath library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -A ldcxp_QueryFile=()					# query name lookup table
declare    ldcxp_Selected=""					# selected query name
declare    ldcxp_FileName=""					# name of the xml file to query

declare -i ldcxp_Initialized=false				# true if initialized (first time)

declare    ldcxp_File=""						# name of the xml file to query
declare -i ldcxp_FileExists=0					# true if the file in ldcxp_File exists

declare    ldcxp_Xmllint="/usr/bin/xmllint"		# path to xmllint

declare    ldcxp_Path=""						# the currently selected query path
declare    ldcxp_Query=""						# the current (or last executed) query
declare    ldcxp_QueryResult=""					# the result of the last executed query

declare    ldcxp_Result=0						# status returned from xmllint

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	ldcXPathQuery
#
#		execute a query and set the ldcxp_QueryResult value
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
function ldcXPathQuery()
{
	[[ -z "${1}" ]] && return 1

	local query=${1}
	local raw=${2:-0}

	ldcxp_Query=${query}
	ldcxp_QueryResult=""
	ldcxp_Result=0

	[[ -n "${ldcxp_Path}" && "${raw}" == "0" ]] &&
	 {
		ldcStrTrim "${ldcxp_Query}" ldcxp_Query
		[[ "${ldcxp_Query:0:1}" != "/" ]] && ldcxp_Query="${ldcxp_Path}/${ldcxp_Query}"
	 }

	ldcxp_QueryResult=$( echo "cat ${ldcxp_Query}" | ${ldcxp_Xmllint} --shell ${ldcxp_FileName}  | grep -v "/ >" )
	[[ $? -eq 0 ]] ||
	 {
		ldcxp_Result=$?
		return 2
	 }

	[[ -z "${ldcxp_QueryResult}" ]] &&
	 {
		ldcxp_Result=$?
		return 3
	 }

	return 0
}

# ******************************************************************************
#
#	ldcXPathCommand
#
#		execute an ldcxp_ath command and set the ldcxp_QueryResult value
#
#	parameters:
#		command = command to execute
#
#	returns:
#		0 => no error
#		1 => Missing command
#		2 => xmllint error, result is in ldcxp_Result
#
# ******************************************************************************
function ldcXPathCommand()
{
	local command=${1}

	[[ -z "${command}" ]] && return 1

	ldcxp_Command=${command}
	ldcxp_CommandResult=""
	ldcxp_Result=0

	ldcxp_CommandResult=$( ${ldcxp_Xmllint} --xpath ${command} ${ldcxp_FileName} )
	[[ $? -eq 0 ]] ||
	 {
		ldcxp_Result=$?
		return 2
	 }

	return 0
}

# ******************************************************************************
#
#	ldcXPathCD
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
function ldcXPathCD()
{
	local path="${1}"

	[[ -z "${path}" ]] &&
	 {
		[[ -z "${ldcxp_Path}" ]] && return 1
		path=${ldcxp_Path}
	 }

	ldcxp_Path=${path}
	return 0
}

# ******************************************************************************
#
#	ldcXPathSelect
#
#		select the ldcxp_Path query file
#
#	parameters:
#		xpsName = name of the ldcxp_ath query file to select
#		xpsFile = path to the query file
#
#	returns:
#		0 => no error
#		non-zero => error code
#
# ******************************************************************************
function ldcXPathSelect()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local xpsName=${1}
	local xpsFile=${2}

	[[ " ${!ldcxp_QueryFile[@]} " =~ "${xpsName}" ]] || 
	 {
		[[ -f $xpsFile ]] || return 2
		ldcxp_QueryFile[${xpsName}]=${xpsFile}
	 }

	ldcXPathReset

	ldcxp_FileName=${ldcxp_QueryFile[${xpsName}]}
	ldcxp_Selected=${xpsName}

	return 0
}

# ******************************************************************************
#
#	ldcXPathInit
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
function ldcXPathInit()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	local name="${1}"
	local file="${2}"
	local xmllint=${3:-""}

	ldcxp_Result=0
	ldcxp_Initialized=0

	ldcXPathReset

	ldcXPathSelect ${name} ${file}
	[[ $? -eq 0 ]] || 
	 {
		ldcxp_Result=$?
		return 1
	 }
	
	[[ -n "${xmllint}" ]] &&
	 {
		[[ -f "${xmllint}" ]] || 
		 {
			ldcxp_Result=$?
			return 2
		 }

		ldcxp_Xmllint=${xmllint}
	 }

	ldcxp_Initialized=1
	return 0
}

# ******************************************************************************
#
#	ldcXPathReset
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
function ldcXPathReset()
{
	set -o pipefail

	ldcxp_Path=""
	ldcxp_Query=""
	ldcxp_QueryResult=""

	ldcxp_Selected=""
	ldcxp_FileName=""
}

# ******************************************************************************
#
#	ldcXPathUnset
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
function ldcXPathUnset()
{
	unset ldcxp_QueryFile[${1}]
	return 0
}

