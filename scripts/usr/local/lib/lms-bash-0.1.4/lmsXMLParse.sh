# ******************************************************************************
# ******************************************************************************
#
#   	lmsXMLParse
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
# @subpackage lmsXMLParse
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/lms-bash.
#
#   ewsdocker/lms-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/lms-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/lms-bash.  If not, see 
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

declare -r lmslib_lmsXMLParse="0.1.2"	# version of library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -i lmsxmp_Initialized=0		# true if initialized (first time)

declare    lmsxmp_Path=""
declare    lmsxmp_Query=""
declare    lmsxmp_QueryResult=""

declare -i lmsxmp_Result=0

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsXMLParseReset
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
function lmsXMLParseReset()
{
	set -o pipefail

	lmsxmp_Path=""
	lmsxmp_Query=""
	lmsxmp_QueryResult=""

	return 0
}

# ******************************************************************************
#
#	lmsXMLParseInit
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
function lmsXMLParseInit()
{
	local name=${1}
	local file=${2}
	local xmllint=${3}

	lmsxmp_Result=0

	lmsXPathInit ${name} ${file} ${xmllint}
	[[ $? -eq 0 ]] ||
	 {
		lmsxmp_Result=$?
		return 1
	 }

	lmsxmp_Initialized=1
	return 0
}

# ******************************************************************************
#
#	lmsXMLParseToArray
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
function lmsXMLParseToArray()
{
	local query=${1}
	local arrayName=${2}
	local raw=${3:-0}

	lmsxmp_Result=0

	lmsXPathQuery ${query} ${raw}
	[[ $? -eq 0 ]] ||
	 {
		lmsxmp_Result=$?
		return 1
	 }

	local resultArray=( $( echo " ${lmsxp_QueryResult} "  | grep -v "-" | cut -f 2 -d "=" | tr -d "\""  | tr " " "\n" ) )
	[[ $? -eq 0 ]] ||
	 {
		lmsxmp_Result=$?
		return 2
	 }

	lmsDynaNew "${arrayName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsxmp_Result=$?
		return 3
	 }

	for value in "${resultArray[@]}"
	do
		lmsDynaAdd "${arrayName}" "${value}"
		[[ $? -eq 0 ]] ||
		 {
			lmsxmp_Result=$?
			return 4
		 }
	done

	return 0
}

# ******************************************************************************
#
#	lmsXMLParseToCmnd
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
function lmsXMLParseToCmnd()
{
	local xCommand=${1}

	lmsXPathCommand ${xCommand}
	[[ $? -eq 0 ]] ||
	 {
		lmsxmp_Result=$?
		return 1
	 }

	lmsxmp_CommandResult=${lmsxp_CommandResult}
	return 0
}

