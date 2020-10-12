# *****************************************************************************
# *****************************************************************************
#
#   commonVars.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.4
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package lms-bash
# @subpackage applications
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

#
# script version - s/b replaced in script with actual version
#
lmsscr_Version="0.0.1"						# script version

#
# default application vars
#
lmsapp_declare="$lmsbase_dirEtc/cliOptions.xml"
lmsapp_errors="$lmsbase_dirEtc/errorCodes.xml"
lmsapp_help="$lmsbase_dirEtc/helpTest.xml"

lmsapp_logDir="${lmsbase_dirAppLog}"
lmsapp_logName="${lmsbase_dirAppLog}/${lmsapp_name}"

lmsapp_guid=""
lmsapp_nsuid=""

lmsapp_result=0

lmsapp_stackSize=0
lmsapp_stackCurrent=0
lmsapp_stackName="lmsapp_stack"

lmsapp_buffer=""
lmsapp_helpBuffer=""

lmsapp_item=""

lmsapp_abort=0								# abort flag: set to 1 to abort the application script
