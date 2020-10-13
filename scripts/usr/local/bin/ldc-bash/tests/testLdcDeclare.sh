#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	testLdcDeclare.sh
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

declare    ldcapp_name="testLdcDeclare"

# *****************************************************************************

source ../applib/installDirs.sh

source $ldcbase_dirAppLib/stdLibs.sh

source $ldcbase_dirAppLib/cliOptions.sh
source $ldcbase_dirAppLib/commonVars.sh

# *****************************************************************************

declare    ldcscr_Version="0.2.0"				# script version

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

source $ldcbase_dirTestLib/testDump.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *****************************************************************************
#
#	testLdcDeclareSet
#
#		Test the ldcDeclareSet functionality
#
#	parameters:
#		qName = the name of the queue to create
#
#	Returns
#		0 = no error
#		non-zero = error code
#
# *****************************************************************************
function testLdcDeclareSet()
{
	ldcDeclareSet "${1}" "${2}"
	return $?
}

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

testLdcDeclareSet "ldccli_optMan" "myroot/man/manpage"
testLdcDmpVar "ldccli_"

# *****************************************************************************

source $ldcbase_dirAppLib/scriptEnd.sh

# *****************************************************************************
