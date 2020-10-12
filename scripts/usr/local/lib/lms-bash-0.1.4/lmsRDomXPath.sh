# ******************************************************************************
# ******************************************************************************
#
#   	lmsRDomXPath.sh
#
#		Provides access to a subset of XPath queries via xmllint (in libxml2)
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage RDOMXPath
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
#			Version 0.0.1 - 07-12-2016.
#					0.0.2 - 02-10-2017.
#
# ******************************************************************************
# ******************************************************************************

declare -r lmslib_lmsRDomX="0.0.2"			# version of RDOMXPath library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -i lmsrdom_xpInitialized=0				# true if initialized (first time)

declare -a lmsrdom_xpFilter=("/")				# xpath filter array
declare    lmsrdom_xpPathCD="/"					# default path

declare    lmsrdom_xpRDOMCallback=""			#

declare    lmsrdom_xpnNamespace=""				# XPath node namespace
declare    lmsrdom_xpnCurentNode=""				# XPath current node name


# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	lmsRDomXCD
#
#		set the query path
#
#	parameters:
#		path = the path elmsrdom_xpression to set
#
#	returns:
#		0 => no error
#		1 => query path not set
#
# ******************************************************************************
function lmsRDomXCD()
{
	local path="${1}"

	if [ -z "${path}" ]
	then
		lmsConioDebug $LINENO "RDOMXPathError" "lmsRDomXCD empty path not set"
		return 1
	fi

	lmsrdom_xpPathCD=${path}

	return 0
}

# ******************************************************************************
#
#	lmsRDomXOpen
#
#		Open the RDOM xml document
#
#	parameters:
#		file = path to the RDOM document file
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function lmsRDomXOpen()
{
	local file=${1}

	lmsRDomOpen ${file}
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
		lmsConioDebug $LINENO "RDOMXPathError" "lmsRDomOpen '${file}' failed with result: ${lmserr_result}."
		return 1
	 }
	
	return 0
}

# ******************************************************************************
#
#	lmsRDomXClose
#
#		Close the current RDOM connection
#
#	parameters:
#		none
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function lmsRDomXClose()
{
	lmsRDomClose()
}

# ******************************************************************************
#
#	lmsRDomXInit
#
#		Initialize the RDOMDocument interface and set the callback filter function
#
#	parameters:
#		callback = name of the callback filter function
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsRDomXInit()
{
	local callback=${1:-"RDOMXPathFilter"}

	unset lmsrdom_xpFilter
	lmsrdom_xpFilter=()

	[[ ${lmsrdom_xpInitialized} -eq 1 ]]
	{
		lmsRDomXReset
	}

	lmsrdom_xpRDOMCallback=${lmsxml_callback}

	lmsRDomCallback ${callback}
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
		lmsConioDebug $LINENO "RDOMXPathError" "lmsRDomCallback '${callback}' failed with result: ${lmserr_result}."
		return 1
	 }

	lmsrdom_xpInitialized=1
	
	return 0
}

# ******************************************************************************
#
#	lmsRDomXReset
#
#		Reset the RDOMDocument interface, including original callback
#
#	parameters:
#		None
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# ******************************************************************************
function lmsRDomXReset()
{
	if [$lmsrdom_xpInitialized -eq 0 ]
	then
		return 0
	fi
	
	lmsrdom_xpInitialized=0

	lmsRDomCallback ${lmsrdom_xpRDOMCallback}
	[[ $? -eq 0 ]] ||
	 {
		lmserr_result=$?
		lmsConioDebug $LINENO "RDOMXPathError" "lmsRDomCallback '${callback}' failed with result: ${lmserr_result}."
		return 1
	 }
}

