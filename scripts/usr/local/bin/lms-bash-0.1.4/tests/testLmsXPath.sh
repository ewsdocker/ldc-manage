#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsXPath.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage tests
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
#		Version 0.0.1 - 06-02-2016.
#				0.0.2 - 06-16-2016.
#				0.1.0 - 01-30-2017.
#				0.1.1 - 02-09-2017.
#				0.1.2 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsXPath"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.2"						# script version

lmsapp_errors="$lmsbase_dirEtc/errorCodes.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $lmsbase_dirLib/testDump.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *******************************************************
#
#	testLmsXPathQuery
#
#		test the performance of the XPathQQuery function
#
#	parameters:
#		query = query to execute
#		raw = 0 ==> process query as is, 1 ==> apply current cd before processing
#
#	returns:
#		0 => no error
#		1 => query error
#
# *******************************************************
function testLmsXPathQuery()
{
	local result=""

	lmsConioDisplay ""
	lmsConioDisplay " lmsXPathQuery: '${1}' '${2}'"

	lmsXPathQuery "${1}" $2
	[[ $? -eq 0 ]] ||
	 {
		echo "$(tput bold)${lmsclr_Red}lmsXPathQuery failed: '${lmsxp_Query}'$(tput sgr0)"
		testXpathExit
	 }

	lmsConioDisplay "  $(tput bold)${lmsclr_Red}'${lmsxp_QueryResult}'$(tput sgr0)"
	return 0
}

# *******************************************************
#
#	testLmsXPathCommand
#
#	parameter:
#		command = command to execute
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *******************************************************
function testLmsXPathCommand()
{
	local xCommand="${1}"
	local result=0

	lmsXPathCommand "${xCommand}"
	[[ $? -eq 0 ]] ||
	 {
		result=$?
		lmsConioDisplay "$(tput bold)${lmsclr_Red}lmsXMLParseToCmnd failed for '${xCommand}'$(tput sgr0)"
		return $result
	 }

	lmsConioDisplay "'${xCommand}' is:"
	lmsConioDisplay ""
	lmsConioDisplay "$(tput bold)${lmsclr_Red}     '${lmsxp_CommandResult}'$(tput sgr0)"
	lmsConioDisplay ""

	lmsConioDisplay "*******************************************"

	return 0
}

# ******************************************************************************
#
#	testLmsXPathInit
#
#		test the performance of the lmsXPathInit function
#
#	parameters:
#		name = internal name of the xml file
#		file = absolute path to the xml file to query
#		xmllint = (optional) path to the xmllint program
#
#	returns:
#		0 => no error
#		1 => xml file error
#		2 => xmllint error
#
# ******************************************************************************
function testLmsXPathInit()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsXPathInit: '${1}' '${2}' '${3}'"
	
	lmsXPathInit ${1} ${2} ${3}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsXPathInit failed: $lmsxp_Result"
		testXPathExit
	 }
}

# ******************************************************************************
#
#	testLmsXPathCD
#
#		set the query path
#
#	parameters:
#		path = the path expression to set
#
#	returns:
#		0 => no error
#		1 => query path not set
#
# ******************************************************************************
function testLmsXPathCD()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsXPathCD: '${1}'"
	
	lmsXPathCD "${1}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsXPathCD failed: $?"
		testXPathExit
	 }
	
	lmsConioDisplay "lmsXPathCD path = ${lmsxp_Path}"
}

# ******************************************************************************
#
#	testLmsXPathUnset
#
#		unset the requested name if found in the xpQueryFile array
#
#	parameters:
#		unsetName = name of the entry to unset
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function testLmsXPathUnset()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsXPathUnset: '${1}'"

	lmsXPathUnset "${1}"
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsXPathUnset failed: $?"
		testXPathExit
	 }

	return 0
}

