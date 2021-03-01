# **************************************************************************
# **************************************************************************
#
#   ldcStartup.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1.
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage startupFunctions
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
#
#		Version 0.0.1 - 05-21-2016.
#				0.1.0 - 01-09-2017.
#				0.1.1 - 02-09-2017.
#
# **************************************************************************
# **************************************************************************

declare -r ldclib_ldcStartup="0.1.1"	# version of the library

# **************************************************************************

declare    ldccli_Validate=0

# **************************************************************************
#
#	ldcStartupInit start-up initialization
#
#	parameters:
#		ldcscr_Version = string representing the current script version
#		xmlErrorCodes = path to the errorCode.xml file
#
#	returns:
#		$? = value returned from ldcCliParse function.
#
# **************************************************************************
ldcStartupInit()
{
	ldcScriptFileName "${0}"

	ldcscr_Version=${1:-"0.0.1"}
	local xmlErrorCodes="${2}"

	ldcScriptDisplayName
	ldcConioDisplay ""

	ldcErrorInitialize "ldcErrors" "${xmlErrorCodes}"
	[[ $? -eq 0 ]] ||
	 {
		[[ ${ldcdyna_valid} -eq 0  &&  ${ldcerr_result} -eq 0  ]] ||
		 {
			ldcConioDebugL "DebugError" "Unable to load error codes from ${xmlErroCodes} : $?."
			return 1
		 }
	 }

#	ldcErrorQInit "errorQueueStack"
#	[[ $? -eq 0 ]] ||
#	 {
#		ldcConioDebugL "QueueInit"  "Unable to initialize error queue: $?"
#		return 3
#	 }

	[[ ${#ldccli_ParamBuffer} -eq 0 ]] && ldccli_command="help"
	return 0
}

# **************************************************************************
# **************************************************************************

