#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcUId
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

declare    ldcapp_name="testLdcUId"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.4"					# script version

declare    ldctst_uid=""
declare -i ldctst_uidLength=12
declare -i ldctst_idsNeeded=64

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

ldccli_optDebug=1				# (d) Debug output if not 0
ldccli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
ldccli_optBatch=0				# (b) Batch mode - missing parameters fail
ldccli_optOverride=0			# set to 1 to ldccli_optOverride the ldccli_optSilent flag
ldccli_optNoReset=0				# not automatic reset of ldccli_optOverride if 1

# *****************************************************************************

while [ ${#ldcuid_Unique[@]} -lt $ldctst_idsNeeded ]
do
	ldcUIdUnique ldctst_uid ${ldctst_uidLength}
	[[ $? -eq 0 ]] || break

	printf "% 6u : %s\n" ${#ldcuid_Unique[@]} ${ldctst_uid}

done

# *****************************************************************************

ldcDmpVarUids

ldccli_optOverride=1
ldccli_optNoReset=1

ldcConioDisplay "***************************"

ldcDmpVarUids

ldcConioDisplay "***************************"

ldccli_optOverride=0
ldccli_optNoReset=0

ldcConioDisplay "Deleting unique id 5 = ${ldcuid_Unique[5]}"

ldcUIdDelete ${ldcuid_Unique[5]}

ldcDmpVarUids

ldcConioDisplay "Deleting unique id 3 = ${ldcuid_Unique[3]}"

ldcUIdDelete "${ldcuid_Unique[3]}"

ldcDmpVarUids

ldcConioDisplay ""
ldcConioDisplay "Unique id table:"
ldcConioDisplay ""

ldctst_uidList=$( declare -p ldcuid_Unique )

ldcConioDisplay "ldctst_uidList: $ldctst_uidList"
ldcConioDisplay ""

ldcStrTrimBetween "$ldctst_uidList" ldctst_uidFields "(" ")"

ldcConioDisplay "fields: $ldctst_uidFields"
ldcConioDisplay ""

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************

