# *****************************************************************************
# *****************************************************************************
#
#   ldcCli.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.0
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcCliParam
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

declare    ldclib_ldcCli="0.2.0"				# library version number

# *****************************************************************************

declare -a ldccli_ParamBuffer=( "$@" )			# cli parameter array buffer
declare    ldccli_ParamList=""					# cli parameter list (string)
declare    ldccli_ParamPointer=0				# cli parameter buffer index

declare -a ldccli_cmndsValid=()					# array of valid commands for this object

declare    ldccli_cmnds="ldccli_commands"		# commands
declare    ldccli_cmndNum=0						# command stack index of the current command
declare    ldccli_command=""					# cli command
declare    ldccli_cmndValid=0					#

declare -a ldccli_parsed=()						#
declare -a ldccli_exploded=()					#

declare -A ldccli_shellParam=()					# provided by config file
declare -A ldccli_InputParam=()					# input parameters
declare -a ldccli_InputErrors=()				# input parameter error names

declare -i ldccli_cmndErrors=0					# cli command error count
declare -i ldccli_paramErrors=0					# cli parameter error count
declare -i ldccli_Errors=0						# number of cli errors detected

# **************************************************************************
#
#	ldcCliCmndValid
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
function ldcCliCmndValid()
{
	local lcmnd=${1:-""}

	ldccli_cmndValid=0

	[[ ${#ldccli_cmndsValid[@]} -eq 0  ||  -z "${lcmnd}" ]] && return 1
 	[[ "${ldccli_cmndsValid[@]}" =~ "${lcmnd}" ]] && 
 	 {
 		ldccli_cmndValid=1
 		return 0
 	 }
 
	return 2
}

# **************************************************************************
#
#	ldcCliCmndNew
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
function ldcCliCmndNew()
{
	local pCmnd=${1:-""}

	local lresult=1

    while true ; do
		[[ -z "${pCmnd}" ]] && break

		(( lresult++ ))
		ldccli_command="${pCmnd}"

		ldcCliCmndValid "${ldccli_command}"
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		ldcStackSize ${ldccli_cmnds} ldccli_cmndNum
		[[ $? -eq 0 ]] || break

		(( lresult++ ))
		ldcClinName "${ldccli_command}" ${ldccli_cmndNum} ldcclin_node

		ldcUtilVarExists ${ldcclin_node}
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		ldcDynaNew ${ldcclin_node} "A"
		[[ ? -eq 0 ]] || break

		(( lresult++ ))

		ldcStackWrite ${ldccli_cmnds} ${ldccli_command}
		[[ $? -eq 0 ]] || break
		
		lresult=0
		break
	done

	return $lresult
}

# **************************************************************************
#
#	ldcCliValid
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
function ldcCliValid()
{
	local pName=${1:-""}

	[[ -z "${pName}" ]] && return 1

	[[ ${#ldccli_shellParam[@]} -gt 0  &&  "${!ldccli_shellParam[@]}" =~ "${pName}" ]] && return 0
	return 2
}

# **************************************************************************
#
#	ldcCliLookup
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
function ldcCliLookup()
{
	local cpName=${1:-""}
	local optName=${2:-""}

	local lresult=1

	while true ; do
		[[ -z "${cpName}"  ||  -z "${optName}" ]] && break
	
		local parameter="${cpName}"

		(( lresult++ ))

		ldcCliValid "${cpName}"
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		ldcDeclareStr ${optName} "${ldccli_shellParam[$cpName]}"
		[[ $? -eq 0 ]] || break
		
		lresult=0
		break
	done

	return $lresult
}

# **************************************************************************
#
#	ldcCliAdd
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
function ldcCliAdd()
{
	local pName="${1}"
	local pValue="${2}"

	[[ -z "${pName}" ]] && return 1

	ldcDeclareArrayEl "ldccli_InputParam" "${pName}" "${pValue}"
	[[ $? -eq 0 ]] || return 2

	return 0
}

# **************************************************************************
#
#	ldcCliCheck
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
function ldcCliCheck()
{
	local pName="${1}"
	local pValue="${2}"

	[[ -z "${pName}" ]] && return 1

	ldcCliValid "${pName}"
	[[ $? -eq 0 ]] &&
	 {
		ldcCliAdd "${pName}" "${pValue}"
		return 0
	 }

	ldccli_InputErrors[${#ldccli_InputErrors[@]}]="${pName}"

	((ldccli_ParamErrors++ ))
	(( ldccli_Errors++ ))

	return 2
}

# **************************************************************************
#
#	ldcCliSplit
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
function ldcCliSplit()
{
	local lParam=${1:-""}

	while true ; do
		[[ -z "${lParam}" ]] && break

		local paramName
		local paramValue

		ldcStrSplit "${lParam}" paramName paramValue
		[[ $? -eq 0 ]] || break

		if [ -z "${paramValue}" ]
		then
			ldcCliCmndNew "${paramName}"
		else
			ldcCliCheck "${paramName}" "$paramValue"
			[[ $? -eq 0 ]] || break
		fi

		return 0
	done

	return 1
}

# **************************************************************************
#
#	ldcCliParse
#
#		parse the cli parameters in global ldccli_ParamBuffer array
#			and store results in ldccli_shellParam, ldccli_command,
#		    ldccli_cmndsValid
#
#	parameters:
#		none
#
#	returns:
#		Result = 0 if no error,
#			   = non-zero => error code
#
# **************************************************************************
function ldcCliParse()
{
	[[ ${#ldccli_ParamBuffer} -eq 0 ]] && return 0

	ldccli_ParamList="${ldccli_ParamBuffer[@]}"

	ldccli_InputErrors=()
	ldccli_InputParam=()

	ldccli_paramErrors=0
	ldccli_cmndErrors=0
	ldccli_Errors=0

	local pString

	for pString in "${ldccli_ParamBuffer[@]}"
	do
		ldcCliSplit "${pString}"
		[[ $? -eq 0 ]] || break
	done

	return 0
}

# **************************************************************************
#
#	ldcCliApply
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
function ldcCliApply()
{
	[[ ${#ldccli_InputParam[@]} -eq 0 ]] && return 0

	local iName
	local iOption
	local iValue

	for iName in "${!ldccli_InputParam[@]}"
	do
		iValue="${ldccli_InputParam[$iName]}"

		ldcCliLookup $iName iOption
		[[ $? -eq 0 ]] || return 1
		
		iOption="ldccli_${iOption}"

		ldcDeclareSet "${iOption}" "${iValue}"
		[[ $? -eq 0 ]] || return 2
	done

	return 0
}

