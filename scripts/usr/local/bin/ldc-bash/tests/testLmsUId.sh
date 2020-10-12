#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsUId
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.4
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
#		Version 0.0.1 - 03-05-2016.
#				0.0.2 - 06-27-2016.
#				0.0.3 - 02-09-2017.
#				0.0.4 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsUId"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.4"					# script version

declare    lmstst_uid=""
declare -i lmstst_uidLength=12
declare -i lmstst_idsNeeded=64

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

lmscli_optDebug=1				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0				# (b) Batch mode - missing parameters fail
lmscli_optOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag
lmscli_optNoReset=0				# not automatic reset of lmscli_optOverride if 1

# *****************************************************************************

while [ ${#lmsuid_Unique[@]} -lt $lmstst_idsNeeded ]
do
	lmsUIdUnique lmstst_uid ${lmstst_uidLength}
	[[ $? -eq 0 ]] || break

	printf "% 6u : %s\n" ${#lmsuid_Unique[@]} ${lmstst_uid}

done

# *****************************************************************************

lmsDmpVarUids

lmscli_optOverride=1
lmscli_optNoReset=1

lmsConioDisplay "***************************"

lmsDmpVarUids

lmsConioDisplay "***************************"

lmscli_optOverride=0
lmscli_optNoReset=0

lmsConioDisplay "Deleting unique id 5 = ${lmsuid_Unique[5]}"

lmsUIdDelete ${lmsuid_Unique[5]}

lmsDmpVarUids

lmsConioDisplay "Deleting unique id 3 = ${lmsuid_Unique[3]}"

lmsUIdDelete "${lmsuid_Unique[3]}"

lmsDmpVarUids

lmsConioDisplay ""
lmsConioDisplay "Unique id table:"
lmsConioDisplay ""

lmstst_uidList=$( declare -p lmsuid_Unique )

lmsConioDisplay "lmstst_uidList: $lmstst_uidList"
lmsConioDisplay ""

lmsStrTrimBetween "$lmstst_uidList" lmstst_uidFields "(" ")"

lmsConioDisplay "fields: $lmstst_uidFields"
lmsConioDisplay ""

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************

