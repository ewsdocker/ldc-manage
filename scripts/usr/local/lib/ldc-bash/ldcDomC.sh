# *********************************************************************************
# *********************************************************************************
#
#   ldcDomC.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.4
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage DOMConfig
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
#			Version 0.0.1 - 08-10-2016.
#					0.0.2 - 09-06-2016.
#					0.0.3 - 02-10-2017.
#					0.0.4 - 08-25-2018.
#
# *********************************************************************************
# *********************************************************************************

declare -r  ldclib_ldcDomC="0.0.4"	# version of library

# *********************************************************************************

declare    ldcdcg_stackName=""
declare    ldcdcg_ns=""

declare	-a ldcdcg_tagTypes=( OPEN OPENCLOSE CLOSE )
declare -a ldcdcg_tagNames=( 'declare' 'declarations' 'set' '/declarations' )

declare    ldcdcg_trace=0
declare    ldcdcg_attName=""
declare    ldcdcg_attType=""

declare    ldccfg_xUid=""

# *********************************************************************************
#
#	ldcDomCParseTags
#
#		Check for matching tag names and tags
#
#	parameters:
#		result = location to place the result (0 = no match, 1 = match found)
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcDomCParseTags()
{
	ldcDeclareInt ${1} 0

	[[ "${ldcdcg_tagTypes[@]}" =~ "${ldcdom_TagType}" ]]  ||  return 1
	[[ "${ldcdcg_tagNames[@]}" =~ "${ldcdom_TagName}" ]]  ||  return 2

	[[ "${!ldcdom_attArray[@]}" =~ "name" ]]  ||  return 3
	[[ "${!ldcdom_attArray[@]}" =~ "type" ]]  ||  ldcdom_attArray['type']="string"
	
	ldcDeclareInt ${1} 1
	return 0
}

# *********************************************************************************
#
#	ldcDomCDeclare
#
#		Declare the variable
#
#	parameters:
#		name = variable name to declare
#		type = variable type
#		content = (optional) content to store in the new variable
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcDomCDeclare()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	case "${2}" in
		"integer")
			ldcDeclareInt ${1} "${3}"
			[[ $? -eq 0 ]] || return 2
			;;

		"array")
			ldcDeclareArray ${1} "${3}"
			[[ $? -eq 0 ]] || return 3
			;;

		"associative")
			ldcDeclareAssoc ${1} "${3}"
			[[ $? -eq 0 ]] || return 4
			;;

		"element")
			[[ "${!ldcdom_attArray[@]}" =~ "parent" ]] || return 5
			ldcDeclareArrayEl "${ldcdcg_ns}${ldcdom_attArray['parent']}" ${1} "${3}"
			[[ $? -eq 0 ]] || return 6
			;;

		"password")
			ldcDeclarePwd ${1} "${3}"
			[[ $? -eq 0 ]] || return 7
			;;

		"string")
			ldcDeclareStr ${1} "${3}"
			[[ $? -eq 0 ]] || return 8
			;;

		*)
			ldcDeclareStr ${1} "${3}"
			[[ $? -eq 0 ]] || return 9
			;;
							
	esac
					
	return 0
}

# *********************************************************************************
#
#	ldcDomCParse
#
#		Load declarations from an XML formatted DOM
#
#	parameters:
#		display = 1 ==> display xml elements, 0 = silent
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcDomCParse()
{
	[[ -n "${ldcdom_Content}" ]] && ldcStrTrim "${ldcdom_Content}" ldcdom_Content
	[[ -n "${ldcdom_Comment}" ]] && ldcStrTrim "${ldcdom_Comment}" ldcdom_Comment

	[[ ${ldcdcg_trace} -eq 0 ]] || ldcDmpVarDOM

	ldcdcg_attName=""
	ldcdcg_attType=""

	[[ " ${!ldcdom_attArray[@]} " =~ "name" ]] && ldcdcg_attName=${ldcdom_attArray['name']}
	[[ " ${!ldcdom_attArray[@]} " =~ "type" ]] && ldcdcg_attType=${ldcdom_attArray['type']}

	case ${ldcdom_TagType} in

		"OPEN" | "OPENCLOSE")
			case ${ldcdom_TagName} in
				"declarations")
					[[ -n "${ldcdcg_attName}" ]] &&
					 {
						ldcStackWrite ${ldcdcg_stackName} ${ldcdcg_ns}
						[[ $? -eq 0 ]] || return 2
					 }

					ldcdcg_ns=${ldcdcg_attName}
					;;

				"declare")
					[[ "${ldcdcg_attType}" != "element" && -n "${ldcdcg_ns}" ]] && ldcdcg_attName="${ldcdcg_ns}${ldcdcg_attName}"
					[[ ${ldcdom_TagType} == "OPENCLOSE" ]] &&
					 {
						[[ -z "${ldcdom_Content}" ]] &&
						 {
							ldcdom_Content=0
							[[ " ${!ldcdom_attArray[@]} " =~ "default" ]] && ldcdom_Content=${ldcdom_attArray["default"]}
						 }
					 }

					ldcDomCDeclare $ldcdcg_attName $ldcdcg_attType "${ldcdom_Content}"
					[[ $? -eq 0 ]] || return 3
					;;

				"set")
					ldcDeclareSet ${ldcdcg_attName} "${ldcdom_Content}"
					[[ $? -eq 0 ]] || return 4
					;;
				*)
					;;
			esac
			;;

		"CLOSE")
			case ${ldcdom_TagName} in

				"/declarations")

					local ns=""
					ldcStackRead ${ldcdcg_stackName} ns
					[[ $? -eq 0 ]] || return 5
					
					ldcdcg_ns=${ns}
					;;

				*)
					;;
			esac
			;;
		*)
			;;
	esac

	ldcdom_attArray=()
	return 0
}

# *********************************************************************************
#
#	ldcDomCLoad
#
#		initialize and start the DOM-XML configuration parser
#
#	parameters:
#		fileName = path to the xml file
#		stackName = (optional) internal DOM stack name (default=ldccfgxml)
#		trace = 0 == > no trace (default), 1 ==> trace elements
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcDomCLoad()
{
	ldcdcg_path=${1}
	ldcdcg_stackName=${2:-"ldccfgxml"}
	ldcdcg_trace=${3:-0}

	ldcDomDCallback "ldcDomCParse" 

	ldcStackCreate ${ldcdcg_stackName} ldccfg_xUid 8
	[[ $? -eq 0 ]] || return 1

	ldcdcg_ns=""
	ldcStackWrite ${ldcdcg_stackName} "${ldcdcg_ns}"
	[[ $? -eq 0 ]] || return 2

	ldcDomDParse ${ldcdcg_path}
	[[ $? -eq 0 ]] || return 3

	return 0
}


