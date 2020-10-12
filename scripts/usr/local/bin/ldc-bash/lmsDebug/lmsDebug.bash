#!/bin/bash

# *******************************************************
# *******************************************************
#
#   lmsDebug.bash
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

declare -i lmscli_optProduction=0

if [ $lmscli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/lms/bash"
	etcDir="$rootDir/etc/lms"
else
	rootDir="$PWD/../.."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/lmsColorDef.bash
. $libDir/lmsDebug.bash

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
				PS4="${lmsclr_Black}${lmsclr_Level}+${lmsclr_Script}"'(${BASH_SOURCE##*/}'":${lmsclr_Line}"'${LINENO}'"${lmsclr_Script}): ${lmsclr_Function}"'${FUNCNAME[0]}'"(): ${lmsclr_Command}"
				export PS4
				SCRIPT=$1
				;;

	esac

	lmsDebugFuncCommand
fi

lmsDebugResetScreen
