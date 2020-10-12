# *****************************************************************************
# *****************************************************************************
#
#   	ldcDomTs.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcDomToStr
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
#			Version 0.0.1 - 07-24-2016.
#					0.0.2 - 09-06-2016.
#					0.0.3 - 09-15-2016.
#					0.1.0 - 01-15-2017.
#					0.1.1 - 02-10-2017.
#					0.1.2 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcDomToStr="0.1.2"	# version of this library

# *******************************************************
# *******************************************************

declare    ldcdts_buffer
declare    ldcdts_stackName="DTSBranches"

# ****************************************************************************
#
#	ldcDomTsFmtIndent
#
#		Add spaces (indentation) to the buffer
#
# 	Parameters:
#  		stackIndex = how many blocks to indent
#		blockSize = (optional) number of spaces in a block
#
#	Returns:
#		0 = no error
#
# ****************************************************************************
function ldcDomTsFmtIndent()
{
	local -i stkIndent=${1:-0}

	[[ ${stkIndent} -gt 0 ]]  &&  printf -v ldcdts_buffer "%s%*s" "${ldcdts_buffer}" ${stkIndent}
	return 0
}

# ****************************************************************************
#
#	ldcDomTsAddAtt
#
# 	Parameters:
#		aUid = uid of the node
#  		attIndent = columns to indent
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomTsAddAtt()
{
	local aUid=${1}
	local attIndent=${2}

	local attName="ldcdom_${aUid}_att"
	local attValue
	local attKey

	ldcDynnReset $attName
	[[ $? -eq 0 ]] || return 0

	ldcDynnValid ${attName} ldcdom_nodeValid
	[[ $? -eq 0 ]] || return 1

	while [[ ${ldcdom_nodeValid} -eq 1 ]]
	do
		ldcDynnMap ${attName} attValue attKey
		[[ $? -eq 0 ]] || return 1

		printf -v ldcdts_buffer "%s %s=%s" "${ldcdts_buffer}" ${attKey} "${attValue}"

		ldcDynnNext ${attName}
		ldcDynnValid ${attName} ldcdom_nodeValid
	done

	return 0
}

# ****************************************************************************
#
#	ldcDomTsFmtOut
#
#		Add node info to the buffer
#
# 	Parameters:
#  		uid = node uid to add
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomTsFmtOut()
{
	local uid=${1}
	local node="ldcdom_${uid}_node"
	local tagName=""
	local attcount=0

	ldcDynaGetAt $node "tagname" tagName
	[[ $? -eq 0 ]] || return 1

	ldcDynaGetAt $node "attcount" attcount
	[[ $? -eq 0 ]] || return 1

	local stackIndent
	ldcStackSize ${ldcdts_stackName} stackIndent
	[[ $? -eq 0 ]] || return 1

	ldcUtilIndent $stackIndent ldcdts_buffer
	printf -v ldcdts_buffer "%s%s" "${ldcdts_buffer}" "${tagName}"

	(( stackIndent++ ))

	[[ ${attcount} -eq 0 ]] ||
	 {
		ldcDomTsAddAtt ${uid} ${stackIndent}
		[[  $? -eq 0 ]] || return 1
	 }

	ldcDynaGetAt $node "content" content
	[[  $? -eq 0 ]] || return 1

	[[ -n "${content}" ]] && printf -v ldcdts_buffer "%s content=\"%s\"" "${ldcdts_buffer}" "${content}"
	printf -v ldcdts_buffer "%s\n" "${ldcdts_buffer}"

	return 0
}

# ****************************************************************************
#
#	ldcDomTsTraverse
#
# 	Parameters:
#  		branch = branch node name to traverse
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomTsTraverse()
{
	local branch=${1}

	local branchName="ldcdom_${branch}"
	local limbs=0
	local limb

	ldcStackWrite ${ldcdts_stackName} ${branch}
	[[ $? -eq 0 ]] || return 1

	ldcDynnReset "$branchName"
	[[ $? -eq 0 ]] || return 1

	ldcDynnValid "$branchName" ldcdom_nodeValid

	while [[ ${ldcdom_nodeValid} -eq 1 ]]
	do
		ldcDynnMap "$branchName" limb
		[[ $? -eq 0 ]] || return 1

		ldcDomTsFmtOut ${limb}
		[[ $? -eq 0 ]] || return 1

		ldcDomTsTraverse ${limb}
		[[ $? -eq 0 ]] || break

		ldcStackPeek "${ldcdts_stackName}" branch
		[[ $? -eq 0 ]] || return 1

		branchName="ldcdom_${branch}"

		ldcDynnNext "$branchName"
		ldcDynnValid "$branchName" ldcdom_nodeValid
	done

	ldcStackRead ${ldcdts_stackName} branch
	[[ $? -eq 0 ]] || 
	 {
		[[ $? -ne 2 ]] || return 1
	 }
	
	return 0
}

# ****************************************************************************
#
#	ldcDomToStr
#
# 	Parameters:
#  		returnString = place to put the generated string
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# ****************************************************************************
function ldcDomToStr()
{
	local stackUid
	local lresult=1

	ldcdts_buffer=""

	while true ; do

		[[ -z "${ldcdom_docTree}" ]] && break

		(( lresult++ ))

		ldcStackLookup "${ldcdts_stackName}" stackUid
		[[ $? -eq 0 ]] && ldcStackDestroy ${ldcdts_stackName}

		ldcStackCreate ${ldcdts_stackName} stackUid 12
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		ldcDomTsFmtOut ${ldcdom_docTree}
		[[ $? -eq 0 ]] || break

		ldcerr_result=0

		(( lresult++ ))

		ldcDomTsTraverse ${ldcdom_docTree}
		[[ $? -eq 0 ]] || break

		(( lresult++ ))

		ldcDeclareStr ${1} "${ldcdts_buffer}"
		[[ $? -eq 0 ]] || break

		$lresult=0
		break
	done
	
	return $lresult
}


