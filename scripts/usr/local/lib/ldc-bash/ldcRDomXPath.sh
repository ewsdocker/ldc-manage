# ******************************************************************************
# ******************************************************************************
#
#   	ldcRDomXPath.sh
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

declare -r ldclib_ldcRDomX="0.0.2"			# version of RDOMXPath library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -i ldcrdom_xpInitialized=0				# true if initialized (first time)

declare -a ldcrdom_xpFilter=("/")				# xpath filter array
declare    ldcrdom_xpPathCD="/"					# default path

declare    ldcrdom_xpRDOMCallback=""			#

declare    ldcrdom_xpnNamespace=""				# XPath node namespace
declare    ldcrdom_xpnCurentNode=""				# XPath current node name


# ******************************************************************************
# ******************************************************************************
#
#						Functions
#
# ******************************************************************************
# ******************************************************************************

# ******************************************************************************
#
#	ldcRDomXCD
#
#		set the query path
#
#	parameters:
#		path = the path eldcrdom_xpression to set
#
#	returns:
#		0 => no error
#		1 => query path not set
#
# ******************************************************************************
function ldcRDomXCD()
{
	local path="${1}"

	if [ -z "${path}" ]
	then
		ldcConioDebug $LINENO "RDOMXPathError" "ldcRDomXCD empty path not set"
		return 1
	fi

	ldcrdom_xpPathCD=${path}

	return 0
}

# ******************************************************************************
#
#	ldcRDomXOpen
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
function ldcRDomXOpen()
{
	local file=${1}

	ldcRDomOpen ${file}
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
		ldcConioDebug $LINENO "RDOMXPathError" "ldcRDomOpen '${file}' failed with result: ${ldcerr_result}."
		return 1
	 }
	
	return 0
}

# ******************************************************************************
#
#	ldcRDomXClose
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
function ldcRDomXClose()
{
	ldcRDomClose()
}

# ******************************************************************************
#
#	ldcRDomXInit
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
function ldcRDomXInit()
{
	local callback=${1:-"RDOMXPathFilter"}

	unset ldcrdom_xpFilter
	ldcrdom_xpFilter=()

	[[ ${ldcrdom_xpInitialized} -eq 1 ]]
	{
		ldcRDomXReset
	}

	ldcrdom_xpRDOMCallback=${ldcxml_callback}

	ldcRDomCallback ${callback}
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
		ldcConioDebug $LINENO "RDOMXPathError" "ldcRDomCallback '${callback}' failed with result: ${ldcerr_result}."
		return 1
	 }

	ldcrdom_xpInitialized=1
	
	return 0
}

# ******************************************************************************
#
#	ldcRDomXReset
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
function ldcRDomXReset()
{
	if [$ldcrdom_xpInitialized -eq 0 ]
	then
		return 0
	fi
	
	ldcrdom_xpInitialized=0

	ldcRDomCallback ${ldcrdom_xpRDOMCallback}
	[[ $? -eq 0 ]] ||
	 {
		ldcerr_result=$?
		ldcConioDebug $LINENO "RDOMXPathError" "ldcRDomCallback '${callback}' failed with result: ${ldcerr_result}."
		return 1
	 }
}

