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
#			Version 0.0.3 - 08-24-2018.
#
# *****************************************************************************
# *****************************************************************************

# **************************************************************************
#
#	testLdcDmpVarStack
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
function testLdcDmpVarStack()
{
	ldcDmpVarStack
	ldcConioDisplay ""
}

# **************************************************************************
#
#	testLdcDmpVar
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
function testLdcDmpVar()
{
	local ldcVars=${1:-"ldctst_ ldccli_"}

	local varList
	ldcStrExplode "${1}" " " varList

	local varName
	for varname in "${varList[@]}"
	do
		ldcDmpVarSelected "${varname}"
		ldcConioDisplay ""
	done

	ldcConioDisplay "---------------------------"
	ldcConioDisplay ""
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
	testLdcDmpVar "${1}"
	exit 1
}

