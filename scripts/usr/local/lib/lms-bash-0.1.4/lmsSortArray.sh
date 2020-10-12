# *****************************************************************************
# *****************************************************************************
#
#   lmsSortArray.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.0
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsSortArray
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
#			Version 0.0.1 - 03-18-2016.
#					0.1.0 - 01-30-2017.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_lmsSortArray="0.1.0"	# version of arraySort library

declare -a lmssrt_sorted

declare -a lmssrt_array=()
declare    lmssrt_sortedList

# ******************************************************************************
#
#	Required global declarations
#
# ******************************************************************************

# ******************************************************************************
# ******************************************************************************
#
#	Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsSortArrayBubble
#
#	Sort all positional arguments and store them in global array lmssrt_array.
#	Without arguments sort this array. 
#
# 	Bubble sorting lets the heaviest element sink to the bottom
#			(or lightest element to float to the top).
#
#	parameters:
#		(array) sortMe = array to be sorted
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsSortArrayBubble()
{
	(($# > 0)) && lmssrt_array=("$@")

	local j=0 
	local ubound=$((${#lmssrt_array[*]} - 1))

    while ((ubound > 0))
	do
		local i=0

		while ((i < ubound))
		do
			if [ "${lmssrt_array[$i]}" \> "${lmssrt_array[$((i + 1))]}" ]
			then
				local t="${lmssrt_array[$i]}"
				lmssrt_array[$i]="${lmssrt_array[$((i + 1))]}"
				lmssrt_array[$((i + 1))]="$t"
			fi

			((++i))
		done

		((++j))
		((--ubound))
	done

	return 0
}

# ******************************************************************************
#
#		NOTE - this implementation does not work at this time
#
#	lmsSortArrayQuick
#
#		quicksorts positional arguments in an array
#
#	parameters:
#		(array) sortMe = array to be sorted
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsSortArrayQuick() 
{
	local pivot 
	local i
	local smaller=()
	local larger=()
	
	lmssrt_sorted=()

	(($#==0)) && return 0
	
	pivot=$1
	shift
	
	for i
	do
    	(( $i < $pivot )) && smaller+=( "$i" ) || larger+=( "$i" )
	done
	
	lmsSortArrayQuick "${smaller[@]}"
	smaller=( "${lmssrt_sorted[@]}" )
   
	lmsSortArrayQuick "${larger[@]}"
   
	larger=( "${lmssrt_sorted[@]}" )
	
	lmssrt_sorted=( "${smaller[@]}" "$pivot" "${larger[@]}" )
}

