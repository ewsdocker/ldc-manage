#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLmsColorDef.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package lms-bash
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
#			Version 0.0.1 - 06-19-2016.
#					0.0.2 - 02-09-2017.
#					0.0.3 - 08-24-2018.
#
# *****************************************************************************
# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh
source $lmsbase_dirAppLib/cliOptions.sh

source $lmsbase_dirAppLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.3"					# script version

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

source $lmsbase_dirAppLb/openLog.sh
source $lmsbase_dirAppLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

lmsConioDisplay "${lmsclr_Red}RED${lmsclr_NoColor}"
lmsConioDisplay "${lmsclr_Bold}${lmsclr_Red}BOLD RED${lmsclr_NoColor}"
lmsConioDisplay ""

lmsConioDisplay "${lmsclr_Purple}PURPLE${lmsclr_NoColor}"
lmsConioDisplay "${lmsclr_Bold}${lmsclr_Purple}BOLD PURPLE${lmsclr_NoColor}"
lmsConioDisplay ""

lmsConioDisplay "${lmsclr_Blue}BLUE${lmsclr_NoColor}"
lmsConioDisplay "${lmsclr_Bold}${lmsclr_Blue}BOLD BLUE${lmsclr_NoColor}"
lmsConioDisplay ""

lmsConioDisplay "no color"

# *****************************************************************************

source $testlibDir/scriptEnd.sh

# *****************************************************************************
