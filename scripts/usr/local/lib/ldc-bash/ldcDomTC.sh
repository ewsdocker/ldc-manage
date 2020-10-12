# *****************************************************************************
# *****************************************************************************
#
#   	ldcDomTC.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.5
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcDomTCConfig
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
#			Version 0.0.1 - 09-07-2016.
#			        0.0.2 - 09-15-2016.
#					0.0.3 - 02-10-2017.
#					0.0.4 - 02-15-2017.
#					0.0.5 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcDomTC="0.0.5"		# version of this library

# *****************************************************************************
# *****************************************************************************

declare    ldcdtc_stackName="DTCBranches"
declare -A ldcdtc_attributes=()

# ****************************************************************************
#
#	ldcDomTCGetAtt
#
# 	Parameters:
#		aUid = uid of the node
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
ldcDomTCGetAtt()
{
	local aUid=${1}

	local attName="ldcdom_${aUid}_att"  # name of the dynamic attribute array
	local attKey						# attribute name
	local attValue						# attribute value
	local itValid

	ldcDynnReset ${attName}
	[[ $? -eq 0 ]] || return 0

	ldcDynnValid ${attName} itValid
	[[ $? -eq 0 ]] || return 1

	while [[ itValid -eq 0 ]]
	do
		ldcDynnGet ${attName} attValue		# next attribute value
		[[ $? -eq 0 ]] &&
		 {
			ldcDynnMap ${attName} attKey	# attribute name
			[[ $? -eq 0 ]] ||
			{
				ldcLogDebugMessage $LINENO "DOMError" "IteratorMap failed for ${attName}"
				return 1
			}

			ldcdtc_attributes[$attKey]="${attValue}"
		 }

		ldcDynnNext ${attName}

		ldcDynnValid ${attName} itValid
		[[ $? -eq 0 ]] || return 1
	done

	[[ "${!ldcdtc_attributes[@]}" =~ "name"  ]] || return 2
	[[ "${!ldcdtc_attributes[@]}" =~ "type"  ]] || ldcdtc_attributes["type"]="string"
	[[ "${!ldcdtc_attributes[@]}" =~ "value" ]] || ldcdtc_attributes["value"]=0

	return 0
}

# ****************************************************************************
#
#	ldcDomTCDclV
#
#		Declare variable attributes
#
# 	Parameters:
#  		uid = node uid to declare
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
ldcDomTCDclV()
{
	local uid=${1}

	local node="ldcdom_${uid}_node"
	local attCount

	ldcDynaGetAt $node "attcount" attCount
	[[  $? -eq 0 ]] || return 1
		
	ldcdtc_attributes=()
	
	[[ ${attCount} -gt 0 ]] &&
	 {
		ldcDomTCGetAtt ${uid}
		[[  $? -eq 0 ]] || return 1
	 }

	ldcDynaGetAt $node "content" content
	[[ -n "${content}" ]] &&
	 {
		ldcdtc_attributes["value"]="${content}"
	 }

	ldcerr_result=0

	case ${ldcdtc_attributes["type"]} in

		"integer")
			[[ -n "${attribName}" ]] &&
			{
				ldcLogDebugMessage $LINENO "Debug" "attrib '${attribName}' - value '${ldcdtc_attributes[value]}'"
				ldcDeclareInt ${attribName} "${ldcdtc_attributes[value]}"
				ldcerr_result=$?
			}
			;;

		"array")

			ldcDeclareArray ldcdtc_attributes["name"] "${ldcdtc_attributes[value]}"
			ldcerr_result=$?
			;;

		"associative")

			ldcDeclareAssoc ldcdtc_attributes["name"] "${ldcdtc_attributes[value]}"
			ldcerr_result=$?
			;;

		"element")

			[[ "${!ldcdom_attArray[@]}" =~ "parent" ]] &&
			 {
				ldcLogDebugMessage $LINENO "DOMError" "Missing parent name."
				return 1
			 }

			ldcDeclareArrayEl ldcdtc_attributes["parent"] ldcdtc_attributes["name"] "${ldcdtc_attributes[value]}"
			;;

		"password")

			ldcDeclarePwd ldcdtc_attributes["name"] "${ldcdtc_attributes[value]}"
			ldcerr_result=$?
			;;

		"string")

			ldcDeclareStr ldcdtc_attributes["name"] "${ldcdtc_attributes[value]}"
			ldcerr_result=$?
			;;

		*)

			ldcDeclareStr ldcdtc_attributes["name"] "${ldcdtc_attributes[value]}"
			ldcerr_result=$?
			;;
							
	esac
					
	[[ ${ldcerr_result} -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Declare variable '${ldcdtc_attributes[name]}' failed."
		return 1
	 }

	return 0
}

