#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLmsDeclare.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.2.0
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage tests
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
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
#		Version 0.0.1 - 07-09-2016.
#				0.1.0 - 01-30-2017.
#				0.1.1 - 02-23-2017.
#				0.2.0 - 09-07-2018.
#
# *****************************************************************************
# *****************************************************************************

# *******************************************************
# *******************************************************
#
#    	External Scripts
#
# *******************************************************
# *******************************************************

declare    lmsapp_name="testLmsDeclare"

# *****************************************************************************

source ../applib/installDirs.sh

source $lmsbase_dirAppLib/stdLibs.sh

source $lmsbase_dirAppLib/cliOptions.sh
source $lmsbase_dirAppLib/commonVars.sh

# *****************************************************************************

declare    lmsscr_Version="0.2.0"				# script version

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
#
#	testLmsDeclareSet
#
#		Test the lmsDeclareSet functionality
#
#	parameters:
#		qName = the name of the queue to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLmsDeclareSet()
{
	lmsDeclareSet "${1}" "${2}"
	return $?
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

testLmsDeclareSet "lmscli_optMan" "myroot/man/manpage"
testLmsDmpVar "lmscli_"

# *****************************************************************************

source $lmsbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
