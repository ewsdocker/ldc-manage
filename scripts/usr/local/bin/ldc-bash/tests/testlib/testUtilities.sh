# *****************************************************************************
# *****************************************************************************
#
#   testUtilities.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package lms-bash
# @subpackage tests
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
#			Version 0.0.3 - 08-24-2018.
#
# *****************************************************************************
# *****************************************************************************

# ****************************************************************************
#
#	testHighlightMessage
#
#		highlight the message in the buffer and output to display
#
# 	Parameters:
#		message = buffer to add the spaces to
#
#	Returns:
#		0 = no error
#
# ****************************************************************************
function testHighlightMessage()
{
	local message="${1}"
	local color=1

	lmsConioDisplay "$( tput bold ; tput setaf $color )     $message $( tput sgr0 )"
}

# ****************************************************************************
#
#	testIndentFmt
#
#		Add spaces (indentation) to the buffer
#
# 	Parameters:
#  		indent = how many blocks to indent
#		buffer = buffer to add the spaces to
#		blockSize = (optional) number of spaces in a block
#
#	Returns:
#		0 = no error
#
# ****************************************************************************
function testIndentFmt()
{
	local -i indent=${1:-1}
	local    buffer=${2:-""}
	local -i bSize=${3:-4}

	(( bSize+=${indent}*${bSize} ))

	[[ ${indent} -gt 0 ]]  &&  printf -v ${buffer} "%s%*s" "${buffer}" ${indent}
	return 0
}

# *****************************************************************************
#
#	testDisplayHelp
#
#	parameters:
#		helpFile = path to the xml file
#
#	returns:
#		$? = 0 ==> no errors.
#
# *****************************************************************************
function testDisplayHelp()
{
	local hlpPath="${1}"
	[[ -z "${lmshlp_XmlFile}" ]] &&
	 {
		lmsHelpInit ${hlpPath}
		[[ $? -eq 0 ]] ||
		 {
			lmstst_resultCode=$?
	 	    lmsLogDisplay "lmsHelpInit '${hlpPath}' failed: ${lmstst_resultCode}"
			return ${lmstst_resultCode}
		 }
	 }

	[[ -z "${lmstst_buffer}" ]] &&
	 {
		lmstst_buffer=$( lmsHelpToStr )
		[[ $? -eq 0 ]] ||
		 {
			lmstst_resultCode=$?
			lmsLogDisplay "lmsHelpToStr failed: ${lmstst_resultCode}"
			return ${lmstst_resultCode}
		 }
	 }

	lmsConioDisplay ""	
	lmsConioDisplay "${lmstst_buffer}"
	lmsConioDisplay ""	

	return 0
}

# *****************************************************************************
#
#	testDomShowData
#
#		Display the current xml dom element
#
# *****************************************************************************
function testDomShowData()
{
	local content

	lmsConioDisplay ""
	lmsConioDisplay "XML_ENTITY    : '${lmsdom_Entity}'"

	lmsConioDisplay "XML_CONTENT   :     '${lmsdom_Content}'"

	lmsConioDisplay "XML_TAG_NAME  :     '${lmsdom_TagName}'"
	lmsConioDisplay "XML_TAG_TYPE  :     '${lmsdom_TagType}'"

	[[ "${lmsdom_TagType}" == "OPEN" || "${lmsdom_TagType}" == "OPENCLOSE" ]] &&
	 {
		[[ ${lmsdom_attribCount} -eq 0 ]] ||
		 {
			lmsConioDisplay "XML_ATT_COUNT :     '${lmsdom_attribCount}'"
		
			for attribute in "${!lmsdom_attribs[@]}"
			do
				lmsConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				lmsConioDisplay "XML_ATT_VAL   :     '${lmsdom_attribs[$attribute]}'"
				
			done
		 }
	 }

	lmsConioDisplay "XML_COMMENT   :     '${lmsdom_Comment}'"
	lmsConioDisplay "XML_PATH      :     '${lmsdom_Path}'"

	lmsConioDisplay "XPATH         :     '${lmsdom_XPath}'"
}