# ****************************************************************************
#
#	ldcDomTCTraverse
#
#		A recursive descent function to traverse all limbs on the
#		requested branch
#
# 	Parameters:
#  		branch = branch node to start the traversal
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
ldcDomTCTraverse()
{
	local branch=${1}

	local branchName="ldcdom_${branch}"

	local limbs=0
	local limb

	ldcLogDebugMessage $LINENO "Debug" "Traverse branch : '${branch}'"

	ldcStackWrite ${ldcdtc_stackName} ${branch}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Unable to write ${branch} to stack named '${ldcdtc_stackName}'"
		return 1
	 }

	ldcDynnReset "$branchName"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "ldcDynnReset '$branchName' failed."
		return 1
	 }

	dynaArrayITValid "$branchName" ldcerr_result
	[[$? -eq 0 ]] || return 1

	while [[ ${ldcerr_result} -eq 0 ]]
	do
		ldcDynnGet "$branchName" limb
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "ldcDynnGet failed."
			return 1
		 }

		ldcDomTCDclV ${limb}
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "DeclareVar '${branchName}' failed."
			return 1
		 }

		ldcLogDebugMessage $LINENO "Debug" "ldcDomTCDclV added '${branchName}'"

		ldcDomTCTraverse $limb
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "Traverse '${limb}' failed."
			return 1
		 }

		ldcStackPeek "${ldcdtc_stackName}" branch
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "Stack peek '${ldcdtc_stackName}' failed."
			return 1
		 }

		branchName="ldcdom_${branch}"

		ldcDynnNext "$branchName"

		ldcDynnValid "$branchName" ldcerr_result
		[[ $? -eq 0 ]] || return 1
	done

	ldcLogDebugMessage $LINENO "Debug" "ldcStackPeek '$ldcdtc_stackName' => '${branch}'"

	ldcStackRead ${ldcdtc_stackName} branch
	[[ $? -eq 0 ]] ||
	 {
		[[ $? -eq 2 ]]
		{
			ldcLogDebugMessage $LINENO "DOMError" "Stack pop EMPTY stack '${ldcdtc_stackName}'."
			return 0
		}

		ldcLogDebugMessage $LINENO "DOMError" "Stack pop '${ldcdtc_stackName}' failed."
		return 1
	 }
	
	ldcLogDebugMessage $LINENO "Debug" "ldcStackRead '$ldcdtc_stackName' ${branch}"

	return 0
}

# ****************************************************************************
#
#	ldcDomTCConfig
#
# 	Parameters:
#  		none
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
ldcDomTCConfig()
{
	local stackUid

	if [[ -z "${ldcdom_docTree}" ]]
	then
		ldcLogDebugMessage $LINENO "DomError" "Root is not set... terminating ldcDomTCConfig"
		echo "Root is not set... terminating ldcDomTCConfig"
		return 1
	fi

	ldcStackExists "${ldcdtc_stackName}" stackUid
	[[ $? -eq 0 ]] && stackUnset ${ldcdtc_stackName}

	ldcStackCreate ${ldcdtc_stackName} stackUid 12
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Unable to create stack named '${ldcdtc_stackName}'"
		return 2
	 }

	ldcerr_result=0

	ldcDomTCTraverse ${ldcdom_docTree}
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
	 }

	return ${ldcerr_result}
}


