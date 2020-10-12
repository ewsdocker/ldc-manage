#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsRlmsDomD.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
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
#		Version 0.0.1 - 06-30-2016.
#				0.0.2 - 02-10-2017.
#				0.0.3 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsRDOMDoc"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.3"							# script version
lmstst_Declarations="$lmsbase_dirEtc/testVariables.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $lmsbase_dirLib/testDump.sh
. $lmsbase_dirLib/testUtilities.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *******************************************************
#
#	testLmsRDomShowXML
#
#		Show the xml data element selected
#
# *******************************************************
testLmsRDomShowXML()
{
	local content

	lmsConioDisplay ""
	lmsConioDisplay "XML_ENTITY    : '${lmsxml_Entity}'"

	lmsStrTrim "${lmsxml_Content}" lmsxml_Content

	lmsConioDisplay "XML_CONTENT   :     '${lmsxml_Content}'"

	lmsConioDisplay "XML_TAG_NAME  :     '${lmsxml_TagName}'"
	lmsConioDisplay "XML_TAG_TYPE  :     '${lmsxml_TagType}'"

	if [[ "${lmsxml_TagType}" == "OPEN" || "${lmsxml_TagType}" == "OPENCLOSE" ]]
	then
		if [ -n "${lmsxml_Attributes}" ]
		then
			lmsRDomParseAtt

			lmsConioDisplay "XML_ATT_COUNT :     '${#lmsxml_AttributesArray[@]}'"
		
			for attribute in "${!lmsxml_AttributesArray[@]}"
			do
				lmsConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				lmsConioDisplay "XML_ATT_VAL   :     '${lmsxml_AttributesArray[$attribute]}'"
				
			done
		fi
	fi

	lmsStrTrim "${lmsxml_Comment}" lmsxml_Comment

	lmsConioDisplay "XML_COMMENT   :     '${lmsxml_Comment}'"
	lmsConioDisplay "XML_PATH      :     '${lmsxml_Path}'"

	lmsConioDisplay "XPATH         :     '${lmsxml_XPath}'"
}

# *******************************************************
#
#	testLmsRDomIndent
#
#		indent the display message by 4 * levels spaces
#
# *******************************************************
function testLmsRDomIndent()
{
	local -i levels

	let levels=${1}-1

	while (( $levels > 0 ))
	do
		lmsConioDisplay "    " n
		let levels-=1
	done
}

# *******************************************************
#
#	testLmsRDomShowStruc
#
# *******************************************************
testLmsRDomShowStruc()
{
	testLmsRDomIndent ${1}
	lmsConioDisplay "${2}"
}

# *******************************************************
#
#	testLmsRDomTable
#
# *******************************************************
testLmsRDomTable()
{
	case $lmsxml_TagType in

		"OPEN")
			lmsStackWrite global "${lmsxml_TagName}"
			lmsStackSize global lmstst_sizeOfStack

			testLmsRDomShowStruc $lmstst_sizeOfStack "${lmsxml_TagName} (${lmsxml_Entity})"

			lmstst_currentStackSize=$lmstst_sizeOfStack
			;;

		"CLOSE")
			lmsStackRead global lmstst_item
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

lmscli_optDebug=1
lmscli_optQueueErrors=0

lmstst_sizeOfStack=0
lmstst_item=""

lmsStackCreate "global" lmstst_guid 8
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "Debug" "StackCreate Unable to open/create stack 'global'"
 }

lmsStackCreate "namespace" lmstst_nsuid 8
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "Debug" "StackCreate Unable to open/create stack 'namespace'"
 }

# *******************************************************

lmsRDomCallback "testLmsRDomShowXML" 
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "RDomError" "Callback function name is missing"
 }

lmsRDomParse ${lmstst_Declarations}
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "RDomError" "TDOMParseDOM '${lmstst_Declarations}'"
 }

lmsConioDisplay "*******************************************************"

# *******************************************************

lmsRDomCallback "testLmsRDomTable" 
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "RDomError" "Callback function name is missing"
 }

lmsRDomParse ${lmstst_Declarations}
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "RDomError" "TDOMParseDOM '${lmstst_Declarations}'"
 }

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
