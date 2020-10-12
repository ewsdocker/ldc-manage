#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLmsLog.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1
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
#			Version 0.0.1 - 08-31-2016.
#					0.0.2 - 09-15-2016.
#					0.0.3 - 12-27-2016.
#					0.1.0 - 02-09-2017.
#					0.1.1 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsLog"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

declare    lmsscr_Version="0.1.1"	# script version

declare    lmstst_Declarations="$lmsbase_dirEtc/lms-testLmsLog.xml"

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

lmscli_optDebug=1

lmsLogOpen $lmstst_logName
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "LogError" "Unable to open log: $lmstst_logName" 1
 }

lmsLogMessage $LINENO "Debug" "Log message 1"

lmsLogMessage $LINENO "Debug" "Log message 2"

lmsLogMessage $LINENO "Debug" "Log message 3"

lmsLogClose

# *******************************************************

lmsLogOpen $lmstst_logName "append"
[[ $? -eq 0 ]] ||
 {
	lmsConioDebugExit $LINENO "LogError" "Unable to open log: $lmstst_logName" 1
	exit 1
 }

lmsLogMessage $LINENO "Debug" "APPENDED Log message 4"

lmsLogClose

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
