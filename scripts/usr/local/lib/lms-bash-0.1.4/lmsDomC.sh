# *********************************************************************************
# *********************************************************************************
#
#   lmsDomC.sh
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
#			Version 0.0.1 - 08-10-2016.
#					0.0.2 - 09-06-2016.
#					0.0.3 - 02-10-2017.
#					0.0.4 - 08-25-2018.
#
# *********************************************************************************
# *********************************************************************************

declare -r  lmslib_lmsDomC="0.0.4"	# version of library

# *********************************************************************************

declare    lmsdcg_stackName=""
declare    lmsdcg_ns=""

declare	-a lmsdcg_tagTypes=( OPEN OPENCLOSE CLOSE )
declare -a lmsdcg_tagNames=( 'declare' 'declarations' 'set' '/declarations' )

declare    lmsdcg_trace=0
declare    lmsdcg_attName=""
declare    lmsdcg_attType=""

declare    lmscfg_xUid=""

# *********************************************************************************
#
#	lmsDomCParseTags
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
function lmsDomCParseTags()
{
	lmsDeclareInt ${1} 0

	[[ "${lmsdcg_tagTypes[@]}" =~ "${lmsdom_TagType}" ]]  ||  return 1
	[[ "${lmsdcg_tagNames[@]}" =~ "${lmsdom_TagName}" ]]  ||  return 2

	[[ "${!lmsdom_attArray[@]}" =~ "name" ]]  ||  return 3
	[[ "${!lmsdom_attArray[@]}" =~ "type" ]]  ||  lmsdom_attArray['type']="string"
	
	lmsDeclareInt ${1} 1
	return 0
}

# *********************************************************************************
#
#	lmsDomCDeclare
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
function lmsDomCDeclare()
{
	[[ -z "${1}" || -z "${2}" ]] && return 1

	case "${2}" in
		"integer")
			lmsDeclareInt ${1} "${3}"
			[[ $? -eq 0 ]] || return 2
			;;

		"array")
			lmsDeclareArray ${1} "${3}"
			[[ $? -eq 0 ]] || return 3
			;;

		"associative")
			lmsDeclareAssoc ${1} "${3}"
			[[ $? -eq 0 ]] || return 4
			;;

		"element")
			[[ "${!lmsdom_attArray[@]}" =~ "parent" ]] || return 5
			lmsDeclareArrayEl "${lmsdcg_ns}${lmsdom_attArray['parent']}" ${1} "${3}"
			[[ $? -eq 0 ]] || return 6
			;;

		"password")
			lmsDeclarePwd ${1} "${3}"
			[[ $? -eq 0 ]] || return 7
			;;

		"string")
			lmsDeclareStr ${1} "${3}"
			[[ $? -eq 0 ]] || return 8
			;;

		*)
			lmsDeclareStr ${1} "${3}"
			[[ $? -eq 0 ]] || return 9
			;;
							
	esac
					
	return 0
}

# *********************************************************************************
#
#	lmsDomCParse
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
function lmsDomCParse()
{
	[[ -n "${lmsdom_Content}" ]] && lmsStrTrim "${lmsdom_Content}" lmsdom_Content
	[[ -n "${lmsdom_Comment}" ]] && lmsStrTrim "${lmsdom_Comment}" lmsdom_Comment

	[[ ${lmsdcg_trace} -eq 0 ]] || lmsDmpVarDOM

	lmsdcg_attName=""
	lmsdcg_attType=""

	[[ " ${!lmsdom_attArray[@]} " =~ "name" ]] && lmsdcg_attName=${lmsdom_attArray['name']}
	[[ " ${!lmsdom_attArray[@]} " =~ "type" ]] && lmsdcg_attType=${lmsdom_attArray['type']}

	case ${lmsdom_TagType} in

		"OPEN" | "OPENCLOSE")
			case ${lmsdom_TagName} in
				"declarations")
					[[ -n "${lmsdcg_attName}" ]] &&
					 {
						lmsStackWrite ${lmsdcg_stackName} ${lmsdcg_ns}
						[[ $? -eq 0 ]] || return 2
					 }

					lmsdcg_ns=${lmsdcg_attName}
					;;

				"declare")
					[[ "${lmsdcg_attType}" != "element" && -n "${lmsdcg_ns}" ]] && lmsdcg_attName="${lmsdcg_ns}${lmsdcg_attName}"
					[[ ${lmsdom_TagType} == "OPENCLOSE" ]] &&
					 {
						[[ -z "${lmsdom_Content}" ]] &&
						 {
							lmsdom_Content=0
							[[ " ${!lmsdom_attArray[@]} " =~ "default" ]] && lmsdom_Content=${lmsdom_attArray["default"]}
						 }
					 }

					lmsDomCDeclare $lmsdcg_attName $lmsdcg_attType "${lmsdom_Content}"
					[[ $? -eq 0 ]] || return 3
					;;

				"set")
					lmsDeclareSet ${lmsdcg_attName} "${lmsdom_Content}"
					[[ $? -eq 0 ]] || return 4
					;;
				*)
					;;
			esac
			;;

		"CLOSE")
			case ${lmsdom_TagName} in

				"/declarations")

					local ns=""
					lmsStackRead ${lmsdcg_stackName} ns
					[[ $? -eq 0 ]] || return 5
					
					lmsdcg_ns=${ns}
					;;

				*)
					;;
			esac
			;;
		*)
			;;
	esac

	lmsdom_attArray=()
	return 0
}

# *********************************************************************************
#
#	lmsDomCLoad
#
#		initialize and start the DOM-XML configuration parser
#
#	parameters:
#		fileName = path to the xml file
#		stackName = (optional) internal DOM stack name (default=lmscfgxml)
#		trace = 0 == > no trace (default), 1 ==> trace elements
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function lmsDomCLoad()
{
	lmsdcg_path=${1}
	lmsdcg_stackName=${2:-"lmscfgxml"}
	lmsdcg_trace=${3:-0}

	lmsDomDCallback "lmsDomCParse" 

	lmsStackCreate ${lmsdcg_stackName} lmscfg_xUid 8
	[[ $? -eq 0 ]] || return 1

	lmsdcg_ns=""
	lmsStackWrite ${lmsdcg_stackName} "${lmsdcg_ns}"
	[[ $? -eq 0 ]] || return 2

	lmsDomDParse ${lmsdcg_path}
	[[ $? -eq 0 ]] || return 3

	return 0
}


