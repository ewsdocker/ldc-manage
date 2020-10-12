#!/bin/bash

# ***************************************************************
# ***************************************************************
#
#   iniParser
#
#   http://theoldschooldevops.com/2008/02/09/bash-ini-parser
#
#   	By AJDIAZ
#
# ***************************************************************
# ***************************************************************

declare -r lmslib_iniParser="0.0.1"	# version of library

# ***************************************************************
#
#    cfg_parser
#
#		read and process the ini file
#
#	parameters:
#		fileName = path to the configuration file
#
# ***************************************************************
cfg_parser ()
{
    ini="$(<$1)"                				# read the file
    ini="${ini//[/\[}"          				# escape [
    ini="${ini//]/\]}"          				# escape ]

    local IFS=$'\n' && ini=( ${ini} ) 			# convert to line-array

    ini=( ${ini[*]//;*/} )      				# remove comments with ;
    ini=( ${ini[*]/\    =/=} )  				# remove tabs before =
    ini=( ${ini[*]/=\   /=} )   				# remove tabs be =
    ini=( ${ini[*]/\ =\ /=} )   				# remove anything with a space around =
    ini=( ${ini[*]/#\\[/\}$'\n'cfg.section.} ) 	# set section prefix
    ini=( ${ini[*]/%\\]/ \(} )    				# convert text2function (1)
    ini=( ${ini[*]/=/=\( } )    				# convert item to array
    ini=( ${ini[*]/%/ \)} )     				# close array parenthesis
    ini=( ${ini[*]/%\\ \)/ \\} ) 				# the multiline trick
    ini=( ${ini[*]/%\( \)/\(\) \{} ) 			# convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} ) 				# remove extra parenthesis
    ini[0]="" 									# remove first element
    ini[${#ini[*]} + 1]='}'    					# add the last brace

    eval "$(echo "${ini[*]}")" 					# eval the result
}

# ***************************************************************
#
#    cfg_writer
#
#		write the ini file
#
#	parameters:
#
# ***************************************************************
cfg_writer ()
{
    IFS=' '$'\n'

    fun="$(declare -F)"
    fun="${fun//declare -f/}"

    for f in $fun; do
        [ "${f#cfg.section}" == "${f}" ] && continue
        item="$(declare -f ${f})"
        item="${item##*\{}"
        item="${item%\}}"
        item="${item//=*;/}"
        vars="${item//=*/}"
        eval $f
        echo "[${f#cfg.section.}]"

        for var in $vars; do
            echo $var=\"${!var}\"
        done

    done
}

# ***************************************************************
#
# parse the config file called 'myfile.ini', with the following
# contents::
#   [sec2]
#   var2='something'
#
# ***************************************************************
#
#cfg_parser 'myfile.ini'
#
# 	*************************************************************
#
#	declare -f cfg.section.sec2
#
#		http://theoldschooldevops.com/2008/02/09/bash-ini-parser/#comment-370
#
# 	*************************************************************
#
# enable section called 'sec2' (in the file [sec2]) for reading
#cfg.section.sec2
#
# read the content of the variable called 'var2' (in the file
# var2=XXX). If your var2 is an array, then you can use
# ${var[index]}
#echo "$var2"
#
# ***************************************************************
#
#cfg_parser myfile.ini
#cfg_write > sample_copy.ini
#
#When calling cfg_write, it’s parse the environment looking for cfg variables, and output an ini file with results to stdout.
#
#There are a limitation with this function, it do not maintain the types on the file and all values are converted to strings (which is not really a problem for bash).
#
#
# ***************************************************************
#
#  I don’t code any functions to update the array. Really this hack do not use an array. We read the ini and create a couple of variables with the same name as variable in the file, and change the section creating a function called the section name. So if you need to add a new section, you might do:
#
#	cfg.section.MYNEWSECTION ()
#	{
#		MYNEWVAR1=”MYNEWVALUE1″
#		# any other variable
#	}
#
# ***************************************************************
#
#  To put the ini contents in uppercase is easy, just change the line:
#
#	IFS=$'\n' && ini=( $(<$1) )
#
#  by the line:
#
#	IFS=$'\n' && ini=( $(tr a-z A-Z <$1) )
#
# ***************************************************************
