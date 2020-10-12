#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testXmlParser.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 02-28-2016.
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
#    	External Scripts
#
# *******************************************************
# *******************************************************

. ../lib/lmsCli.bash
. ../lib/lmsConio.bash
. ../lib/lmsError.bash
. ../lib/lmsScriptName.bash
. ../lib/setupErrorCodes.bash
. ../lib/lmsDeclare.bash
. ../lib/stackExternal.bash
. ../lib/lmsStr.bash
. ../lib/varsFromXml.bash
. ../lib/xmlParser.bash

# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************

declare -i sizeOfStack=0
declare -i currentStackSize=0
declare poppedItem=""

# *******************************************************
#
#	showXmlData
#
#		Show the xml data element selected
#
# *******************************************************
showXmlData()
{
	local content

	lmsConioDisplay ""
	lmsConioDisplay "XML_ENTITY   : '${XML_ENTITY}'"

	lmsStrTrim "${XML_CONTENT}" XML_CONTENT

	lmsConioDisplay "XML_CONTENT  :     '${XML_CONTENT}'"
	lmsConioDisplay "XML_TAG_NAME :     '${XML_TAG_NAME}'"
	lmsConioDisplay "XML_TAG_TYPE :     '${XML_TAG_TYPE}'"

	lmsStrTrim "${XML_COMMENT}" XML_COMMENT

	lmsConioDisplay "XML_COMMENT  :     '${XML_COMMENT}'"
	lmsConioDisplay "XML_path     :     '${XML_PATH}'"
}

# *******************************************************
#
#	indentDisplay
#
#		indent the display message by 4 * levels spaces
#
# *******************************************************
indentDisplay()
{
	local -i levels

	lmsConioDebug "indentDisplay" "levels = ${1}"

	let levels=${1}-1

	lmsConioDebug "indentDisplay" "indent levels = ${1}"

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
	indentDisplay ${1}
	lmsConioDisplay "${2}"
}

# *******************************************************
#
#	buildDataTable
#
# *******************************************************
buildDataTable()
{
	case $XML_TAG_TYPE in

		"OPEN")
			stack_push global "${XML_TAG_NAME}"
			stack_size global sizeOfStack

			lmsConioDebug "buildDataTable" "sizeOfStack: ${sizeOfStack}"
			testLmsRDomShowStruc $sizeOfStack "${XML_TAG_NAME} (${XML_ENTITY})"

			currentStackSize=$sizeOfStack
			;;

		"CLOSE")
			stack_pop global poppedItem
			;;

		*)
			;;
	esac
}

# *******************************************************
# *******************************************************
#
#		Start main program below here
#
# *******************************************************
# *******************************************************

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag

lmsscr_Version="1.0"			# Application version

sizeOfStack=0
poppedItem=""

stack_new global
stack_new namespace

# *******************************************************
# *******************************************************

lmsErrorInitialize

lmsConioDisplay "*******************************************************"
lmsScriptDisplayName

#displayHelp

#lmsConioDisplay "<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>"

parse_xml "showXmlData" "../TestFiles/shellVariables.xml"
parse_xml "buildDataTable" "../TestFiles/shellVariables.xml"


$LINENO "EndOfTest"
