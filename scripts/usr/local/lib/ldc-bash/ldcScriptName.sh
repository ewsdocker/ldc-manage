# *****************************************************************************
# *****************************************************************************
#
#   ldcScriptName.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage scriptName
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
#
#			Version 0.0.1 - 02-24-2016.
#			        0.0.2 - 03-18-2016.
#					0.1.0 - 01-24-2017.
#					0.1.1 - 02-09-2017.
#
# *****************************************************************************
# *****************************************************************************

declare -r ldclib_ldcScriptName="0.1.3"	# version of ldcscr_Name library

declare ldcscr_Directory=""			# script directory
declare ldcscr_Path=""				# script path
declare ldcscr_Name=""				# script name
declare ldcscr_Version="0.0.1"		# main script version

# *****************************************************************************
#
#    ldcScriptFileName
#
#		set the global ldcscr_Name to the base name of this script
#
# *****************************************************************************
ldcScriptFileName()
{
	ldcscr_Directory=$PWD
	ldcscr_Path=$(dirname "$0")
	ldcscr_Name=$(basename "$1" .sh)
}

# *****************************************************************************
#
#    ldcScriptDisplayName
#
#		display the script name and version of this script
#
# *****************************************************************************
ldcScriptDisplayName()
{
	ldcScriptFileName $0
	ldcConioDisplay " "
	ldcConioDisplay "$(tput bold ; tput setaf 1)${ldcscr_Name} version ${ldcscr_Version}$(tput sgr0)"
}

