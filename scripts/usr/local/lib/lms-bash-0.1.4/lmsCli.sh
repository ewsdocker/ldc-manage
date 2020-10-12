# *****************************************************************************
# *****************************************************************************
#
#   lmsCli.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.0
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage lmsCliParam
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
#			Version 0.0.1 - 02-24-2016.
#					0.0.2 - 07-01-2016.
#					0.0.3 - 08-19-2016.
#					0.0.4 - 09-07-2016.
#					0.1.0 - 01-24-2017.
#					0.1.1 - 02-12-2017.
#					0.1.2 - 02-23-2017.
#					0.2.0 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    lmslib_lmsCli="0.2.0"				# library version number

# *****************************************************************************

declare -a lmscli_ParamBuffer=( "$@" )			# cli parameter array buffer
declare    lmscli_ParamList=""					# cli parameter list (string)
declare    lmscli_ParamPointer=0				# cli parameter buffer index

declare -a lmscli_cmndsValid=()					# array of valid commands for this object

declare    lmscli_cmnds="lmscli_commands"		# commands
declare    lmscli_cmndNum=0						# command stack index of the current command
declare    lmscli_command=""					# cli command
declare    lmscli_cmndValid=0					#

declare -a lmscli_parsed=()						#
declare -a lmscli_exploded=()					#

declare -A lmscli_shellParam=()					# provided by config file
declare -A lmscli_InputParam=()					# input parameters
declare -a lmscli_InputErrors=()				# input parameter error names

declare -i lmscli_cmndErrors=0					# cli command error count
declare -i lmscli_paramErrors=0					# cli parameter error count
declare -i lmscli_Errors=0						# number of cli errors detected

