# *****************************************************************************
# *****************************************************************************
#
#   cliOptions.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
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

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optLogDisplay=0

lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optQuiet=0				# set to 1 to lmscli_optOverride the lmscli_optSilent flag
lmscli_optNoReset=0
lmscli_optOverride=0

lmscli_optQueueErrors=0
lmscli_optPrintDOMEntity=0

lmscli_optBatch=0				# (b) Batch mode - missing parameters fail
