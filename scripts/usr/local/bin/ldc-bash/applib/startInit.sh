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
# @package ldc-bash
# @subpackage applications
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

#
#	Run the startup initialize function(s)
#
ldcStartupInit $ldcscr_Version ${ldcapp_errors}
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugL "Debug" "Unable to load error codes."
	exit 1
 }

#
#	Select the error codes from the XML error file
#
ldcXPathSelect "ldcErrors" ${ldcerr_arrayName}
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugL "XmlError" "Unable to select ${ldcerr_arrayName}"
	ldcErrorExitScript "XmlError"
 }

ldcDomCLoad "${ldcapp_declare}" "${ldcapp_stackName}" 0
[[ $? -eq 0 ]] ||
 {
	ldcapp_result=$?
echo "Startup failed in ldcDomCLoad error: ${ldcapp_result}"
	ldcConioDebugL "DOMError" "Startup failed in ldcDomCLoad error: ${ldcapp_result}"
	ldcErrorExitScript "DOMError"
 }

ldcCliParse
[[ $? -eq 0 ]] || 
{
	ldcConioDebugL "CliError" "cliParameterParse failed"
	ldcErrorExitScript "CliError"
}

[[ ${ldccli_Errors} -eq 0 ]] ||
 {
	ldcConioDebugL "CliError" "cliErrors = ${ldccli_Errors}, param = ${ldccli_paramErrors}, cmnd = ${ldccli_cmndErrors}"
	ldcErrorExitScript "CliError"
 }

ldcCliApply
[[ $? -eq 0 ]] || 
 {
	ldcConioDebugL "CliError" "ldcCliApply failed: $?"
	ldcErrorExitScript "CliError"
 }

echo "Init ldcHelp"

ldcHelpInit ${ldcapp_help}
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugL "HelpError" "Help init failed."
	ldcErrorExitScript "HelpError"
 }

echo "ldcHelp inited"

