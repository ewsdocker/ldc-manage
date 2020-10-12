# *****************************************************************************
# *****************************************************************************
#
#   lmsScriptName.sh
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
#
#			Version 0.0.1 - 02-24-2016.
#			        0.0.2 - 03-18-2016.
#					0.1.0 - 01-24-2017.
#					0.1.1 - 02-09-2017.
#
# *****************************************************************************
# *****************************************************************************

declare -r lmslib_lmsScriptName="0.1.3"	# version of lmsscr_Name library

declare lmsscr_Directory=""			# script directory
declare lmsscr_Path=""				# script path
declare lmsscr_Name=""				# script name
declare lmsscr_Version="0.0.1"		# main script version

# *****************************************************************************
#
#    lmsScriptFileName
#
#		set the global lmsscr_Name to the base name of this script
#
# *****************************************************************************
lmsScriptFileName()
{
	lmsscr_Directory=$PWD
	lmsscr_Path=$(dirname "$0")
	lmsscr_Name=$(basename "$1" .sh)
}

# *****************************************************************************
#
#    lmsScriptDisplayName
#
#		display the script name and version of this script
#
# *****************************************************************************
lmsScriptDisplayName()
{
	lmsScriptFileName $0
	lmsConioDisplay " "
	lmsConioDisplay "$(tput bold ; tput setaf 1)${lmsscr_Name} version ${lmsscr_Version}$(tput sgr0)"
}

