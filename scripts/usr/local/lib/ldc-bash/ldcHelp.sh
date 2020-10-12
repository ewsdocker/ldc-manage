# ******************************************************************************
# ******************************************************************************
#
#   	ldcHelp.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcHelp
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
#			Version 0.0.1 - 06-09-2016.
#					0.1.0 - 01-09-2017.
#					0.1.1 - 01-29-2017.
#					0.1.2 - 02-08-2017.
#					0.1.3 - 09-06-2018.
#
# ******************************************************************************
# ******************************************************************************

declare -r ldclib_ldcHelp="0.1.3"	# version of library

# ******************************************************************************
#
#	Required global declarations
#
# ******************************************************************************

declare    ldchlp_XmlFile			# path to the xml help file
declare    ldchlp_XmlName			# internal name of the xml help file
declare    ldchlp_Array				# NAME of the help dynamicArray of names

declare -i ldchlp_Count				# count of help items
declare -i ldchlp_Number			# help item number
declare    ldchlp_Message    		# help message
declare    ldchlp_Name				# key into the ErrorCode/ErrorMsgs arrays
declare    ldchlp_QueryResult		# query result buffer (string)

declare    ldchlp_Query				# error code or error name to look up
declare    ldchlp_Buffer			# format buffer
declare    ldchlp_MsgBuffer			# multi-message format buffer
declare    ldchlp_FormatType		# format code
declare -i ldchlp_error				# error result code

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#   ldcHelpQClear
#
#		Clear the result variables
#
#	parameters:
#		none
#
#	returns:
#		0 ==> no error
#
# ******************************************************************************
function ldcHelpQClear()
{
	ldchlp_QueryResult=""
	ldchlp_Number=0
	ldchlp_Name=""
	ldchlp_Message=""
}

# ******************************************************************************
#
#    ldcHelpInit
#
#	Read the help messages from the supplied xml file.
#
#	parameters:
#		helpFileName = help message xml file name
#
#	returns:
#
# ******************************************************************************
function ldcHelpInit()
{
	local helpFile="${1}"

echo "helpFile: $helpFile"

	[[ -z "${helpFile}" ]] && return 1

	ldchlp_XmlFile=${helpFile}

	ldchlp_Array="ldchlp_info"
	ldchlp_error=0

	ldcHelpQClear

echo "loading help file."

	ldcDomCLoad "${helpFile}" "${ldchlp_Array}" 0
	[[ $? -eq 0 ]] ||
	 {
		ldchlp_error=$?
		return 3
	 }

echo "help loaded."

	return 0
}

# ******************************************************************************
#
#	ldcHelpValidName
#
#		Returns 0 if the help entry name is valid, 1 if not
#
#	parameters:
#		HelpEntryName = Entry name
#
#	returns:
#		result = 0 if found
#			   = 1 if not found
#
# ******************************************************************************
function ldcHelpValidName()
{
	[[ -n "${1}" && " ${ldchlp_Array[@]} " =~ "${1}" ]] && return 0
	return 1
}

# ******************************************************************************
#
#	ldcHelpValidInd
#
#		Return 0 if the error number is valid, otherwise return 1
#
#	parameters:
#		Error-Code-Number = error number
#
#	outputs:
#		(integer) result = 0 if valid, 1 if not valid
#
#	returns:
#		result = 0 if found, 1 if not
#
# ******************************************************************************
function ldcHelpValidInd()
{
	[[ -n "${1}" && " ${!ldchlp_Array[@]} " =~ "${1}" ]] && return 0
	return 1
}

# ******************************************************************************
#
#	ldcHelpGetMsg
#
#	Given the help name, return the message
#
#	parameters:
#		help-Code-Name = help name
#
#	returns:
#		result = 0 if no error
#				 1 if error
#
# ******************************************************************************
function ldcHelpGetMsg()
{
	local name="${1}"

	ldchlp_error=0
	ldcXMLParseToCmnd  "string(//ldc/help/options/var[@name=\"${name}\"]/use)"
	[[ $? -eq 0 ]] || 
	 {
		ldchlp_error=$?
		return 1
	 }

	ldchlp_Name=$name
	ldchlp_Message=${ldcxmp_CommandResult}

	return 0
}

# ******************************************************************************
#
#	_ldcHelpToStr
#
#		Get current help message from config. file and format to global buffer
#
#	parameters:
#		command = xpath command to execute
#		indent = number of spaces to indent or zero
#
#	returns:
#		result = 0 if no error
#				 1 if error
#
# ******************************************************************************
function _ldcHelpToStr()
{
	local command="${1}"
	local indent=${2:-0}

	ldcXMLParseToCmnd "${command}"
	[[ $? -eq 0 ]] || return 1

	local result=${ldcxmp_CommandResult}

	[[ ${indent} -gt 0 ]] && printf -v ldchlp_Message "%s%*s " "${ldchlp_Message}" ${indent} 

	printf -v ldchlp_Message "%s%s\n" "${ldchlp_Message}" "${result}"
	return 0
}

# ******************************************************************************
#
#	ldcHelpToStrV
#
#		Return a formatted string to print as the help display
#
#	parameters:
#		helpMessage = location to place the message
#
#	returns:
#		result = 0 if no error
#				 1 ==> missing parameter
#				 2 ==> _ldcHelpToStr error
#				 3 ==> dynaNode error
#
# ******************************************************************************
function ldcHelpToStrV()
{
	[[ -z "${1}" ]] && return 1

	local itName=""
	local fullScriptName=$(basename "${0}" ".sh" )

	ldchlp_error=0
	ldchlp_Message="   ${fullScriptName} "

	while [[ true ]]
	do
		_ldcHelpToStr "string(//ldc/help/labels/label[@name=\"command\"])"
		[[ $? -eq 0 ]] ||
		 {
			ldchlp_error=$?
			return 2
		 }

		printf -v ldchlp_Message "%s\n" "${ldchlp_Message}"

		ldcDynnReset "${ldchlp_Array}"
		[[ $? -eq 0 ]] ||
		 {
			ldchlp_error=$?
			return 3
		 }

		local valid=0
		ldcDynnValid "${ldchlp_Array}" valid

		while [[ ${valid} -eq 1 ]]
		do
			ldcDynnMap "${ldchlp_Array}" itName
			[[ $? -eq 0 ]] ||
			 {
				ldchlp_error=$?
				return 3
			 }
	
			_ldcHelpToStr "string(//ldc/help/options/var[@name=\"${itName}\"]/use)" 6
			[[ $? -eq 0 ]] ||
			 {
				ldchlp_error=$?
				return 2
			 }

			ldcDynnNext "${ldchlp_Array}"
			ldcDynnValid "${ldchlp_Array}" valid
		done

		printf -v ldchlp_Message "%s\n" "${ldchlp_Message}"

		_ldcHelpToStr "string(//ldc/help/labels/label[@name=\"footer\"])" 3
		break

	done

	printf -v ldchlp_Message "%s\n" "${ldchlp_Message}"

	ldcDeclareStr ${1} "${ldchlp_Message}"
	return 0
}

# ******************************************************************************
#
#	ldcHelpToStr
#
#		Return a formatted string to print as the help display
#
#	parameters:
#		none
#
#	outputs:
#		(string) help-Message = formatted help message, 
#									if helpMessage option not provided
#
#	returns:
#		result = 0 if no error
#				 1 if error
#
# ******************************************************************************
function ldcHelpToStr()
{
	ldcHelpToStrV ldchlp
	[[ $? -eq 0 ]] ||
	 {
		ldchlp_error=$?
		echo ""
		return 1
	 }
	
	echo "$ldchlp"
	return 0
}


