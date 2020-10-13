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
# @package ldc-bash
# @subpackage applications
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

#
# script version - s/b replaced in script with actual version
#
ldcscr_Version="0.0.1"						# script version

#
# default application vars
#
ldcapp_declare="$ldcbase_dirEtc/cliOptions.xml"
ldcapp_errors="$ldcbase_dirEtc/errorCodes.xml"
ldcapp_help="$ldcbase_dirEtc/helpTest.xml"

ldcapp_logDir="${ldcbase_dirAppLog}"
ldcapp_logName="${ldcbase_dirAppLog}/${ldcapp_name}"

ldcapp_guid=""
ldcapp_nsuid=""

ldcapp_result=0

ldcapp_stackSize=0
ldcapp_stackCurrent=0
ldcapp_stackName="ldcapp_stack"

ldcapp_buffer=""
ldcapp_helpBuffer=""

ldcapp_item=""

ldcapp_abort=0								# abort flag: set to 1 to abort the application script
