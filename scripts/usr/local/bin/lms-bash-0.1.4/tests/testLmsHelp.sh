#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   testHelpFunctions.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
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
#		Version 0.0.1 - 06-09-2016.
#				0.0.2 - 01.09-2017.
#				0.1.0 - 01-29-2017.
#				0.1.1 - 02-23-2017.
#				0.1.2 - 09-06-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="testLmsHelp"
declare    lmslib_bashRelease="0.1.3"

# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh

source $lmsbase_dirAppLib/cliOptions.sh
source $lmsbase_dirAppLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.2"				# script version

lmsapp_help="$lmsbase_dirEtc/helpTest.xml"	# path to the help file
#lmsvar_help="$lmsbase_dirEtc/lmsInstallHelp.xml"	# path to the help file

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

function testLmsHelpInit()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsHelpInit '${1}'"
	lmsConioDisplay ""
	
	lmsHelpInit "${1}"
	[[ $? -eq 0 ]] ||
	{
        xError=$?
		lmsConioDisplay "lmsHelp initialize failed: error = $xError, result = $lmshlp_error"
		testDumpExit "lmshlp_"
	}
	
	return 0
}

function testLmsHelpToStrV()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsHelpToStrV"

	lmstst_buffer=""
	lmsHelpToStrV lmstst_buffer
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "lmsHelpToStrV failed: $?, result = $lmshlp_error"
		testDumpExit "lmshlp_"
	}

	lmsConioDisplay "'${lmstst_buffer}'"
	return 0
}

function testLmsHelpToStr()
{
	lmsConioDisplay ""
	lmsConioDisplay "lmsHelpToStr"

	lmstst_buffer=$( lmsHelpToStr lmstst_buffer )
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "lmsHelpToStr failed: $?, result = $lmshlp_error"
		testDumpExit "lmshlp_"
	}

	lmsConioDisplay "'${lmstst_buffer}'"
	return 0
}

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

echo "STARTING"
exit 1

lmscli_optDebug=0

testLmsHelpInit "${lmsvar_help}"

testLmsHelpToStr

lmsConioDisplay "================================="

testLmsHelpToStrV

# *****************************************************************************

source $lmsbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
