# **************************************************************************
# **************************************************************************
#
#   lmsStartup.sh
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

declare -r lmslib_lmsStartup="0.1.1"	# version of the library

# **************************************************************************

declare    lmscli_Validate=0

# **************************************************************************
#
#	lmsStartupInit start-up initialization
#
#	parameters:
#		lmsscr_Version = string representing the current script version
#		xmlErrorCodes = path to the errorCode.xml file
#
#	returns:
#		$? = value returned from lmsCliParse function.
#
# **************************************************************************
lmsStartupInit()
{
	lmsScriptFileName "${0}"

	lmsscr_Version=${1:-"0.0.1"}
	local xmlErrorCodes="${2}"

	lmsScriptDisplayName
	lmsConioDisplay ""

	lmsErrorInitialize "lmsErrors" "${xmlErrorCodes}"
	[[ $? -eq 0 ]] ||
	 {
		[[ ${lmsdyna_valid} -eq 0  &&  ${lmserr_result} -eq 0  ]] ||
		 {
			lmsConioDebugL "DebugError" "Unable to load error codes from ${xmlErroCodes} : $?."
			return 1
		 }
	 }

#	lmsErrorQInit "errorQueueStack"
#	[[ $? -eq 0 ]] ||
#	 {
#		lmsConioDebugL "QueueInit"  "Unable to initialize error queue: $?"
#		return 3
#	 }

	[[ ${#lmscli_ParamBuffer} -eq 0 ]] && lmscli_command="help"
	return 0
}


