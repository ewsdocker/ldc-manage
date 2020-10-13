#!/bin/bash
# ***************************************************************************************************
# ***************************************************************************************************
#
#   testLdcCli.sh
#
# ***************************************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.0
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package ldc-bash
# @subpackage tests
#
# ***************************************************************************************************
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

declare    ldcapp_name="testLdcCli"

# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh

source $ldcbase_dirAppLib/cliOptions.sh
source $ldcbase_dirAppLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.2.0"	# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $ldcbase_dirTestLib/testDump.sh
source $ldcbase_dirTestLib/testUtilities.sh

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

ldccli_optDebug=0
ldccli_optQueueErrors=0
ldccli_Errors=0

ldccli_optLogDisplay=1
ldccli_optSilent=0

# *****************************************************************************

ldctst_buffer=""

ldcConioDisplay ""
ldcUtilATS "ldccli_shellParam" ldctst_buffer
ldcConioDisplay "$ldctst_buffer"

ldcConioDisplay ""
ldcUtilATS "ldccli_InputParam" ldctst_buffer
ldcConioDisplay "$ldctst_buffer"

ldcConioDisplay ""
testLdcDmpVar "ldccli_"
ldcConioDisplay ""

# *****************************************************************************

source $ldcbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
