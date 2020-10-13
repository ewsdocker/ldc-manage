#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcError.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage tests
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
#	Licensed under the GNU General Public License, GPL-3.0-or-later.
#
#   This file is part of ewsdocker/ldc-bash.
#
#   ewsdocker/ldc-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/ldc-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/ldc-bash.  If not, see 
#   <http://www.gnu.org/licenses/>.
#
# *****************************************************************************
#
#			Version 0.0.1 - 02-22-2016.
#					0.0.2 - 03-18-2016.
#					0.1.0 - 01-11-2017.
#					0.1.1 - 01-24-2017.
#					0.1.2 - 02-23-2017.
#					0.1.3 - 08-27-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcError"
declare    ldclib_bashRelease="0.1.3"

# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh
source $ldcbase_dirAppLib/cliOptions.sh
source $ldcbase_dirAppLib/commonVars.sh

source $ldcbase_dirLib/ldcSortArray.sh

# *****************************************************************************

ldcscr_Version="0.1.3"					# script version

declare    ldctst_errorNumber=0
declare    ldcapp_declare="$ldcbase_dirEtc/cliOptions.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $ldcbase_dirTestLib/testDump.sh

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

source $ldcbase_dirAppLib/openLog.sh
source $ldcbase_dirAppLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

ldcConioDisplay " "
ldctst_errorName="QueuePop"

ldcConioDisplay "ldcErrorLookupName '${ldctst_errorName}'"

ldcErrorLookupName "QueuePop"
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "ldcErrorLookupName failed for QueuePop"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay "$ldcerr_name = '$ldcerr_message'"

# *****************************************************************************

ldctst_errorNumber=20

ldcConioDisplay ""
ldcConioDisplay "ldcErrorLookupNumber ${ldctst_errorNumber}"

ldcErrorLookupNumber ${ldctst_errorNumber}
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "error code lookup failed"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number $ldcerr_number = $ldcerr_name"
ldcConioDisplay "    $ldcerr_message"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldctst_errorName="DOMError"

ldcConioDisplay ""
ldcConioDisplay "validErrorName '${ldctst_errorName}'"

ldcErrorValidName ${ldctst_errorName}
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "${ldctst_errorName} not found"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

# *****************************************************************************

ldctst_errorNumber=6

ldcConioDisplay " "
ldcConioDisplay "ldcErrorValidNumber '${ldctst_errorNumber}'"

ldcErrorValidNumber ${ldctst_errorNumber}
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find Error #${ldctst_errorNumber}"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number ${ldctst_errorNumber} is valid"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay " "
ldcConioDisplay "ldcErrorQuery ldcUIdExists UNFORMATTED"

ldcErrorQuery "ldcUIdExists" 0
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find ldcUIdExists"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number '${ldcerr_number}' = '${ldcerr_name}'"
ldcConioDisplay "    Error message='${ldcerr_message}'"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay "ldcErrorQuery ldcUIdExists FORMATTED"

ldcErrorQuery "ldcUIdExists" 1
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find ldcUIdExists"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number $ldcerr_number = $ldcerr_name"
ldcConioDisplay "    Error message=$ldcerr_message"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay "ldcErrorQuery 5 DEFAULT (UNFORMATTED)"

ldcErrorQuery 5
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find Error #5"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number $ldcerr_number = $ldcerr_name"
ldcConioDisplay "    Error message=$ldcerr_message"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay "ldcErrorQuery 5 FORMATTED"

ldcErrorQuery 5 1
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find ldcUIdExists"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number $ldcerr_number = $ldcerr_name"
ldcConioDisplay "    Error message=$ldcerr_message"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay "ldcErrorQuery NotRoot"

ldcErrorQuery "NotRoot"
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find NotRoot"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number $ldcerr_number = $ldcerr_name"
ldcConioDisplay "    Error message=$ldcerr_message"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay " "
ldcConioDisplay "ldcErrorQuery 22"

ldcErrorQuery 22
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "Did not find Error #22"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcConioDisplay ""
ldcConioDisplay "Error number $ldcerr_number = $ldcerr_name"
ldcConioDisplay "    Error message=$ldcerr_message"
ldcConioDisplay "-----------------------------------"

# *****************************************************************************

ldcConioDisplay " "

ldcConioDisplay "Error name KEYS"

ldcConioDisplay " "
ldcsrt_array=()

ldcDynnReset ${ldcerr_arrayName}
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "ldcDynnReset failed"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

ldcDynnReload ${ldcerr_arrayName}
[[ $? -eq 0 ]] ||
 {
	ldccli_optLogDisplay=0
	ldcLogDisplay "ldcDynnReload failed"
	testDumpExit "ldccfg_x ldctest_ ldcerr_ ldcxmp_"
 }

error=0
while [[ $ldcdyna_valid -eq 1 ]]
do
	ldcDynnKey "${ldcerr_arrayName}" index
	[[ $? -eq 0 ]] || 
	{
		error=1
		ldcLogDisplay "ldcDynnKey failed"
		break
	}

	printf -v digits "10#%04u" $index
	ldcsrt_array[${#ldcsrt_array[@]}]=$digits

	ldcDynnNext ${ldcerr_arrayName}
	[[ $? -eq 0 ]] ||
	 {
		error=2
		ldcLogDisplay "ldcDynnNext failed"
		break
	 }

	ldcDynn_Valid
	ldcdyna_valid=$?
done

[[ $error -eq 0 ]] &&
{
	ldcSortArrayBubble
	ldcUtilATS $ldcsrt_array ldctst_buffer
	ldcConioDisplay "$ldctst_buffer"
}

# *****************************************************************************

ldccli_optDebug=0

# *****************************************************************************

ldcConioDisplay "ldcErrorCodeList NAME unformatted console"

	ldcErrorCodeList 1 0 0

# *****************************************************************************

ldcConioDisplay "ldcErrorCodeList NAME unformated BUFFER"

	ldcErrorCodeList 1 0 1
	ldcConioDisplay "$ldcerr_msgBuffer"

# *****************************************************************************

ldcConioDisplay " "
ldcConioDisplay "*******************************************************"
ldcConioDisplay " "
ldcConioDisplay "NUMBER unformatted console"

	ldcErrorCodeList 0 0 0

# *****************************************************************************

ldcConioDisplay "NUMBER unformatted BUFFER"

	ldcErrorCodeList 0 0 1
	ldcConioDisplay "$ldcerr_msgBuffer"

# *****************************************************************************

ldcConioDisplay "NUMBER FORMATTED console"

	ldcErrorCodeList 0 1 0

# *****************************************************************************

ldcConioDisplay "ldcErrorCodeList NUMBER FORMATTED BUFFER"

	ldcErrorCodeList 0 1 1
	ldcConioDisplay "$ldcerr_msgBuffer"

# *****************************************************************************

ldcConioDisplay " "
ldcConioDisplay "*******************************************************"
ldcConioDisplay " "

ldcConioDisplay "ldcErrorCodeList NAME FORMATTED console"

	ldcErrorCodeList 1 1 0

# *****************************************************************************

ldcConioDisplay "ldcErrorCodeList NAME FORMATTED BUFFER"

	ldcErrorCodeList 1 1 1
	ldcConioDisplay "$ldcerr_msgBuffer"

# *****************************************************************************

source $ldcbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
