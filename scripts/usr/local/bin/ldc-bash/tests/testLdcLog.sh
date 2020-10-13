#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcLog.sh
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

declare    ldcapp_name="testLdcLog"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.1.1"	# script version

declare    ldctst_Declarations="$ldcbase_dirEtc/ldc-testLdcLog.xml"

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

ldccli_optDebug=1

ldcLogOpen $ldctst_logName
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugExit $LINENO "LogError" "Unable to open log: $ldctst_logName" 1
 }

ldcLogMessage $LINENO "Debug" "Log message 1"

ldcLogMessage $LINENO "Debug" "Log message 2"

ldcLogMessage $LINENO "Debug" "Log message 3"

ldcLogClose

# *******************************************************

ldcLogOpen $ldctst_logName "append"
[[ $? -eq 0 ]] ||
 {
	ldcConioDebugExit $LINENO "LogError" "Unable to open log: $ldctst_logName" 1
	exit 1
 }

ldcLogMessage $LINENO "Debug" "APPENDED Log message 4"

ldcLogClose

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
