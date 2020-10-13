#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcRDomXPathN.sh
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

declare    ldcapp_name="testLdcRDomXPathN"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.0.3"				# script version
declare	   ldctst_Declarations="$ldcbase_dirEtc/testVariables.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $ldcbase_dirLib/testDump.sh
. $ldcbase_dirLib/testUtilities.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *******************************************************
#
#	testLdcRDomXPNSet
#
#
# *******************************************************
testLdcRDomXPNSet()
{
	ldcConioDisplay ""
	ldcConioDisplay "XML_ENTITY    : '${ldcxml_Entity}'"

	ldcStrTrim "${ldcxml_Content}" ldcxml_Content

	ldcConioDisplay "XML_CONTENT   :     '${ldcxml_Content}'"

	ldcConioDisplay "XML_TAG_NAME  :     '${ldcxml_TagName}'"
	ldcConioDisplay "XML_TAG_TYPE  :     '${ldcxml_TagType}'"

	if [[ "${ldcxml_TagType}" == "OPEN" || "${ldcxml_TagType}" == "OPENCLOSE" ]]
	then
		if [ -n "${ldcxml_Attributes}" ]
		then
			ldcRDomParseAtt

			ldcConioDisplay "XML_ATT_COUNT :     '${#ldcxml_AttributesArray[@]}'"
		
			for attribute in "${!ldcxml_AttributesArray[@]}"
			do
				ldcConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				ldcConioDisplay "XML_ATT_VAL   :     '${ldcxml_AttributesArray[$attribute]}'"
				
			done
		fi
	fi

	ldcStrTrim "${ldcxml_Comment}" ldcxml_Comment

	ldcConioDisplay "XML_COMMENT   :     '${ldcxml_Comment}'"
	ldcConioDisplay "XML_PATH      :     '${ldcxml_Path}'"

	ldcConioDisplay "XPATH         :     '${ldcxml_XPath}'"
}

# *******************************************************
#
#	testLdcRDomXPNData
#
#		Show the xml data element selected
#
# *******************************************************
testLdcRDomXPNData()
{
	local content

	ldcConioDisplay ""
	ldcConioDisplay "XML_ENTITY    : '${ldcxml_Entity}'"

	ldcStrTrim "${ldcxml_Content}" ldcxml_Content

	ldcConioDisplay "XML_CONTENT   :     '${ldcxml_Content}'"

	ldcConioDisplay "XML_TAG_NAME  :     '${ldcxml_TagName}'"
	ldcConioDisplay "XML_TAG_TYPE  :     '${ldcxml_TagType}'"

	if [[ "${ldcxml_TagType}" == "OPEN" || "${ldcxml_TagType}" == "OPENCLOSE" ]]
	then
		if [ -n "${ldcxml_Attributes}" ]
		then
			ldcRDomParseAtt

			ldcConioDisplay "XML_ATT_COUNT :     '${#ldcxml_AttributesArray[@]}'"
		
			for attribute in "${!ldcxml_AttributesArray[@]}"
			do
				ldcConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				ldcConioDisplay "XML_ATT_VAL   :     '${ldcxml_AttributesArray[$attribute]}'"
				
			done
		fi
	fi

	ldcStrTrim "${ldcxml_Comment}" ldcxml_Comment

	ldcConioDisplay "XML_COMMENT   :     '${ldcxml_Comment}'"
	ldcConioDisplay "XML_PATH      :     '${ldcxml_Path}'"

	ldcConioDisplay "XPATH         :     '${ldcxml_XPath}'"
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

ldcStackCreate "global" ldctst_guid 8
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugExit $LINENO "Debug" "StackCreate Unable to open/create stack 'global'"
 }

ldcStackCreate "namespace" ldctst_nsuid 8
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugExit $LINENO "Debug" "StackCreate Unable to open/create stack 'namespace'"
 }

# *******************************************************

if [[ $showData -ne 0 ]]
then
	ldcRDomCallback "testLdcRDomXPNData" 
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebugExit $LINENO "RDomError" "Callback function name is missing"
	 }

	ldcRDomParseDOM ${ldctst_Declarations}
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDebugExit $LINENO "RDomError" "TDOMParseDOM '${ldctst_Declarations}'"
	 }

	ldcConioDisplay "*******************************************************"

fi

# *******************************************************

ldcRDomCallback "ldcRDomXPathN" 
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugExit $LINENO "RDomError" "Callback function name is missing"
 }

ldcRDomParse ${ldctst_Declarations}
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugExit $LINENO "RDomError" "TDOMParseDOM '${ldctst_Declarations}'"
 }

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************