# **************************************************************************
#
#	lmsCliCmndValid
#
#	  Returns 0 if the command is valid, 1 if not
#
#	parameters:
#		cmnd = command
#
#	returns:
#		result = 0 if found, 1 if not found
#
# **************************************************************************
function lmsCliCmndValid()
{
	local lcmnd=${1:-""}

	lmscli_cmndValid=0

	[[ ${#lmscli_cmndsValid[@]} -eq 0  ||  -z "${lcmnd}" ]] && return 1
 	[[ "${lmscli_cmndsValid[@]}" =~ "${lcmnd}" ]] && 
 	 {
 		lmscli_cmndValid=1
 		return 0
 	 }
 
	return 2
}

# **************************************************************************
#
#	lmsCliCmndNew
#
#		create a new command entry and node
#
#	parameters:
#		pCmnd = command
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# **************************************************************************
function lmsCliCmndNew()
{
	local pCmnd=${1:-""}

	local lresult=1

    while true ; do
		[[ -z "${pCmnd}" ]] && break

		(( lresult++ ))
		lmscli_command="${pCmnd}"

		lmsCliCmndValid "${lmscli_command}"
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		lmsStackSize ${lmscli_cmnds} lmscli_cmndNum
		[[ $? -eq 0 ]] || break

		(( lresult++ ))
		lmsClinName "${lmscli_command}" ${lmscli_cmndNum} lmsclin_node

		lmsUtilVarExists ${lmsclin_node}
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		lmsDynaNew ${lmsclin_node} "A"
		[[ ? -eq 0 ]] || break

		(( lresult++ ))

		lmsStackWrite ${lmscli_cmnds} ${lmscli_command}
		[[ $? -eq 0 ]] || break
		
		lresult=0
		break
	done

	return $lresult
}

# **************************************************************************
#
#	lmsCliValid
#
#	Returns 0 if the parameter name is valid, 1 if not
#
#	parameters:
#		cliParameterName = parameter name
#
#	returns:
#		0 = found, 
#		1 = no valid parameters exist
#		2 = requested parameter is invalid
#
# **************************************************************************
function lmsCliValid()
{
	local pName=${1:-""}

	[[ -z "${pName}" ]] && return 1

	[[ ${#lmscli_shellParam[@]} -gt 0  &&  "${!lmscli_shellParam[@]}" =~ "${pName}" ]] && return 0
	return 2
}

# **************************************************************************
#
#	lmsCliLookup
#
#		Lookup the parameter and set the option name
#
#	parameters:
#		cliParameterName = parameter name
#		OptionName = location to place the option name
#
#	returns:
#		0 = found, 
#		1 = requested parameter is invalid
#
# **************************************************************************
function lmsCliLookup()
{
	local cpName=${1:-""}
	local optName=${2:-""}

	local lresult=1

	while true ; do
		[[ -z "${cpName}"  ||  -z "${optName}" ]] && break
	
		local parameter="${cpName}"

		(( lresult++ ))

		lmsCliValid "${cpName}"
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		lmsDeclareStr ${optName} "${lmscli_shellParam[$cpName]}"
		[[ $? -eq 0 ]] || break
		
		lresult=0
		break
	done

	return $lresult
}

# **************************************************************************
#
#	lmsCliAdd
#
#		Add input parameter name and (optional) value
#
#	parameters:
#		pName = parameter name
#		pValue = (optional) parameter value
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# **************************************************************************
function lmsCliAdd()
{
	local pName="${1}"
	local pValue="${2}"

	[[ -z "${pName}" ]] && return 1

	lmsDeclareArrayEl "lmscli_InputParam" "${pName}" "${pValue}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# **************************************************************************
#
#	lmsCliCheck
#
#		check input parameter name and value
#
#	parameters:
#		pName = parameter name
#		pValue = parameter value
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# **************************************************************************
function lmsCliCheck()
{
	local pName="${1}"
	local pValue="${2}"

	[[ -z "${pName}" ]] && return 1

	lmsCliValid "${pName}"
	[[ $? -eq 0 ]] &&
	 {
		lmsCliAdd "${pName}" "${pValue}"
		return 0
	 }

	lmscli_InputErrors[${#lmscli_InputErrors[@]}]="${pName}"

	((lmscli_ParamErrors++ ))
	(( lmscli_Errors++ ))

	return 2
}

# **************************************************************************
#
#	lmsCliSplit
#
#		Splits the parameter string into name and value
#
#	parameters:
#		parameter = parameter string
#
#	returns:
#		0 = parameter is valid
#		non-zero = error code
#
# **************************************************************************
function lmsCliSplit()
{
	local lParam=${1:-""}

	while true ; do
		[[ -z "${lParam}" ]] && break

		local paramName
		local paramValue

		lmsStrSplit "${lParam}" paramName paramValue
		[[ $? -eq 0 ]] || break

		if [ -z "${paramValue}" ]
		then
			lmsCliCmndNew "${paramName}"
		else
			lmsCliCheck "${paramName}" "$paramValue"
			[[ $? -eq 0 ]] || break
		fi

		return 0
	done

	return 1
}

# **************************************************************************
#
#	lmsCliParse
#
#		parse the cli parameters in global lmscli_ParamBuffer array
#			and store results in lmscli_shellParam, lmscli_command,
#		    lmscli_cmndsValid
#
#	parameters:
#		none
#
#	returns:
#		Result = 0 if no error,
#			   = non-zero => error code
#
# **************************************************************************
function lmsCliParse()
{
	[[ ${#lmscli_ParamBuffer} -eq 0 ]] && return 0

	lmscli_ParamList="${lmscli_ParamBuffer[@]}"

	lmscli_InputErrors=()
	lmscli_InputParam=()

	lmscli_paramErrors=0
	lmscli_cmndErrors=0
	lmscli_Errors=0

	local pString

	for pString in "${lmscli_ParamBuffer[@]}"
	do
		lmsCliSplit "${pString}"
		[[ $? -eq 0 ]] || break
	done

	return 0
}

# **************************************************************************
#
#	lmsCliApply
#
#		Apply the pending cliInputParameters
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# **************************************************************************
function lmsCliApply()
{
	[[ ${#lmscli_InputParam[@]} -eq 0 ]] && return 0

	local iName
	local iOption
	local iValue

	for iName in "${!lmscli_InputParam[@]}"
	do
		iValue="${lmscli_InputParam[$iName]}"

		lmsCliLookup $iName iOption
		[[ $? -eq 0 ]] || return 1
		
		iOption="lmscli_${iOption}"

		lmsDeclareSet "${iOption}" "${iValue}"
		[[ $? -eq 0 ]] || return 2
	done

	return 0
}

