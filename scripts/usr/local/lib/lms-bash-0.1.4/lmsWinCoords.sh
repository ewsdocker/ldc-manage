# ******************************************************************************
# ******************************************************************************
#
#   lmsWinCoords.sh
#
#		Add, modify and retrieve window coordinates from a dynamic array
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsWinCoords
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#		Version 0.0.1 - 12-20-2016.
#				0.0.2 - 02-10-2017.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_lmsWinCoords="0.0.2"			# version of lmsWinCoords library

# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsWinCoords
#
#		Apply window coordinates to the provided dynamic array
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#		workspace = window workspace number (winws)
#		xcoord = value of the x-coordinate (winx)
#		ycoord = value of the y-coordinate (winy)
#		width = width of the window (winw)
#		height = height of the window (winh)
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsWinCoords()
{
	local nodeName="${1}"
	local winws=${2:-0}
	local winx=${3:-0}
	local winy=${4:-0}
	local winw=${5:-100}
	local winh=${4:-60}

	lmsWinCoordsSet ${nodeName} "winws" ${winws}
	[[ $? -eq 0 ] || return $?

	lmsWinCoordsSet ${nodeName} "winx" ${winx}
	[[ $? -eq 0 ] || return $?

	lmsWinCoordsSet ${nodeName} "winy" ${winy}
	[[ $? -eq 0 ] || return $?

	lmsWinCoordsSet ${nodeName} "winw" ${winw}
	[[ $? -eq 0 ] || return $?

	lmsWinCoordsSet ${nodeName} "winh" ${winh}
	[[ $? -eq 0 ] || return $?

	return 0
}

# ******************************************************************************
#
#	lmsWinCoordsCopy
#
#		populates the destination (copyName) dynamic array window coordinates
#			from the source (nodeName) dynamic array
#
#	parameters:
#		nodeName = the name of the source dynamic array
#		copyName = the name of the destination dynamic array
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsWinCoordsCopy()
{
	local nodeName=${1}
	local copyName=${2}

	local value

	lmsDynaGetAt ${nodeName} "winws" $value
	[[ $? -eq 0 ]] || return 1

	lmsDynaSetAt ${copyName} "winws" $value
	 [[ $? -eq 0 ]] || return 1

	lmsDynaGetAt ${nodeName} "winx" $value
	[[ $? -eq 0 ]] || return 1

	lmsDynaSetAt ${copyName} "winx" $value
	 [[ $? -eq 0 ]] || return 1

	lmsDynaGetAt ${nodeName} "winy" $value
	[[ $? -eq 0 ]] || return 1

	lmsDynaSetAt ${copyName} "winy" $value
	 [[ $? -eq 0 ]] || return 1

	lmsDynaGetAt ${nodeName} "winw" $value
	[[ $? -eq 0 ]] || return 1

	lmsDynaSetAt ${copyName} "winw" $value
	 [[ $? -eq 0 ]] || return 1

	lmsDynaGetAt ${nodeName} "winh" $value
	[[ $? -eq 0 ]] || return 1

	lmsDynaSetAt ${copyName} "winh" $value
	 [[ $? -eq 0 ]] || return 1

	return 0
}

# ******************************************************************************
#
#	lmsWinCoordsToStr
#
#		returns coordinates as a string containing 
#			the window coordinates for output
#
#		(x-coord, y-coord, width, height)
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#		viewport = viewport flag (0 = include workspace, 1 = no workspace)
#
#	outputs:
#		buffer = string containing the coordinates to print
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsWinCoordsToStr()
{
	local nodeName=${1}
	local viewport=${2:-0}

	local value
	local buffer=""

	while [ true ]
	do
		[[ $viewport -eq 0 ]] &&
		 {
			lmsDynaGetAt ${nodeName} "winws" $value
			[[ $? -eq 0 ]] || break

			printf -v buffer "%s" $value
		 }

		lmsDynaGetAt ${nodeName} "winx" $value
		[[ $? -eq 0 ]] || break

		printf -v buffer "%s %s" "${buffer}" ${value}

		lmsDynaGetAt ${nodeName} "winy" $value
		[[ $? -eq 0 ]] || break

		printf -v buffer "%s %s" "${buffer}" ${value}

		lmsDynaGetAt ${nodeName} "winw" $value
		[[ $? -eq 0 ]] || break

		printf -v buffer "%s %s" "${buffer}" ${value}

		lmsDynaGetAt ${nodeName} "winh" $value
		[[ $? -eq 0 ]] || break

		printf -v buffer "%s %s" "${buffer}" ${value}

		echo "${buffer}"
		return 0
	done
	
	echo "${buffer}"
	return 1
}

# ******************************************************************************
#
#	lmsWinCoordsViewport
#
#		returns coordinates as a string containing 
#			the window coordinates without the workspace number)
#
#		(x-coord, y-coord, width, height)
#
#	parameters:
#		nodeName = the name of the dynamic array to create
#
#	outputs:
#		buffer = string containing the coordinates to print
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsWinCoordsViewport()
{
	buffer=$( lmsWinCoordsToStr ${nodeName} 1 )
	lmserr_result=$?
	
	echo "${buffer}"
	return ${lmserr_result}
}

