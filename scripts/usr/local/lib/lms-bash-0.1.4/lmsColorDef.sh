#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#   	lmsColorDef.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.4
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package colorDefinitions
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
#			Version 0.0.1 - 06-19-2016.
#					0.0.2 - 01-22-2017.
#					0.0.3 - 02-09-2017.
#					0.0.4 - 08-25-2018.
#
# *****************************************************************************
# *****************************************************************************

declare -r lmslib_lmsColorDefs="0.0.4"	# version of library

# ******************************************************************************
#
#	Global declarations
#
# ******************************************************************************

declare -r lmsclr_Black="$(tput setaf 0)"
declare -r lmsclr_DarkGrey="$(tput bold ; tput setaf 0)"

declare -r lmsclr_Red="$(tput setaf 1)"
declare -r lmsclr_Lightred="$(tput bold ; tput setaf 1)"

declare -r lmsclr_Green="$(tput setaf 2)"
declare -r lmsclr_LightGreen="$(tput bold ; tput setaf 2)"

declare -r lmsclr_Yellow="$(tput setaf 3)"

declare -r lmsclr_LightBlue="$(tput bold ; tput setaf 4)"
declare -r lmsclr_Blue="$(tput setaf 4)"

declare -r lmsclr_Purple="$(tput setaf 5)"
declare -r lmsclr_Pink="$(tput bold ; tput setaf 5)"

declare -r lmsclr_Cyan="$(tput setaf 6)"
declare -r lmsclr_LightCyan="$(tput bold ; tput setaf 6)"

declare -r lmsclr_LightGrey="$(tput setaf 7)"
declare -r lmsclr_White="$(tput bold ; tput setaf 7)"

declare -r lmsclr_NoColor="$(tput sgr0)" # no color

declare -r lmsclr_ZBlue="$(tput sgr0 ; tput setaf 4 )"

declare -r lmsclr_Bold="$(tput bold)"

export lmsclr_Black lmsclr_DarkGrey lmsclr_LightGrey lmsclr_White
export lmsclr_Red lmsclr_LightRed lmsclr_Green lmsclr_LightGreen
export lmsclr_Yellow lmsclr_Blue lmsclr_LightBlue
export lmsclr_Purple lmsclr_Pink lmsclr_Cyan lmsclr_LightCyan
export lmsclr_NoColor lmsclr_Bold lmsclr_ZBlue

# ******************************************************************************
#
#	
#
# ******************************************************************************

if ! $lmsclr_Level; then
	lmsclr_Level=${lmsclr_Cyan}
	export lmsclr_Level
fi

if ! $lmsclr_Script; then
	lmsclr_Script=${lmsclr_Blue}
	export lmsclr_Script
fi

if ! $lmsclr_Line; then
	lmsclr_Line=${lmsclr_Red}
	export lmsclr_Line
fi

if ! $lmsclr_Function; then
	lmsclr_Function=${lmsclr_Green}
	export lmsclr_Function
fi

if ! $lmsclr_Command; then
	lmsclr_Command=${lmsclr_Purple}
	export lmsclr_Command
fi 

#echo -n "${lmsclr_Bold}${lmsclr_Blue}"

