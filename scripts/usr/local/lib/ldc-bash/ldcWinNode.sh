# ******************************************************************************
# ******************************************************************************
#
#   ldcWinNode.sh
#
#		A window information node container
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage winNode
#
# *****************************************************************************
#
#	Copyright © 2016,2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#		Version 0.0.1 - 12-21-2016.
#				0.0.2 - 02-09-2017.
#
# ******************************************************************************
# ******************************************************************************

declare -r ldclib_ldcWinNode="0.0.2"			# version of winNode library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************


# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	ldcWinNodeCreate
#
#		Create the node
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcWinNodeCreate()
{
	local nodeName="${1}"
	local winInfo="${2}"

	ldcUtilWMParse "${nodeName}" "${winInfo}"
	[[ $? -eq 0 ]] ||
	 {
		ldcLogDebugMessage $LINENO "WinNodeDebug" "Unable to parse wminfo: '$wmInfo'."
		return 2
	 }

	local count
	dynArrayCount ${nodeName} count
	[[ $? -eq 0 ]] || return 3

	[[ $count -eq 0 ]] && return 3

	return 0
}

# ******************************************************************************
#
#	ldcWinNodeSet
#
#		Set the specified winNode field
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#		field = the name of the field
#		value = the field's value
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcWinNodeSet()
{
	local nodeName="${1}"
	local field=${2:-""}
	local value=${3:-""}

	dynArrayIsRegistered ${nodeName}
	[[ $? -eq 0 ]] &&
	 {
		ldcWinNodeCreate "${nodeName}"
		[[ $? -eq 0 ]] ||
		{
			ldcerr_result=$?
			ldcLogDebugMessage $LINENO "winNodeError" "ldcWinNodeSet could not create dynamic array '${nodeName}'"
			return 1
		}
	 }

	[[ -z "${field}" ]] &&
	 {
		ldcerr_result=$?
		ldcLogDebugMessage $LINENO "winNodeError" "Field name is required."
		return 2
	 }

	ldcDynaSetAt "${nodeName}" "${field}" "${value}"
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
		ldcLogDebugMessage $LINENO "winNodeError" "winNode could not set value '${value}' at location '${field}' in '${nodeName}'"
		return 3
	 }

	return 0
}

# ******************************************************************************
#
#	ldcWinNodeGet
#
#		Get the specified winNode field value
#
#	parameters:
#		nodeName = name of the dynamic array
#		field = name of the field
#
#	outputs:
#		value = value of the specified field
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function ldcWinNodeGet()
{
	local nodeName="${1}"
	local field=${2:-""}

	ldcerr_result=0

	local value

	ldcDynaGetAt "${nodeName}" "${field}" value
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
	 }

	echo "${value}"
	return ${ldcerr_result}
}

# ******************************************************************************
#
#	ldcWinNodeCount
#
#		Return the number of keys in the array
#
#	parameters:
#		nodeName = name of the node
#
#	outputs:
#		count = number of keys in the array
#
#	returns:
#		0 = no error
#		1 = error
#
# ******************************************************************************
function ldcWinNodeCount()
{
	local nodeName="${1}"
	ldcerr_result=0

	local count=dynArrayCount "${nodeName}"
	[[ $? -eq 0 ]] ||
	{
		ldcerr_result=1
	}

	echo "${count}"
	return $ldcerr_result
}

# ******************************************************************************
#
#	ldcWinNodeToStr
#
#		Returns a printable string of the winNode contents
#
#	parameters:
#		nodeName = name of the node
#
#	outputs:
#		winBuffer = the array in printable format
#
#	returns:
#		0 = no error
#		1 = error
#
# ******************************************************************************
function ldcWinNodeToStr()
{
	local nodeName="${1}"
	ldcerr_result=0

	local count

	dynArrayCount "${nodeName}" count
	[[ $? -eq 0 ]] ||
	{
		ldcerr_result=1
		echo "Empty array"
		return $ldcerr_result
	}

	printf -v buffer "%s\n" $(ldcWinNodeGet "title" )
	

	echo "${buffer}"
	return $ldcerr_result
}

