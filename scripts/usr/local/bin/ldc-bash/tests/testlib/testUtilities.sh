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
# @package ldc-bash
# @subpackage tests
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

	ldcConioDisplay "$( tput bold ; tput setaf $color )     $message $( tput sgr0 )"
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
	[[ -z "${ldchlp_XmlFile}" ]] &&
	 {
		ldcHelpInit ${hlpPath}
		[[ $? -eq 0 ]] ||
		 {
			ldctst_resultCode=$?
	 	    ldcLogDisplay "ldcHelpInit '${hlpPath}' failed: ${ldctst_resultCode}"
			return ${ldctst_resultCode}
		 }
	 }

	[[ -z "${ldctst_buffer}" ]] &&
	 {
		ldctst_buffer=$( ldcHelpToStr )
		[[ $? -eq 0 ]] ||
		 {
			ldctst_resultCode=$?
			ldcLogDisplay "ldcHelpToStr failed: ${ldctst_resultCode}"
			return ${ldctst_resultCode}
		 }
	 }

	ldcConioDisplay ""	
	ldcConioDisplay "${ldctst_buffer}"
	ldcConioDisplay ""	

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

	ldcConioDisplay ""
	ldcConioDisplay "XML_ENTITY    : '${ldcdom_Entity}'"

	ldcConioDisplay "XML_CONTENT   :     '${ldcdom_Content}'"

	ldcConioDisplay "XML_TAG_NAME  :     '${ldcdom_TagName}'"
	ldcConioDisplay "XML_TAG_TYPE  :     '${ldcdom_TagType}'"

	[[ "${ldcdom_TagType}" == "OPEN" || "${ldcdom_TagType}" == "OPENCLOSE" ]] &&
	 {
		[[ ${ldcdom_attribCount} -eq 0 ]] ||
		 {
			ldcConioDisplay "XML_ATT_COUNT :     '${ldcdom_attribCount}'"
		
			for attribute in "${!ldcdom_attribs[@]}"
			do
				ldcConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				ldcConioDisplay "XML_ATT_VAL   :     '${ldcdom_attribs[$attribute]}'"
				
			done
		 }
	 }

	ldcConioDisplay "XML_COMMENT   :     '${ldcdom_Comment}'"
	ldcConioDisplay "XML_PATH      :     '${ldcdom_Path}'"

	ldcConioDisplay "XPATH         :     '${ldcdom_XPath}'"
}



