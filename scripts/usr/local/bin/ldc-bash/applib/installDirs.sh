# *****************************************************************************
# *****************************************************************************
#
#   installDirs.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.3
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
#			Version 0.0.1 - 02-24-2016.
#					0.0.2 - 01-24-2017.
#			        0.0.3 - 08-24-2018.
#
# *****************************************************************************
# *****************************************************************************

declare    ldclib_bashRelease="0.1.4"

# *****************************************************************************

declare    ldcbase_prefix="/media/dev-2018/git/ewsdocker/ldc-bash/scripts"
declare    ldcbase_dirBase="/usr/local"

#declare    ldcbase_prefix="/ldc-base-${ldclib_bashRelease}"
#declare    ldcbase_dirBase="/usr/local"

#declare    ldcbase_prefix=""
#declare    ldcbase_dirBase="${HOME}/.local"

# *****************************************************************************

declare    ldcbase_bash="ldc-bash"
declare    ldcbase_bashRelease="${ldcbase_bash}-${ldclib_bashRelease}"

ldcbase_dirBase="${ldcbase_prefix}${ldcbase_dirBase}"

declare    ldcbase_dirBin="${ldcbase_dirBase}/bin/${ldcbase_bashRelease}"
declare    ldcbase_dirEtc="${ldcbase_dirBase}/etc/${ldcbase_bashRelease}"
declare    ldcbase_dirLib="${ldcbase_dirBase}/lib/${ldcbase_bashRelease}"
declare    ldcbase_dirShare="${ldcbase_dirBase}/share/${ldcbase_bashRelease}"

declare    ldcbase_dirApps="${ldcbase_dirBin}"
declare    ldcbase_dirAppLib="${ldcbase_dirApps}/applib"

declare    ldcbase_dirTests="${ldcbase_dirBin}/tests"
declare    ldcbase_dirTestLib="${ldcbase_dirTests}/testlib"

declare    ldcbase_dirVar="${ldcbase_prefix}/var/local"

declare    ldcbase_dirAppLog="${ldcbase_dirVar}/log/${ldcbase_bashRelease}"
declare    ldcbase_dirBkup="${ldcbase_dirVar}/backup/${ldcbase_bashRelease}"

# *****************************************************************************
# *****************************************************************************

