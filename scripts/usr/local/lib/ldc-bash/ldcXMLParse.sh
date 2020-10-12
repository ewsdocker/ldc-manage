# ******************************************************************************
# ******************************************************************************
#
#   	ldcXMLParse
#
#		Provides access to a subset of XPath commands via xmllint (in libxml2)
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcXMLParse
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/ldc-bash.
#
#   ewsdocker/ldc-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/ldc-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/ldc-bash.  If not, see 
#   <http://www.gnu.org/licenses/>.
#
# *****************************************************************************
#
#			Version 0.0.2 - 06-02-2016.
#					0.1.0 - 01-29-2017.
#					0.1.1 - 02-09-2017.
#                   0.1.2 - 09-05-2018.
#
# ******************************************************************************
# ******************************************************************************
#
#	Dependencies:
#
# ******************************************************************************
# ******************************************************************************

declare -r ldclib_ldcXMLParse="0.1.2"	# version of library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -i ldcxmp_Initialized=0		# true if initialized (first time)

declare    ldcxmp_Path=""
declare    ldcxmp_Query=""
declare    ldcxmp_QueryResult=""

declare -i ldcxmp_Result=0

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	ldcXMLParseReset
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
function ldcXMLParseReset()
{
	set -o pipefail

	ldcxmp_Path=""
	ldcxmp_Query=""
	ldcxmp_QueryResult=""

	return 0
}

# ******************************************************************************
#
#	ldcXMLParseInit
#
#		initialize query vars and set the xml file to query
#
#	parameters:
#		name = internal name of the file
#		file = absolute path to the xml file to query
#		xmllint = (optional) path to the xmllint program
#
#	returns:
#		0 => no error
#		1 => xml file error
#		2 => xmllint error
#
# ******************************************************************************
function ldcXMLParseInit()
{
	local name=${1}
	local file=${2}
	local xmllint=${3}

	ldcxmp_Result=0

	ldcXPathInit ${name} ${file} ${xmllint}
	[[ $? -eq 0 ]] ||
	 {
		ldcxmp_Result=$?
		return 1
	 }

	ldcxmp_Initialized=1
	return 0
}

# ******************************************************************************
#
#	ldcXMLParseToArray
#
#		execute the query and return results as an array of elements
#
#	parameters:
#		query = the xpath query to be executed
#		arrayName = array name to create
#		raw = 0 ==> process query as is, 1 ==> apply current cd before processing
#
#	returns:
#		0 => no error
#		non-zero => error-code returned from XPath or post-process script
#
# ******************************************************************************
function ldcXMLParseToArray()
{
	local query=${1}
	local arrayName=${2}
	local raw=${3:-0}

	ldcxmp_Result=0

	ldcXPathQuery ${query} ${raw}
	[[ $? -eq 0 ]] ||
	 {
		ldcxmp_Result=$?
		return 1
	 }

	local resultArray=( $( echo " ${ldcxp_QueryResult} "  | grep -v "-" | cut -f 2 -d "=" | tr -d "\""  | tr " " "\n" ) )
	[[ $? -eq 0 ]] ||
	 {
		ldcxmp_Result=$?
		return 2
	 }

	ldcDynaNew "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcxmp_Result=$?
		return 3
	 }

	for value in "${resultArray[@]}"
	do
		ldcDynaAdd "${arrayName}" "${value}"
		[[ $? -eq 0 ]] ||
		 {
			ldcxmp_Result=$?
			return 4
		 }
	done

	return 0
}

# ******************************************************************************
#
#	ldcXMLParseToCmnd
#
#		execute the command and return the result
#
#	parameters:
#		query = the xpath query to be executed
#
#	returns:
#		0 => no error
#		non-zero => error-code returned from XPath or post-process script
#
# ******************************************************************************
function ldcXMLParseToCmnd()
{
	local xCommand=${1}

	ldcXPathCommand ${xCommand}
	[[ $? -eq 0 ]] ||
	 {
		ldcxmp_Result=$?
		return 1
	 }

	ldcxmp_CommandResult=${ldcxp_CommandResult}
	return 0
}

