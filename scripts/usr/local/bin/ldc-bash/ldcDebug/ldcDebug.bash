#!/bin/bash

# *******************************************************
# *******************************************************
#
#   ldcDebug.bash
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 06-28-2016.
#
# *******************************************************
# *******************************************************

# *******************************************************
# *******************************************************
#
#    	External Scripts
#
# *******************************************************
# *******************************************************

declare -i ldccli_optProduction=0

if [ $ldccli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/ldc/bash"
	etcDir="$rootDir/etc/ldc"
else
	rootDir="$PWD/../.."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/ldcColorDef.bash
. $libDir/ldcDebug.bash

# *******************************************************
# *******************************************************

if [ $# -gt 0 ]
then

	case "$1" in

		"test")
				FLAGS='-n'
				SCRIPT=$2
				;;

		"verbose")
				FLAGS='-xv'
				SCRIPT=$2
				;;

		"noexec")
				FLAGS='-xvn'
				SCRIPT=$2
				;;

		*)
				FLAGS='-x'
				PS4="${ldcclr_Black}${ldcclr_Level}+${ldcclr_Script}"'(${BASH_SOURCE##*/}'":${ldcclr_Line}"'${LINENO}'"${ldcclr_Script}): ${ldcclr_Function}"'${FUNCNAME[0]}'"(): ${ldcclr_Command}"
				export PS4
				SCRIPT=$1
				;;

	esac

	ldcDebugFuncCommand
fi

ldcDebugResetScreen
