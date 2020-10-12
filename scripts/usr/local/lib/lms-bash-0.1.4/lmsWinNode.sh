# ******************************************************************************
# ******************************************************************************
#
#   lmsWinNode.sh
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

declare -r lmslib_lmsWinNode="0.0.2"			# version of winNode library

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
#	lmsWinNodeCreate
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
function lmsWinNodeCreate()
{
	local nodeName="${1}"
	local winInfo="${2}"

	lmsUtilWMParse "${nodeName}" "${winInfo}"
	[[ $? -eq 0 ]] ||
	 {
		lmsLogDebugMessage $LINENO "WinNodeDebug" "Unable to parse wminfo: '$wmInfo'."
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
#	lmsWinNodeSet
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
function lmsWinNodeSet()
{
	local nodeName="${1}"
	local field=${2:-""}
	local value=${3:-""}

	dynArrayIsRegistered ${nodeName}
	[[ $? -eq 0 ]] &&
	 {
		lmsWinNodeCreate "${nodeName}"
		[[ $? -eq 0 ]] ||
		{
			lmserr_result=$?
			lmsLogDebugMessage $LINENO "winNodeError" "lmsWinNodeSet could not create dynamic array '${nodeName}'"
			return 1
		}
	 }

	[[ -z "${field}" ]] &&
	 {
		lmserr_result=$?
		lmsLogDebugMessage $LINENO "winNodeError" "Field name is required."
		return 2
	 }

	lmsDynaSetAt "${nodeName}" "${field}" "${value}"
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
		lmsLogDebugMessage $LINENO "winNodeError" "winNode could not set value '${value}' at location '${field}' in '${nodeName}'"
		return 3
	 }

	return 0
}

# ******************************************************************************
#
#	lmsWinNodeGet
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
function lmsWinNodeGet()
{
	local nodeName="${1}"
	local field=${2:-""}

	lmserr_result=0

	local value

	lmsDynaGetAt "${nodeName}" "${field}" value
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
	 }

	echo "${value}"
	return ${lmserr_result}
}

# ******************************************************************************
#
#	lmsWinNodeCount
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
function lmsWinNodeCount()
{
	local nodeName="${1}"
	lmserr_result=0

	local count=dynArrayCount "${nodeName}"
	[[ $? -eq 0 ]] ||
	{
		lmserr_result=1
	}

	echo "${count}"
	return $lmserr_result
}

# ******************************************************************************
#
#	lmsWinNodeToStr
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
function lmsWinNodeToStr()
{
	local nodeName="${1}"
	lmserr_result=0

	local count

	dynArrayCount "${nodeName}" count
	[[ $? -eq 0 ]] ||
	{
		lmserr_result=1
		echo "Empty array"
		return $lmserr_result
	}

	printf -v buffer "%s\n" $(lmsWinNodeGet "title" )
	

	echo "${buffer}"
	return $lmserr_result
}

