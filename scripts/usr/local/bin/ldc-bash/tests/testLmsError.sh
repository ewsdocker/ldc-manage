#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLmsError.sh
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
#   This file is part of ewsdocker/lms-bash.
#
#   ewsdocker/lms-bash is free software: you can redistribute 
#   it and/or modify it under the terms of the GNU General Public License 
#   as published by the Free Software Foundation, either version 3 of the 
#   License, or (at your option) any later version.
#
#   ewsdocker/lms-bash is distributed in the hope that it will 
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
#   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ewsdocker/lms-bash.  If not, see 
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

declare    lmsapp_name="testLmsError"
declare    lmslib_bashRelease="0.1.3"

# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh
source $lmsbase_dirAppLib/cliOptions.sh
source $lmsbase_dirAppLib/commonVars.sh

source $lmsbase_dirLib/lmsSortArray.sh

# *****************************************************************************

lmsscr_Version="0.1.3"					# script version

declare    lmstst_errorNumber=0
declare    lmsapp_declare="$lmsbase_dirEtc/cliOptions.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $lmsbase_dirTestLib/testDump.sh

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

source $lmsbase_dirAppLib/openLog.sh
source $lmsbase_dirAppLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

lmsConioDisplay " "
lmstst_errorName="QueuePop"

lmsConioDisplay "lmsErrorLookupName '${lmstst_errorName}'"

lmsErrorLookupName "QueuePop"
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "lmsErrorLookupName failed for QueuePop"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay "$lmserr_name = '$lmserr_message'"

# *****************************************************************************

lmstst_errorNumber=20

lmsConioDisplay ""
lmsConioDisplay "lmsErrorLookupNumber ${lmstst_errorNumber}"

lmsErrorLookupNumber ${lmstst_errorNumber}
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "error code lookup failed"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number $lmserr_number = $lmserr_name"
lmsConioDisplay "    $lmserr_message"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmstst_errorName="DOMError"

lmsConioDisplay ""
lmsConioDisplay "validErrorName '${lmstst_errorName}'"

lmsErrorValidName ${lmstst_errorName}
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "${lmstst_errorName} not found"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

# *****************************************************************************

lmstst_errorNumber=6

lmsConioDisplay " "
lmsConioDisplay "lmsErrorValidNumber '${lmstst_errorNumber}'"

lmsErrorValidNumber ${lmstst_errorNumber}
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find Error #${lmstst_errorNumber}"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number ${lmstst_errorNumber} is valid"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay " "
lmsConioDisplay "lmsErrorQuery lmsUIdExists UNFORMATTED"

lmsErrorQuery "lmsUIdExists" 0
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find lmsUIdExists"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number '${lmserr_number}' = '${lmserr_name}'"
lmsConioDisplay "    Error message='${lmserr_message}'"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay "lmsErrorQuery lmsUIdExists FORMATTED"

lmsErrorQuery "lmsUIdExists" 1
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find lmsUIdExists"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number $lmserr_number = $lmserr_name"
lmsConioDisplay "    Error message=$lmserr_message"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay "lmsErrorQuery 5 DEFAULT (UNFORMATTED)"

lmsErrorQuery 5
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find Error #5"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number $lmserr_number = $lmserr_name"
lmsConioDisplay "    Error message=$lmserr_message"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay "lmsErrorQuery 5 FORMATTED"

lmsErrorQuery 5 1
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find lmsUIdExists"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number $lmserr_number = $lmserr_name"
lmsConioDisplay "    Error message=$lmserr_message"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay "lmsErrorQuery NotRoot"

lmsErrorQuery "NotRoot"
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find NotRoot"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number $lmserr_number = $lmserr_name"
lmsConioDisplay "    Error message=$lmserr_message"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay " "
lmsConioDisplay "lmsErrorQuery 22"

lmsErrorQuery 22
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "Did not find Error #22"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsConioDisplay ""
lmsConioDisplay "Error number $lmserr_number = $lmserr_name"
lmsConioDisplay "    Error message=$lmserr_message"
lmsConioDisplay "-----------------------------------"

# *****************************************************************************

lmsConioDisplay " "

lmsConioDisplay "Error name KEYS"

lmsConioDisplay " "
lmssrt_array=()

lmsDynnReset ${lmserr_arrayName}
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "lmsDynnReset failed"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

lmsDynnReload ${lmserr_arrayName}
[[ $? -eq 0 ]] ||
 {
	lmscli_optLogDisplay=0
	lmsLogDisplay "lmsDynnReload failed"
	testDumpExit "lmscfg_x lmstest_ lmserr_ lmsxmp_"
 }

error=0
while [[ $lmsdyna_valid -eq 1 ]]
do
	lmsDynnKey "${lmserr_arrayName}" index
	[[ $? -eq 0 ]] || 
	{
		error=1
		lmsLogDisplay "lmsDynnKey failed"
		break
	}

	printf -v digits "10#%04u" $index
	lmssrt_array[${#lmssrt_array[@]}]=$digits

	lmsDynnNext ${lmserr_arrayName}
	[[ $? -eq 0 ]] ||
	 {
		error=2
		lmsLogDisplay "lmsDynnNext failed"
		break
	 }

	lmsDynn_Valid
	lmsdyna_valid=$?
done

[[ $error -eq 0 ]] &&
{
	lmsSortArrayBubble
	lmsUtilATS $lmssrt_array lmstst_buffer
	lmsConioDisplay "$lmstst_buffer"
}

# *****************************************************************************

lmscli_optDebug=0

# *****************************************************************************

lmsConioDisplay "lmsErrorCodeList NAME unformatted console"

	lmsErrorCodeList 1 0 0

# *****************************************************************************

lmsConioDisplay "lmsErrorCodeList NAME unformated BUFFER"

	lmsErrorCodeList 1 0 1
	lmsConioDisplay "$lmserr_msgBuffer"

# *****************************************************************************

lmsConioDisplay " "
lmsConioDisplay "*******************************************************"
lmsConioDisplay " "
lmsConioDisplay "NUMBER unformatted console"

	lmsErrorCodeList 0 0 0

# *****************************************************************************

lmsConioDisplay "NUMBER unformatted BUFFER"

	lmsErrorCodeList 0 0 1
	lmsConioDisplay "$lmserr_msgBuffer"

# *****************************************************************************

lmsConioDisplay "NUMBER FORMATTED console"

	lmsErrorCodeList 0 1 0

# *****************************************************************************

lmsConioDisplay "lmsErrorCodeList NUMBER FORMATTED BUFFER"

	lmsErrorCodeList 0 1 1
	lmsConioDisplay "$lmserr_msgBuffer"

# *****************************************************************************

lmsConioDisplay " "
lmsConioDisplay "*******************************************************"
lmsConioDisplay " "

lmsConioDisplay "lmsErrorCodeList NAME FORMATTED console"

	lmsErrorCodeList 1 1 0

# *****************************************************************************

lmsConioDisplay "lmsErrorCodeList NAME FORMATTED BUFFER"

	lmsErrorCodeList 1 1 1
	lmsConioDisplay "$lmserr_msgBuffer"

# *****************************************************************************

source $lmsbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
