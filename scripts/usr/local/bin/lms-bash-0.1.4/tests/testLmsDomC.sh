#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLmsDomC.sh
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
#			Version 0.0.1 - 09-06-2016.
#					0.0.2 - 02-15-2017.
#					0.0.3 - 02-23-2017.
#					0.0.4 - 09-07-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsDomC"

# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh

source $lmsbase_dirAppLib/cliOptions.sh
source $lmsbase_dirAppLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.0.4"						# script version

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

lmstst_Declarations="$lmsbase_dirEtc/testDeclarations.xml"

echo "lmstst_Declarations: ${lmstst_Declarations}"

lmsDomCLoad ${lmstst_Declarations} "lmstst_stack" 1
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "DomError - lmsDomCLoad failed."
	testDumpExit "lmsdom_ lmstst_ lmsstk lmscli"
 }

testDumpExit "lmsdom_ lmstest_ lmstst_ lmsstk lmscli lmshlp_"

# *****************************************************************************

source $lmsbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
