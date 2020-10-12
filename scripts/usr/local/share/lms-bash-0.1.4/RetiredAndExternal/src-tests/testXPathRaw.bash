#!/bin/bash

# *******************************************************
# *******************************************************
#
#   testLmsXPath.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 06-02-2016.
#					0.0.2 - 06-16-2016.
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

declare -i lmscli_optProduction=1

if [ $lmscli_optProduction -eq 0 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/lms/bash"
	etcDir="$rootDir/etc/lms"
else
	rootDir="$PWD/../.."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/arraySort.bash
. $libDir/runtimeUser.bash
. $libDir/lmsConio.bash
. $libDir/lmsCli.bash
. $libDir/lmsDynNode.bash
. $libDir/lmsDynArray.bash
. $libDir/lmsError.bash
. $libDir/errorQueueDisplay.bash
. $libDir/lmsErrorQ.bash
. $libDir/lmsHelp.bash
. $libDir/lmsScriptName.bash
. $libDir/lmsDeclare.bash
. $libDir/lmsStack.bash
. $libDir/lmsStartup.bash
. $libDir/lmsStr.bash
. $libDir/lmsUId
. $libDir/lmsXMLParse
. $libDir/lmsXPath.bash

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************

lmsscr_Version="0.0.2"					# script version
lmsvar_errors="$etcDir/errorCodes.xml"		# path to the error codes file
lmsvar_help="$etcDir/testHelp.xml"			# path to the help information file

# *******************************************************
# *******************************************************
#
#		Start main program functions below here
#
# *******************************************************
# *******************************************************

# ******************************************************************************
#
#	lmsXPathQuery
#
#		execute a query and set the lmsxp_QueryResult value
#
#	parameters:
#		query = query to execute
#		raw = 0 ==> process query as is, 1 ==> apply current cd before processing
#
#	outputs:
#		result = query result
#
#	returns:
#		0 => no error
#		1 => query error
#
# ******************************************************************************
function XQuery()
{
	local query="${1}"

	if [ -z "${query}" ]
	then
		lmsErrorQWrite $LINENO "XPathError" "Empty XPath query"
		echo "NO XPath query provided"
		return 1
	fi

	lmsxp_Query=${query}
	lmsxp_QueryResult=""
	lmsxp_Result=0

	lmsxp_QueryResult=$( echo "cat ${lmsxp_Query}" | ${lmsxp_Xmllint} --shell "${lmsxp_FileName}"  | grep -v "/ >" )
	#lmsxp_QueryResult=$( echo "cat $query" | "${lmsxp_Xmllint}" --shell "${lmsxp_FileName}"  | grep -v "/ >" )
shellVarDump
exit 1

	#lmsxp_QueryResult=$( "${lmsxp_Xmllint}" --xpath ${query} ${lmsxp_FileName} )

echo "xpQueryResult = $lmsxp_QueryResult"
exit 1

	[[ $? -eq 0 ]] ||
	 {
		lmsxp_Result=$?
		lmsErrorQWriteX $LINENO "XPathInfo" "XPath query failed: $?"
		echo "XPath query failelmsxp_Qd: $?"
		return $?
	 }

	[[ -z "${lmsxp_QueryResult}" ]] &&
	 {
		lmsErrorQWriteX $LINENO "XPathInfo"  "XPath query returned empty result"
		echo "XPath query returned empty result"
		return 1
	 }

	echo "${lmsxp_QueryResult}"
	return 0
}

# *******************************************************
# *******************************************************
#
#		Start main program script below here
#
# *******************************************************
# *******************************************************

declare -i ec

lmsConioDisplay "*******************************************"

lmsErrorQInit
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "Unable to initialize error queue."
	exit 1
 }

lmsConioDisplay ""

lmsXPathInit "help" "$etcDir/shellHelp.xml"
[[ $? -eq 0 ]] ||
 {
	let ec=$?+1
	lmsConioDisplay "lmsXPathInit failed."
	exit $ec
 }

XQuery "/lms/help/options/var"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "lmsXPathInit failed."
	exit 4
 }

lmsConioDisplay "QueryResult: ${lmsxp_QueryResult}"

XQuery "//@name"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "XQuery failed"
	exit 5
 }

lmsConioDisplay "QueryResult: ${lmsxp_QueryResult}"

XQuery "options"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "XQuery failed"
	exit 6
 }

lmsConioDisplay "QueryResult: ${lmsxp_QueryResult}"

XQuery "//lms/options/installOptions"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "XQuery failed"
	exit 7
 }

lmsConioDisplay "QueryResult: ${lmsxp_QueryResult}"

lmsConioDisplay "*******************************************"

exit 0

# *********************************************************

declare -i errorCount=0

lmsErrorQErrors errorCount
if [ $? -ne 0 ]
then
	lmsErrorQWrite $LINENO "QueuePop"  "Reading error queue size: $?"
	let errorCount+=1
fi

if [ $errorCount -gt 0 ]
then
	lmsConioDisplay "${errorCount} error(s)."

	lmsErrorQDispPop 1
	lmsErrorExitScript "EndInError"
fi

lmsErrorExitScript "EndOfTest"

