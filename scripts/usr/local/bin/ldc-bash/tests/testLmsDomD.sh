#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   testLdcDomD.sh
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

declare    ldcapp_name="testLdcDynDomD"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.1.3"					# script version
declare	   ldctst_Declarations="$ldcbase_dirEtc/testVariables.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $ldcbase_dirLib/testDump.sh

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

	ldcConioDisplay ""
	ldcConioDisplay "XML_ENTITY    : '${ldcdom_Entity}'"

	ldcStrTrim "${ldcdom_Content}" ldcdom_Content

	ldcConioDisplay "XML_CONTENT   :     '${ldcdom_Content}'"

	ldcConioDisplay "XML_TAG_NAME  :     '${ldcdom_TagName}'"
	ldcConioDisplay "XML_TAG_TYPE  :     '${ldcdom_TagType}'"

	[[ "${ldcdom_TagType}" == "OPEN" || "${ldcdom_TagType}" == "OPENCLOSE" ]] &&
	 {
		[[ -n "${ldcdom_attribs}" ]] &&
		 {
			ldcDomDParseAtt

			ldcConioDisplay "XML_ATT_COUNT :     '${ldcdom_attribCount}'"
		
			for attribute in "${!ldcdom_attArray[@]}"
			do
				ldcConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				ldcConioDisplay "XML_ATT_VAL   :     '${ldcdom_attArray[$attribute]}'"
				
			done
		 }
	 }

	ldcStrTrim "${ldcdom_Comment}" ldcdom_Comment

	ldcConioDisplay "XML_COMMENT   :     '${ldcdom_Comment}'"
	ldcConioDisplay "XML_PATH      :     '${ldcdom_Path}'"

	ldcConioDisplay "XPATH         :     '${ldcdom_XPath}'"
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
		ldcConioDisplay "    " n
		(( levels-- ))
	done
}

# *******************************************************
#
#	testLdcRDomShowStruc
#
# *******************************************************
testLdcRDomShowStruc()
{
	testIndentDisplay ${1}
	ldcConioDisplay "${2}"
}

# *******************************************************
#
#	testBuildDataTable
#
# *******************************************************
testBuildDataTable()
{
	case $ldcdom_TagType in

		"OPEN")
			ldcStackWrite global "${ldcdom_TagName}"
			ldcStackSize global ldctst_sizeOfStack

			testLdcRDomShowStruc $ldctst_sizeOfStack "${ldcdom_TagName} (${ldcdom_Entity})"

			ldctst_currentStackSize=$ldctst_sizeOfStack
			;;

		"CLOSE")
			ldcStackRead global ldctst_Item
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

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************
ldccli_optDebug=0
ldccli_optQueueErrors=0
ldccli_optLogDisplay=0

# *****************************************************************************

ldctst_sizeOfStack=0
ldctst_Item=""

ldcStackCreate "global" ldctst_guid 8
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "StackCreate Unable to open/create stack 'global'"
	testDumpExit
 }

ldcStackCreate "namespace" ldctst_nsuid 8
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "StackCreate Unable to open/create stack 'namespace'"
 	testDumpExit
 }

# *****************************************************************************

ldcDomDCallback "testShowXmlData" 
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Callback function name is missing"
 	testDumpExit
 }

ldcDomDParse ${ldctst_Declarations}
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "TDOMParseDOM '${ldctst_Declarations}'"
	testDumpExit	
 }

ldcConioDisplay "*******************************************************"

ldcDomDCallback "testBuildDataTable" 
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Callback function name is missing"
	testDumpExit
 }

ldcDomDParse ${ldctst_Declarations}
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "TDOMParseDOM '${ldctst_Declarations}'"
 	testDumpExit
 }

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
