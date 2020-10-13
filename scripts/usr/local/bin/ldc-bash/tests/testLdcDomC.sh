#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLdcDomC.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.4
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage DOMDocument
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
#			Version 0.0.1 - 09-06-2016.
#					0.0.2 - 02-15-2017.
#					0.0.3 - 02-23-2017.
#					0.0.4 - 09-07-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcDomC"

# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh

source $ldcbase_dirAppLib/cliOptions.sh
source $ldcbase_dirAppLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.0.4"						# script version

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

ldctst_Declarations="$ldcbase_dirEtc/testDeclarations.xml"

echo "ldctst_Declarations: ${ldctst_Declarations}"

ldcDomCLoad ${ldctst_Declarations} "ldctst_stack" 1
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "DomError - ldcDomCLoad failed."
	testDumpExit "ldcdom_ ldctst_ ldcstk ldccli"
 }

testDumpExit "ldcdom_ ldctest_ ldctst_ ldcstk ldccli ldchlp_"

# *****************************************************************************

source $ldcbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
