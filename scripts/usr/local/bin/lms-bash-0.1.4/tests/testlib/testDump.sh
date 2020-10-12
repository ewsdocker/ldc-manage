# *****************************************************************************
# *****************************************************************************
#
#   testDump.sh
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
#			Version 0.0.3 - 08-24-2018.
#
# *****************************************************************************
# *****************************************************************************

# **************************************************************************
#
#	testLmsDmpVarStack
#
#      dump call stack
#
#	parameters:
#		none
#
#	Returns
#		0 = no error
#		1 = error
#
# **************************************************************************
function testLmsDmpVarStack()
{
	lmsDmpVarStack
	lmsConioDisplay ""
}

# **************************************************************************
#
#	testLmsDmpVar
#
#      dump selected varialbes
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# **************************************************************************
function testLmsDmpVar()
{
	local lmsVars=${1:-"lmstst_ lmscli_"}

	local varList
	lmsStrExplode "${1}" " " varList

	local varName
	for varname in "${varList[@]}"
	do
		lmsDmpVarSelected "${varname}"
		lmsConioDisplay ""
	done

	lmsConioDisplay "---------------------------"
	lmsConioDisplay ""
}

# **************************************************************************
#
#	testDumpExit
#
#      dump selected varialbes and exit
#
#	parameters:
#		arrayName = name of the array to iterate
#
#	Returns
#		0 = no error
#		1 = error
#
# **************************************************************************
function testDumpExit()
{
	testLmsDmpVar "${1}"
	exit 1
}

