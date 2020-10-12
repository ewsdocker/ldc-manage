#!/bin/bash

# *******************************************************
# *******************************************************
#
#   queryFedoraSetupCodes.sh
#
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 1.0 - 02-24-2016.
#
# *******************************************************
# *******************************************************
declare -A lmscli_shellParam				# cli parameters
declare -A lmscli_shellParametersChanged			# copy of cli parameter prior to change (for debug)

declare -i lmscli_Errors=0					# number of cli errors detected
declare -a lmscli_ParamBuffer			# cli parameter array buffer

# *******************************************************
# *******************************************************
#
#    	External Scripts
#
# *******************************************************
# *******************************************************

. ShellSnippets/applicationName.sh
. ShellSnippets/lmsError.sh
. ShellSnippets/lmsConio.sh
. ShellSnippets/setupFedoraErrorCodes.sh

# *******************************************************
# *******************************************************
#
#		Application Script below here
#
# *******************************************************
# *******************************************************

lmscli_optDebug=0				# (d) Debug output if not 0
lmscli_optSilent=0    			# (q) Quiet setting: non-zero for absolutely NO output
lmscli_optBatch=0					# (b) Batch mode - missing parameters fail
silentOverride=0			# set to 1 to lmscli_optOverride the lmscli_optSilent flag

applicationVersion="1.0"	# Application version

# *******************************************************
# *******************************************************

declare -a lmscli_shellParam	# cli input parameters
declare -a cliChanged		# original value of changed parameters

# *******************************************************
#
#    displayHelp
#
#		Display help message block
#
# *******************************************************
displayHelp()
{
    lmsConioDisplay " "
    lmsConioDisplay "  ${applicationBasename} [-l ss] Error-Number-Or-Name"
    lmsConioDisplay " "
    lmsConioDisplay "  ${applicationBasename} [-d [nn]] [-q [nn]] [-h] [--help] [-v]"
    lmsConioDisplay " "
    lmsConioDisplay "    -l = list format code:"
    lmsConioDisplay "           s = single code, colon separated (default)"
    lmsConioDisplay " "
    lmsConioDisplay "           b = all error codes, colon separated in a block, separated by new-line"
    lmsConioDisplay "           c = all error codes, colon separated, output one-at-a-time, separated by new-line"
    lmsConioDisplay "           f = all error codes, print-output format, one-line-at-at-time"
    lmsConioDisplay " "
    lmsConioDisplay "    -d = debug flag setting (0 = no debug, otherwise debug level)"
    lmsConioDisplay "    -q = quiet (no output) if set to non-zero"
    lmsConioDisplay "    -v = show version"
    lmsConioDisplay " "
    lmsConioDisplay "    -h = help (display this message)"
    lmsConioDisplay "    --help = help (display this message)"
    lmsConioDisplay " "
    lmsConioDisplay "   where nn = numeric value"
    lmsConioDisplay "         ss = string value"
    lmsConioDisplay " "
}

# *******************************************************
#
#	showChangedParameters
#
#		display changed parameters
#
# *******************************************************
showChangedParameters()
{
	for parameter in "${!lmscli_shellParam[@]}"
	do
		case ${parameter} in

			l)
	        	lmsConioDebug "showChangedParameters" "Groups: ${lmscli_shellParam[$parameter]} changed to ${MOUNTGROUP}"
            	;;

			# ***********************************************

        	d)
	        	lmsConioDebug "showChangedParameters" "Debug: ${lmscli_shellParam[$parameter]} changed to ${lmscli_optDebug}"
        		;;

			q)
	        	lmsConioDebug "showChangedParameters" "Quiet: ${lmscli_shellParam[$parameter]} changed to ${lmscli_optSilent}"
	        	;;

			# ***********************************************

    		*)
        		echo >&2 "(showChangedParameters) Invalid argument: $1"
        		;;

		esac
	done
}

# *******************************************************
# *******************************************************
#
#    		MAIN BODY OF THE SCRIPT
#
# *******************************************************
# *******************************************************

initializeErrorCodes

if [ $lmscli_optSilent -ne 0 ]
then
	displayApplicationName
fi

# *******************************************************
#
#    parse and store cli parameters
#
# *******************************************************

lmscli_ParamBuffer=( "$@" )

lmscli_Errors=0

while test $# -gt 0
do
	case $1 in

		-l)
			lmscli_shellParam[l]=${lmsErrorQueryType}
            lmsErrorQueryType=$2
            shift
            ;;

        -d)
			lmscli_shellParam[d]=${lmscli_optDebug}
            lmscli_optDebug=$2
	    	if [ -e $lmscli_optDebug ]
	    	then
	        	lmscli_optDebug=1
 	    	fi

        	if [ ! -z "${lmscli_optDebug##*[!0-9]*}" ]
        	then
	    		shift
	    	else
	    		lmscli_optDebug=1
	    	fi
        	;;

		-q)
			lmscli_shellParam[q]=${lmscli_optSilent}
      		lmscli_optSilent=$2
      		if [ -e $lmscli_optSilent ]
	    	then
	        	lmscli_optSilent=1
 	    	fi

        	if [ ! -z "${lmscli_optSilent##*[!0-9]*}" ]
        	then
	    		shift
	    	else
	    		lmscli_optSilent=1
	    	fi
	    	;;

		# ***********************************************

		-v)
	    	displayVersion
	    	exit Error_None
        	;;

		--help)
	    	displayHelp
	    	exit Error_None
        	;;

		-h)
	    	displayHelp
	    	exit Error_None
        	;;

    	*)
    		lmscli_Errors=${lmscli_Errors}+1
           	lmsConioDisplay "Invalid argument: $1"
        	;;

   	esac
   	shift

done

# *******************************************************

if [ ${lmscli_Errors} -ne 0 ]
then
	exit Error_ParamErrors
fi

if [ ${#lmscli_shellParam[@]} -ne 0 ]
then
	showChangedParameters
fi

# *******************************************************




# *******************************************************

exitScript Error_None