# ******************************************************************************
#
#	testLmsXPathSelect
#
#		select the lmsxp_ath query file
#
#	parameters:
#		xpsName = name of the lmsxp_path query file to select
#		xpsFile = path to the query file
#
#	returns:
#		0 => no error
#		non-zero => error code
#
# ******************************************************************************
function testLmsXPathSelect()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsXPathSelect: '${1}' '${2}'"
	
	lmsXPathSelect ${1} ${2}
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "lmsXPathSelect failed: $lmsxp_Result"
		testXPathExit
	 }
}

# ******************************************************************************
#
#	testLmsXPathReset
#
#		reset query vars
#
#	parameters:
#		none
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function testLmsXPathReset()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsXPathReset"

	lmsXPathReset
}

# ******************************************************************************
#
#	testXPathExit
#
#		Common error exit point
#
#	parameters:
#		none
#
#	returns:
#		DOES NOT RETURN
#
# ******************************************************************************
function testXPathExit()
{
	lmsConioDisplay ""
	lmsConioDisplay "Exit"

	[[ $lmscli_optDebug -eq 0  &&  lmscli_optQueueErrors -ne 0 ]]  &&  lmsErrorQDispPop

	lmsConioDisplay "  Log-file: '${lmstst_logName}'"

	exit 1
}

# ******************************************************************************
#
#	testStartup
#
#		run the startup initialization in a test environment
#
#	parameters:
#		vers = script version
#		xmlErrors = error code file name
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function testStartup()
{
	lmsScriptFileName "${0}"

	lmsscr_Version=${1:-"0.0.1"}
	local xmlErrorCodes="${2}"

	lmsScriptDisplayName
	lmsConioDisplay ""

}

# ******************************************************************************
#
#	testLmsErrorInitialize
#
#
#	parameters:
#		vers = script version
#		xmlErrors = error code file name
#
#	returns:
#		0 => no error
#
# ******************************************************************************
function testLmsErrorInitialize()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsErrorInitialize '${1}'"

	lmsxp_Result=0
	lmsErrorInitialize "lmsErrors" "${1}"
	[[ $? -eq 0 ]] ||
	 {
		lmsxp_Result=$?
		[[ ${lmsdyna_valid} -eq 0  &&  ${lmserr_result} -eq 0  ]] ||
		 {
			lmsConioDisplay "Unable to load error codes from ${xmlErroCodes} : ${1}."
			testXPathExit
		 }
	 }
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

lmsScriptFileName $0
lmsScriptDisplayName
lmsConioDisplay ""

. $lmsbase_dirLib/openLog.sh
#. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

testLmsXPathReset

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathInit "shell" "$lmsbase_dirEtc/shellHelp.xml"

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathQuery "/lms/help/options/var" 0

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathQuery "//@name" 0

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathQuery "//options" 0

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathCD "/lms/help/options"

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathQuery "var" 0

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

helpName="batch"
helpCommand="string(//lms/help/options/var[@name=\"${helpName}\"]/use)"

testLmsXPathCommand ${helpCommand}

#lmsConioDisplay ""
#lmsConioDisplay "*******************************************"

helpName="lib"
helpCommand="string(//lms/help/options/var[@name=\"${helpName}\"]/use)"

testLmsXPathCommand ${helpCommand}

#lmsConioDisplay ""
#lmsConioDisplay "*******************************************"

helpName="trial"
helpCommand="string(//lms/help/options/var[@name=\"${helpName}\"]/use)"

testLmsXPathCommand ${helpCommand}

#lmsConioDisplay ""
#lmsConioDisplay "*******************************************"

testLmsErrorInitialize "${lmsapp_errors}"

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathSelect "lmsErrors" ${lmsapp_errors}

testLmsDmpVar "lmserr_"

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathUnset "shell"

testLmsDmpVar "lmserr_"

lmsConioDisplay ""
lmsConioDisplay "*******************************************"

testLmsXPathUnset "lmsErrors"

testLmsDmpVar "lmserr_"

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
