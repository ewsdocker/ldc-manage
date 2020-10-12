# *****************************************************************************
# *****************************************************************************
#
#   	ldcDomDelTree.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcDomDTDelete
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
#			Version 0.0.1 - 09-19-2016.
#					0.0.2 - 02-10-2017.
#					0.0.3 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcDomDT="0.0.3"	# version of this library

# *******************************************************
# *******************************************************

# ****************************************************************************
#
#	ldcDomDTDelAtt
#
# 	Parameters:
#		aUid = uid of the node whose attributes are to be deleted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDTDelAtt()
{
	local aUid=${1}
	local attName="ldcdom_${aUid}_att"  # name of the dynamic attribute array

	ldcDynaUnset $attName
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Unable to delete dynamic array '${attName}'"
		#return 1
	 }

	return 0
}

# ****************************************************************************
#
#	ldcDomDTDestroy
#
#		Declare variable attributes
#
# 	Parameters:
#  		uid = node uid to delete
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDTDestroy()
{
	local uid=${1}
	local node="ldcdom_${uid}_node"

	ldcDynaGetAt $node "attcount" attcount
	[[  $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "Debug" "Unable to get count of attribs for '${uid}'"
		return 1
	 }

	[[ $attcount -gt 0 ]] &&
	 {
		ldcDomDTDelAtt ${uid}
		[[  $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "Debug" "Unable to delete attribs for '${uid}'"
			#return 0
		 }
	 }

	ldcDynaUnset $node
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "unable to delete node $node"
		return 2
	 }

	return 0
}

# ****************************************************************************
#
#	ldcDomDTTraverse
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
function ldcDomDTTraverse()
{
	local branch="${1}"
	local branchName="ldcdom_${branch}"
	local limbs=0
	local limb

	ldcLogDebugMessage $LINENO "Debug" "Traverse branch : '${branch}'"

	ldcStackWrite "${ldcddt_stackName}" ${branch}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Unable to write ${branch} to stack named '${ldcddt_stackName}'"
		return 1
	 }

	ldcDynnReset "$branchName"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "ldcDynnReset '$branchName' failed."
		return 2
	 }

	local valid

	ldcDynnValid "$branchName" valid
	ldcerr_result=$?

	while [[ ${ldcerr_result} -eq 0 ]]
	do

		ldcDynnGet "$branchName" limb
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "ldcDynnGet failed."
			return 3
		 }

		ldcDomDTTraverse $limb
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "Traverse '${limb}' failed."
			return 4
		 }

		ldcStackPeek "${ldcddt_stackName}" branch
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "Stack peek '${ldcddt_stackName}' failed."
			return 5
		 }

		branchName="ldcdom_${branch}"

		ldcDynnGet "$branchName" limb
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "ldcDynnGet $branchName failed."
			return 6
		 }

		ldcDynnNext "$branchName"
		ldcDynnValid "$branchName" valid

		ldcerr_result=$?
	done

	ldcLogDebugMessage $LINENO "Debug" "ldcStackPeek '${ldcddt_stackName}' => '${branch}'"

	ldcStackRead "${ldcddt_stackName}" branch
	[[ $? -eq 0 ]] ||
	 {
		[[ $? -eq 2 ]]
		{
			ldcLogDebugMessage $LINENO "DOMError" "Stack pop EMPTY stack '${ldcddt_stackName}'."
			return 0
		}

		ldcLogDebugMessage $LINENO "DOMError" "Stack pop '${ldcddt_stackName}' failed."
		return 7
	 }
	
	ldcLogDebugMessage $LINENO "Debug" "ldcStackRead '$ldcddt_stackName' ${branch}"

	DOMdtDestroy "${branch}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LILNENO "StackDestroy" "Unable to destroy '${branch}'."
	 }

	ldcLogDebugMessage $LILNENO "Debug" "Node '${branch}' destroyed."

	return 0
}

# ****************************************************************************
#
#	ldcDomDTDelete
#
# 	Parameters:
#  		ddtRoot = root of the tree (branch) to be deleted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomDTDelete()
{
	local ddtRoot="${1}"
	local stackUid

	if [[ -z "${ddtRoot}" ]]
	then
		ldcLogDebugMessage $LINENO "DomError" "Root is not set... terminating ldcDomTCConfig"
		return 1
	fi

	ldcStackExists "${ldcddt_stackName}"
	[[ $? -eq 0 ]] &&
	 {
		ldcStackDestroy "${ldcddt_stackName}"
	 }

	ldcStackCreate "${ldcddt_stackName}" stackUid 12
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Unable to create stack named '${ldcddt_stackName}'"
		return 2
	 }

	ldcerr_result=0

	ldcDomDTTraverse ${ddtRoot}
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "DOMTraverse failed for root '${ddtRoot}'"
		return 3
	 }

	local stksize=0

	ldcStackSize "${ldcddt_stackName}" stkSize
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "DOMError" "Unable to get size of stack '${ldcddt_stackName}'"
		return 4
	 }
	
	[[ ${stkSize} -gt 0 ]] &&
	 {
		ldcDomDTDestroy "${ddtRoot}"
		[[ $? -eq 0 ]] ||
		 {
			ldcLogDebugMessage $LINENO "DOMError" "Unable to delete root '${ddtRoot}'"
			return 5
		 }
	 }

	ldcLogDebugMessage $LINENO "Debug" "Deleted root '${ddtRoot}'"

	ldcStackDestroy "${ldcddt_stackName}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "StackError" "Unable to destroy stack '${ldcddt_stackName}'"
		return 6
	 }

	return 0
}


