# *****************************************************************************
# *****************************************************************************
#
#   	lmsDomDelTree.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage lmsDomDTDelete
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
#			Version 0.0.1 - 09-19-2016.
#					0.0.2 - 02-10-2017.
#					0.0.3 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r lmslib_lmsDomDT="0.0.3"	# version of this library

# *******************************************************
# *******************************************************

# ****************************************************************************
#
#	lmsDomDTDelAtt
#
# 	Parameters:
#		aUid = uid of the node whose attributes are to be deleted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function lmsDomDTDelAtt()
{
	local aUid=${1}
	local attName="lmsdom_${aUid}_att"  # name of the dynamic attribute array

	lmsDynaUnset $attName
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "Unable to delete dynamic array '${attName}'"
		#return 1
	 }

	return 0
}

# ****************************************************************************
#
#	lmsDomDTDestroy
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
function lmsDomDTDestroy()
{
	local uid=${1}
	local node="lmsdom_${uid}_node"

	lmsDynaGetAt $node "attcount" attcount
	[[  $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "Debug" "Unable to get count of attribs for '${uid}'"
		return 1
	 }

	[[ $attcount -gt 0 ]] &&
	 {
		lmsDomDTDelAtt ${uid}
		[[  $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "Debug" "Unable to delete attribs for '${uid}'"
			#return 0
		 }
	 }

	lmsDynaUnset $node
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "unable to delete node $node"
		return 2
	 }

	return 0
}

# ****************************************************************************
#
#	lmsDomDTTraverse
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
function lmsDomDTTraverse()
{
	local branch="${1}"
	local branchName="lmsdom_${branch}"
	local limbs=0
	local limb

	lmsLogDebugMessage $LINENO "Debug" "Traverse branch : '${branch}'"

	lmsStackWrite "${lmsddt_stackName}" ${branch}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "Unable to write ${branch} to stack named '${lmsddt_stackName}'"
		return 1
	 }

	lmsDynnReset "$branchName"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "lmsDynnReset '$branchName' failed."
		return 2
	 }

	local valid

	lmsDynnValid "$branchName" valid
	lmserr_result=$?

	while [[ ${lmserr_result} -eq 0 ]]
	do

		lmsDynnGet "$branchName" limb
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "DOMError" "lmsDynnGet failed."
			return 3
		 }

		lmsDomDTTraverse $limb
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "DOMError" "Traverse '${limb}' failed."
			return 4
		 }

		lmsStackPeek "${lmsddt_stackName}" branch
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "DOMError" "Stack peek '${lmsddt_stackName}' failed."
			return 5
		 }

		branchName="lmsdom_${branch}"

		lmsDynnGet "$branchName" limb
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "DOMError" "lmsDynnGet $branchName failed."
			return 6
		 }

		lmsDynnNext "$branchName"
		lmsDynnValid "$branchName" valid

		lmserr_result=$?
	done

	lmsLogDebugMessage $LINENO "Debug" "lmsStackPeek '${lmsddt_stackName}' => '${branch}'"

	lmsStackRead "${lmsddt_stackName}" branch
	[[ $? -eq 0 ]] ||
	 {
		[[ $? -eq 2 ]]
		{
			lmsLogDebugMessage $LINENO "DOMError" "Stack pop EMPTY stack '${lmsddt_stackName}'."
			return 0
		}

		lmsLogDebugMessage $LINENO "DOMError" "Stack pop '${lmsddt_stackName}' failed."
		return 7
	 }
	
	lmsLogDebugMessage $LINENO "Debug" "lmsStackRead '$lmsddt_stackName' ${branch}"

	DOMdtDestroy "${branch}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LILNENO "StackDestroy" "Unable to destroy '${branch}'."
	 }

	lmsLogDebugMessage $LILNENO "Debug" "Node '${branch}' destroyed."

	return 0
}

# ****************************************************************************
#
#	lmsDomDTDelete
#
# 	Parameters:
#  		ddtRoot = root of the tree (branch) to be deleted
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function lmsDomDTDelete()
{
	local ddtRoot="${1}"
	local stackUid

	if [[ -z "${ddtRoot}" ]]
	then
		lmsLogDebugMessage $LINENO "DomError" "Root is not set... terminating lmsDomTCConfig"
		return 1
	fi

	lmsStackExists "${lmsddt_stackName}"
	[[ $? -eq 0 ]] &&
	 {
		lmsStackDestroy "${lmsddt_stackName}"
	 }

	lmsStackCreate "${lmsddt_stackName}" stackUid 12
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "Unable to create stack named '${lmsddt_stackName}'"
		return 2
	 }

	lmserr_result=0

	lmsDomDTTraverse ${ddtRoot}
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "DOMTraverse failed for root '${ddtRoot}'"
		return 3
	 }

	local stksize=0

	lmsStackSize "${lmsddt_stackName}" stkSize
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "DOMError" "Unable to get size of stack '${lmsddt_stackName}'"
		return 4
	 }
	
	[[ ${stkSize} -gt 0 ]] &&
	 {
		lmsDomDTDestroy "${ddtRoot}"
		[[ $? -eq 0 ]] ||
		 {
			lmsLogDebugMessage $LINENO "DOMError" "Unable to delete root '${ddtRoot}'"
			return 5
		 }
	 }

	lmsLogDebugMessage $LINENO "Debug" "Deleted root '${ddtRoot}'"

	lmsStackDestroy "${lmsddt_stackName}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "StackError" "Unable to destroy stack '${lmsddt_stackName}'"
		return 6
	 }

	return 0
}


