# *****************************************************************************
# *****************************************************************************
#
#   startInit.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package lms-bash
# @subpackage applications
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

#
#	Run the startup initialize function(s)
#
lmsStartupInit $lmsscr_Version ${lmsapp_errors}
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugL "Debug" "Unable to load error codes."
	exit 1
 }

#
#	Select the error codes from the XML error file
#
lmsXPathSelect "lmsErrors" ${lmserr_arrayName}
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugL "XmlError" "Unable to select ${lmserr_arrayName}"
	lmsErrorExitScript "XmlError"
 }

lmsDomCLoad "${lmsapp_declare}" "${lmsapp_stackName}" 0
[[ $? -eq 0 ]] ||
 {
	lmsapp_result=$?
echo "Startup failed in lmsDomCLoad error: ${lmsapp_result}"
	lmsConioDebugL "DOMError" "Startup failed in lmsDomCLoad error: ${lmsapp_result}"
	lmsErrorExitScript "DOMError"
 }

lmsCliParse
[[ $? -eq 0 ]] || 
{
	lmsConioDebugL "CliError" "cliParameterParse failed"
	lmsErrorExitScript "CliError"
}

[[ ${lmscli_Errors} -eq 0 ]] ||
 {
	lmsConioDebugL "CliError" "cliErrors = ${lmscli_Errors}, param = ${lmscli_paramErrors}, cmnd = ${lmscli_cmndErrors}"
	lmsErrorExitScript "CliError"
 }

lmsCliApply
[[ $? -eq 0 ]] || 
 {
	lmsConioDebugL "CliError" "lmsCliApply failed: $?"
	lmsErrorExitScript "CliError"
 }

echo "Init lmsHelp"

lmsHelpInit ${lmsapp_help}
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugL "HelpError" "Help init failed."
	lmsErrorExitScript "HelpError"
 }

echo "lmsHelp inited"

