#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   testLmsCli.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.0
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package lms-bash
# @subpackage tests
#
# ***************************************************************************************************
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
# ***************************************************************************************************
#
#			Version 0.0.1 - 02-24-2016.
#					0.0.2 - 07-01-2016.
#					0.1.0 - 01-17-2017.
#					0.1.1 - 01-23-2017.
#					0.1.2 - 02-11-2017.
#					0.1.3 - 02-23-2017.
#                   0.2.0 - 08-24-2018.
#
# ***************************************************************************************************
# ***************************************************************************************************

declare    lmsapp_name="testLmsCli"

# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh

source $lmsbase_dirAppLib/cliOptions.sh
source $lmsbase_dirAppLib/commonVars.sh

# *****************************************************************************

declare    lmsscr_Version="0.2.0"	# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $lmsbase_dirTestLib/testDump.sh
source $lmsbase_dirTestLib/testUtilities.sh

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

lmscli_optDebug=0
lmscli_optQueueErrors=0
lmscli_Errors=0

lmscli_optLogDisplay=1
lmscli_optSilent=0

# *****************************************************************************

lmstst_buffer=""

lmsConioDisplay ""
lmsUtilATS "lmscli_shellParam" lmstst_buffer
lmsConioDisplay "$lmstst_buffer"

lmsConioDisplay ""
lmsUtilATS "lmscli_InputParam" lmstst_buffer
lmsConioDisplay "$lmstst_buffer"

lmsConioDisplay ""
testLmsDmpVar "lmscli_"
lmsConioDisplay ""

# *****************************************************************************

source $lmsbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
