#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   testLmsDomD.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage tests
#
# ***************************************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# ***************************************************************************************************
#
#			Version 0.0.1 - 06-30-2016.
#					0.1.0 - 01-17-2017.
#					0.1.1 - 01-30-2017.
#					0.1.2 - 02-10-2017.
#					0.1.3 - 02-23-2017.
#
# ***************************************************************************************************
# ***************************************************************************************************

declare    lmsapp_name="testLmsDynDomD"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

declare    lmsscr_Version="0.1.3"					# script version
declare	   lmstst_Declarations="$lmsbase_dirEtc/testVariables.xml"

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
#	testShowXmlData
#
#		Show the xml data element selected
#
# *******************************************************
function testShowXmlData()
{
	local content

	lmsConioDisplay ""
	lmsConioDisplay "XML_ENTITY    : '${lmsdom_Entity}'"

	lmsStrTrim "${lmsdom_Content}" lmsdom_Content

	lmsConioDisplay "XML_CONTENT   :     '${lmsdom_Content}'"

	lmsConioDisplay "XML_TAG_NAME  :     '${lmsdom_TagName}'"
	lmsConioDisplay "XML_TAG_TYPE  :     '${lmsdom_TagType}'"

	[[ "${lmsdom_TagType}" == "OPEN" || "${lmsdom_TagType}" == "OPENCLOSE" ]] &&
	 {
		[[ -n "${lmsdom_attribs}" ]] &&
		 {
			lmsDomDParseAtt

			lmsConioDisplay "XML_ATT_COUNT :     '${lmsdom_attribCount}'"
		
			for attribute in "${!lmsdom_attArray[@]}"
			do
				lmsConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				lmsConioDisplay "XML_ATT_VAL   :     '${lmsdom_attArray[$attribute]}'"
				
			done
		 }
	 }

	lmsStrTrim "${lmsdom_Comment}" lmsdom_Comment

	lmsConioDisplay "XML_COMMENT   :     '${lmsdom_Comment}'"
	lmsConioDisplay "XML_PATH      :     '${lmsdom_Path}'"

	lmsConioDisplay "XPATH         :     '${lmsdom_XPath}'"
}

# *******************************************************
#
#	testIndentDisplay
#
#		indent the display message by 4 * levels spaces
#
# *******************************************************
function testIndentDisplay()
{
	local -i levels=${1}

	(( levels-- ))

	while [[ $levels -gt 0 ]]
	do
		lmsConioDisplay "    " n
		(( levels-- ))
	done
}

# *******************************************************
#
#	testLmsRDomShowStruc
#
# *******************************************************
testLmsRDomShowStruc()
{
	testIndentDisplay ${1}
	lmsConioDisplay "${2}"
}

# *******************************************************
#
#	testBuildDataTable
#
# *******************************************************
testBuildDataTable()
{
	case $lmsdom_TagType in

		"OPEN")
			lmsStackWrite global "${lmsdom_TagName}"
			lmsStackSize global lmstst_sizeOfStack

			testLmsRDomShowStruc $lmstst_sizeOfStack "${lmsdom_TagName} (${lmsdom_Entity})"

			lmstst_currentStackSize=$lmstst_sizeOfStack
			;;

		"CLOSE")
			lmsStackRead global lmstst_Item
			;;

		*)
			;;
	esac
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************
lmscli_optDebug=0
lmscli_optQueueErrors=0
lmscli_optLogDisplay=0

# *****************************************************************************

lmstst_sizeOfStack=0
lmstst_Item=""

lmsStackCreate "global" lmstst_guid 8
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "StackCreate Unable to open/create stack 'global'"
	testDumpExit
 }

lmsStackCreate "namespace" lmstst_nsuid 8
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "StackCreate Unable to open/create stack 'namespace'"
 	testDumpExit
 }

# *****************************************************************************

lmsDomDCallback "testShowXmlData" 
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "Callback function name is missing"
 	testDumpExit
 }

lmsDomDParse ${lmstst_Declarations}
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "TDOMParseDOM '${lmstst_Declarations}'"
	testDumpExit	
 }

lmsConioDisplay "*******************************************************"

lmsDomDCallback "testBuildDataTable" 
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "Callback function name is missing"
	testDumpExit
 }

lmsDomDParse ${lmstst_Declarations}
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "TDOMParseDOM '${lmstst_Declarations}'"
 	testDumpExit
 }

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
