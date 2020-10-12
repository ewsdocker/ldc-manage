# ******************************************************************************
# ******************************************************************************
#
#   	lmsHelp.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage lmsHelp
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
#			Version 0.0.1 - 06-09-2016.
#					0.1.0 - 01-09-2017.
#					0.1.1 - 01-29-2017.
#					0.1.2 - 02-08-2017.
#					0.1.3 - 09-06-2018.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_lmsHelp="0.1.3"	# version of library

# ******************************************************************************
#
#	Required global declarations
#
# ******************************************************************************

declare    lmshlp_XmlFile			# path to the xml help file
declare    lmshlp_XmlName			# internal name of the xml help file
declare    lmshlp_Array				# NAME of the help dynamicArray of names

declare -i lmshlp_Count				# count of help items
declare -i lmshlp_Number			# help item number
declare    lmshlp_Message    		# help message
declare    lmshlp_Name				# key into the ErrorCode/ErrorMsgs arrays
declare    lmshlp_QueryResult		# query result buffer (string)

declare    lmshlp_Query				# error code or error name to look up
declare    lmshlp_Buffer			# format buffer
declare    lmshlp_MsgBuffer			# multi-message format buffer
declare    lmshlp_FormatType		# format code
declare -i lmshlp_error				# error result code

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#   lmsHelpQClear
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
function lmsHelpQClear()
{
	lmshlp_QueryResult=""
	lmshlp_Number=0
	lmshlp_Name=""
	lmshlp_Message=""
}

# ******************************************************************************
#
#    lmsHelpInit
#
#	Read the help messages from the supplied xml file.
#
#	parameters:
#		helpFileName = help message xml file name
#
#	returns:
#
# ******************************************************************************
function lmsHelpInit()
{
	local helpFile="${1}"

echo "helpFile: $helpFile"

	[[ -z "${helpFile}" ]] && return 1

	lmshlp_XmlFile=${helpFile}

	lmshlp_Array="lmshlp_info"
	lmshlp_error=0

	lmsHelpQClear

echo "loading help file."

	lmsDomCLoad "${helpFile}" "${lmshlp_Array}" 0
	[[ $? -eq 0 ]] ||
	 {
		lmshlp_error=$?
		return 3
	 }

echo "help loaded."

	return 0
}

# ******************************************************************************
#
#	lmsHelpValidName
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
function lmsHelpValidName()
{
	[[ -n "${1}" && " ${lmshlp_Array[@]} " =~ "${1}" ]] && return 0
	return 1
}

# ******************************************************************************
#
#	lmsHelpValidInd
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
function lmsHelpValidInd()
{
	[[ -n "${1}" && " ${!lmshlp_Array[@]} " =~ "${1}" ]] && return 0
	return 1
}

# ******************************************************************************
#
#	lmsHelpGetMsg
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
function lmsHelpGetMsg()
{
	local name="${1}"

	lmshlp_error=0
	lmsXMLParseToCmnd  "string(//lms/help/options/var[@name=\"${name}\"]/use)"
	[[ $? -eq 0 ]] || 
	 {
		lmshlp_error=$?
		return 1
	 }

	lmshlp_Name=$name
	lmshlp_Message=${lmsxmp_CommandResult}

	return 0
}

# ******************************************************************************
#
#	_lmsHelpToStr
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
function _lmsHelpToStr()
{
	local command="${1}"
	local indent=${2:-0}

	lmsXMLParseToCmnd "${command}"
	[[ $? -eq 0 ]] || return 1

	local result=${lmsxmp_CommandResult}

	[[ ${indent} -gt 0 ]] && printf -v lmshlp_Message "%s%*s " "${lmshlp_Message}" ${indent} 

	printf -v lmshlp_Message "%s%s\n" "${lmshlp_Message}" "${result}"
	return 0
}

# ******************************************************************************
#
#	lmsHelpToStrV
#
#		Return a formatted string to print as the help display
#
#	parameters:
#		helpMessage = location to place the message
#
#	returns:
#		result = 0 if no error
#				 1 ==> missing parameter
#				 2 ==> _lmsHelpToStr error
#				 3 ==> dynaNode error
#
# ******************************************************************************
function lmsHelpToStrV()
{
	[[ -z "${1}" ]] && return 1

	local itName=""
	local fullScriptName=$(basename "${0}" ".sh" )

	lmshlp_error=0
	lmshlp_Message="   ${fullScriptName} "

	while [[ true ]]
	do
		_lmsHelpToStr "string(//lms/help/labels/label[@name=\"command\"])"
		[[ $? -eq 0 ]] ||
		 {
			lmshlp_error=$?
			return 2
		 }

		printf -v lmshlp_Message "%s\n" "${lmshlp_Message}"

		lmsDynnReset "${lmshlp_Array}"
		[[ $? -eq 0 ]] ||
		 {
			lmshlp_error=$?
			return 3
		 }

		local valid=0
		lmsDynnValid "${lmshlp_Array}" valid

		while [[ ${valid} -eq 1 ]]
		do
			lmsDynnMap "${lmshlp_Array}" itName
			[[ $? -eq 0 ]] ||
			 {
				lmshlp_error=$?
				return 3
			 }
	
			_lmsHelpToStr "string(//lms/help/options/var[@name=\"${itName}\"]/use)" 6
			[[ $? -eq 0 ]] ||
			 {
				lmshlp_error=$?
				return 2
			 }

			lmsDynnNext "${lmshlp_Array}"
			lmsDynnValid "${lmshlp_Array}" valid
		done

		printf -v lmshlp_Message "%s\n" "${lmshlp_Message}"

		_lmsHelpToStr "string(//lms/help/labels/label[@name=\"footer\"])" 3
		break

	done

	printf -v lmshlp_Message "%s\n" "${lmshlp_Message}"

	lmsDeclareStr ${1} "${lmshlp_Message}"
	return 0
}

# ******************************************************************************
#
#	lmsHelpToStr
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
function lmsHelpToStr()
{
	lmsHelpToStrV lmshlp
	[[ $? -eq 0 ]] ||
	 {
		lmshlp_error=$?
		echo ""
		return 1
	 }
	
	echo "$lmshlp"
	return 0
}


