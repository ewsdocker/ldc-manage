# ******************************************************************************
# ******************************************************************************
#
#  lmsSortArray.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 03-18-2016.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_arraySort="0.1.0"	# version of arraySort library

declare -a arraySortRet
declare -a lmssrt_array=()

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
#	lmsSortArray.bash
#
#	Sort all positional arguments and store them in global array lmssrt_array.
#	Without arguments sort this array. 
#
# 	Bubble sorting lets the heaviest element sink to the bottom
#			(or lightest element to float to the top).
#
#	Based upon code contributed by Andreas Spindler:
#		http://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
#
#	parameters:
#		(array) sortMe = array to be sorted
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsSortArray.bash()
{
	[[ $# -gt 0 ]] && lmssrt_array=("$@")

	local j=0 
	local ubound=${#lmssrt_array[*]}

	(( ubound-- ))

    while [[ ubound -gt 0 ]]
	do
		local i=0

		while [[ i -lt ubound ]]
		do
			[[ "${lmssrt_array[$i]}" \> "${lmssrt_array[$((i + 1))]}" ]] &&
			 {
				local t="${lmssrt_array[$i]}"
				lmssrt_array[$i]="${lmssrt_array[$((i + 1))]}"
				lmssrt_array[$((i + 1))]="$t"
			 }

			(( i++ ))
		done

		(( j++ ))
		(( ubound-- ))
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
	
	arraySortRet=()

	(( $# -eq 0 )) && return 0
	
	pivot=$1
	shift
	
	for i
	do
    	[[ $i < $pivot ]] && smaller+=( "$i" ) || larger+=( "$i" )
	done
	
	lmsSortArrayQuick "${smaller[@]}"
	smaller=( "${arraySortRet[@]}" )
   
	lmsSortArrayQuick "${larger[@]}"
   
	larger=( "${arraySortRet[@]}" )
	
	arraySortRet=( "${smaller[@]}" "$pivot" "${larger[@]}" )
}

# ******************************************************************************
# ******************************************************************************
#
#			END OF Array Sort
#
# ******************************************************************************
# ******************************************************************************
