#!/bin/bash

# *******************************************************
# *******************************************************
#
#   createNetworkShareCredentials
#   Copyright (C) 2016. EarthWalk Software
#
#   	By Jay Wheeler.
#
#			Version 0.0.1 - 02-24-2016.
#			        0.0.2 - 03-18-2016.
#
# *******************************************************
# *******************************************************

declare -r lmslib_createNetworkShareCredentials="0.0.2"	# version of library

# *******************************************************
# *******************************************************
#
#	Functions
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#	displayHelp
#
#		Display help message block
#
# *******************************************************
displayHelp()
{
	lmsConioDisplay " "
	lmsConioDisplay "  ${applicationName} <global-option-1>=<value-1> ... <global-option-n>=<value-n> <command-name> [ <command-option-1> ... ]"
	lmsConioDisplay " "
	lmsConioDisplay "  ${applicationName} ngroup=<group-name> nuser=<user-name> npass=<password> "
	lmsConioDisplay "              [ cname=<credential-name> ] "
	lmsConioDisplay "              [ cpath=<credential-folder> ] "
	lmsConioDisplay "              [ cfile=<credential-file> ]"
	lmsConioDisplay "              [ batch=< 0|1 > ]"
	lmsConioDisplay "              [ debug=<debug-level> ]"
	lmsConioDisplay "              [ silence=< 0|1 > ]"
	lmsConioDisplay " "
	lmsConioDisplay "	 COMMANDS: < create | update | delete | error | version | help >"
	lmsConioDisplay " "
	lmsConioDisplay "      < command > [< command-option-1 > ... < command-option-n > ]"
	lmsConioDisplay " "
	lmsConioDisplay "  GLOBAL OPTIONS"
	lmsConioDisplay " "
	lmsConioDisplay "	ngroup = local host network group name"
	lmsConioDisplay "	nuser = network share server login user"
	lmsConioDisplay "	npass = network share server login password"
	lmsConioDisplay " "
	lmsConioDisplay "	cname = (optional) credential file name"
	lmsConioDisplay "	cpath = (optional) credential folder path"
	lmsConioDisplay "	cfile = (optional) credential file path - default = cpath + cname"
	lmsConioDisplay " "
	lmsConioDisplay "	lmserr_result = error number or name"
	lmsConioDisplay " "
	lmsConioDisplay "	batch = (optional) debug flag setting"
	lmsConioDisplay "	silent = (optional) quiet if set to non-zero"
	lmsConioDisplay "	version = (optional) show version"
	lmsConioDisplay " "
	lmsConioDisplay "	help = help display"
	lmsConioDisplay " "
	lmsConioDisplay "  COMMAND OPTIONS"
	lmsConioDisplay " "
	lmsConioDisplay " "
	lmsConioDisplay " "
}

