#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testLdcColorDef.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package ldc-bash
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
#			Version 0.0.1 - 06-19-2016.
#					0.0.2 - 02-09-2017.
#					0.0.3 - 08-24-2018.
#
# *****************************************************************************
# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh
source $ldcbase_dirAppLib/cliOptions.sh

source $ldcbase_dirAppLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.3"					# script version

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

source $ldcbase_dirAppLb/openLog.sh
source $ldcbase_dirAppLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the tests starting here
#
# *****************************************************************************
# *****************************************************************************

ldcConioDisplay "${ldcclr_Red}RED${ldcclr_NoColor}"
ldcConioDisplay "${ldcclr_Bold}${ldcclr_Red}BOLD RED${ldcclr_NoColor}"
ldcConioDisplay ""

ldcConioDisplay "${ldcclr_Purple}PURPLE${ldcclr_NoColor}"
ldcConioDisplay "${ldcclr_Bold}${ldcclr_Purple}BOLD PURPLE${ldcclr_NoColor}"
ldcConioDisplay ""

ldcConioDisplay "${ldcclr_Blue}BLUE${ldcclr_NoColor}"
ldcConioDisplay "${ldcclr_Bold}${ldcclr_Blue}BOLD BLUE${ldcclr_NoColor}"
ldcConioDisplay ""

ldcConioDisplay "no color"

# *****************************************************************************

source $testlibDir/scriptEnd.sh

# *****************************************************************************
