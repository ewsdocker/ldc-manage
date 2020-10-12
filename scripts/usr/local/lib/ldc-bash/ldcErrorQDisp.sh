# *****************************************************************************
# *****************************************************************************
#
#   ldcErrorQDisp.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage ldcErrorQDisp
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
#			Version 0.0.1 - 03-27-2016.
#					0.1.0 - 01-16-2017.
#					0.1.1 - 01-25-2017.
#					0.1.2 - 09-06-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcErrorQDisp="0.1.2"	# version of the library

# *****************************************************************************
#
#	ldcErrorQDispDetail
#
#		Display the error messages in exploded format
#
#	Parameters:
#		qName = queue name
#		qResult = return buffer
#		qElement = record number
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function ldcErrorQDispDetail()
{
	local    qName=${1}
	local    qResult="${2}"
	local    qElement=$3

	ldcErrorLookupName ${qName} "${ldcerr_QError}"
	[[ $? -eq 0 ]] || return 1

	ldcerr_QErrorDesc="$ldcerr_message"

	ldcConioDisplay "$qElement - ${qResult}"
	ldcConioDisplay ""
	ldcConioDisplay "   Time:            $ldcerr_QDateTime"
	ldcConioDisplay "   Line-number:     $ldcerr_QLine"
	ldcConioDisplay "   Source:          $ldcerr_QScript"
	ldcConioDisplay "   Function:        $ldcerr_QFunction"
	ldcConioDisplay "   Error:           $ldcerr_QError"
	ldcConioDisplay "   Description:     $ldcerr_QErrorDesc"
	ldcConioDisplay "   Error-modifier:  $ldcerr_QErrorMod"
	ldcConioDisplay ""

	return 0
}

# *****************************************************************************
#
#	ldcErrorQDispOutput
#
#		Display the error messages in exploded format
#
#	Parameters:
#		qName = queue name
#		qResult = result to display
#		qElement = record number to display
#		qDetail = (optional) 0 => no detail (default), non-zero => detail
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function ldcErrorQDispOutput()
{
	local    qName=${1}
	local    qResult="${2}"
	local    qElement=${3:-0}
	local -i qDetail=${4:-0}

	[[ ${4} -ne 0 ]] &&
	 {
		ldcErrorQDispDetail "${qName}" "${qResult}" ${qElement}
		return $?
	 }

	printf "% 4u %s - %s @ % u in %s:%s\n" ${qElement} "$ldcerr_QDateTime" "$ldcerr_QError" $ldcerr_QLine "$ldcerr_QScript" "$ldcerr_QFunction"
	printf "    %s (%s)\n" "${ldcerr_QErrorDesc}" "${ldcerr_QErrorMod}"

	return 0
}

# *****************************************************************************
#
#	ldcErrorQDispPeek
#
#		Non-volatile listing of the error queue stack
#
#	Parameters:
#		qName = queue name
#		qDetail = 0 => standard detail, 1 => full detail
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function ldcErrorQDispPeek()
{
	local    qName=${1}
	local -i qDetail=${2:-0}
	local    qResult=""
	local    qElement=0

	local    qCount

	ldccli_optQueueErrors=0
	ldcerr_result=0

	ldcErrorQErrors "${qName}" qCount
	[[ $? -eq 0 ]] || 
	 {
		ldcerr_result=$?
		return 1
	 }

	ldcerr_result=0
	while [[ $ldcerr_result -eq 0  &&  $qElement -lt $qCount ]]
	do
		qResult=""
		ldcErrorQPeek ${qName} qResult $qElement
		[[ $? -eq 0 ]] || break

		ldcErrorQDispOutput ${qName} "${qResult}" ${qElement} ${qDetail}
		[[ $? -eq 0 ]] || break

		(( qElement++ ))
	done

	ldccli_optQueueErrors=1
	return 0
}

# *****************************************************************************
#
#	ldcErrorQDispPop
#
#		Volatile listing of the error queue stack
#
#	Parameters:
#		qName = name of the error queue
#		qDetail = 0 => standard detail, 1 => full detail
#
#	Returns:
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function ldcErrorQDispPop()
{
	local    qName=${1}
	local -i qDetail=${2:-0}

	local    qResult=""
	local    qCount

	ldcErrorQErrors ${qName} qCount
	[[ $? -eq 0 ]] || return 1

	while [[ $qCount -gt 0 ]]
	do
		(( qCount-- ))

		ldcErrorQRead ${qName} qResult
		[[ $? -eq 0 ]] || return 2

		ldcErrorQDispOutput ${qName} "${qResult}" ${qCount} ${qDetail}
		[[ $? -eq 0 ]] || return 3
	done

	return 0
}

