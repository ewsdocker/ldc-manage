#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	getSongInfo
#
#		Grab song name changes from Audacious audio player and store 
#			in CurrentSong for applications (such a B.U.T.T.)
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 1.1.6
# @copyright © 2014, 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package getSongInfo
#
# *****************************************************************************
#
#	Copyright © 2014, 2016, 2017, 2018. EarthWalk Software
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
#   <http://www.gnu.org/licenses/>.#
# *****************************************************************************
#
#			Version 0.0.1 - 01-29-2017.
#					1.1.0 - 02-23-2017.
#					1.1.6 - 09-05-2018.
#
#
# *****************************************************************************
# *****************************************************************************

ldcapp_name="getSongInfo"

declare    ldcapp_name="getSongInfo"

declare    ldclib_bashRelease="0.1.4"

declare -i ldccli_optProduction=0

# *****************************************************************************

source applib/installDirs.sh

# *****************************************************************************

source $ldcbase_dirLib/stdLibs.sh
source $ldcbase_dirLib/cliOptions.sh
source $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="1.1.6"									# script version

ldcapp_errors="$ldcbase_dirEtc/errorCodes.xml"
ldcvar_help="$ldcbase_dirEtc/getSongHelp.xml"					# path to the help information file
ldcvar_SongOptions="$ldcbase_dirEtc/getSongOptions.xml"

ldcapp_declare="$ldcbase_dirEtc/getSongOptions.xml"			# script declarations

# *****************************************************************************
#
#   File locations - modify as needed
#
# *****************************************************************************
declare    ldcsng_fileRoot="/home/jay/.config/songlists/"
declare    ldcsng_fileCurrent="CurrentSong"
declare    ldcsng_fileSongName="SongName"
declare    ldcsng_fileSongHost="SongHost"

declare    ldcsng_fileRootList="/home/jay/Music/"
declare    ldcsng_fileListName="SongList"

# *****************************************************************************
#
#   Setable options - change default, 
#			or as command line options
#
# *****************************************************************************
declare -i ldcsng_reduceQuote=1   	# 0 = do not translate quote char, 1 = translate with ldccli_optAlter

# *****************************************************************************
#
#   Global variables - modified by program flow
#
# *****************************************************************************
declare    ldcsng_current=""  		# Currently playing song
declare    ldcsng_playerStatus=""   # Player status
declare -i ldcsng_playerPID=0		# Player PID

declare -i ldcsng_streamType=0		# Type of stream - 0=local file, 1=remote stream

declare    ldcsng_album=""			# Playing song album name
declare    ldcsng_artist=""   		#              artist
declare    ldcsng_title=""			#			   title
declare    ldcsng_formattedTitle="" #              formatted title

declare    ldcsng_tuple=""

declare    ldcsng_songHost=""		#
declare    ldcsng_songName=""		#
declare    ldcsng_currentHost=""	#
declare    ldcsng_currentAlbum=""	#

declare    ldcsng_songNameMod=""	#
declare    ldcsng_outputTitle=""	#
declare -i ldcsng_titleAllowed=0	# 1 if ok to output an xterm title

declare	   ldcsng_helpMessage=""	#
declare -i ldcsng_currentHour=0

declare    ldcsng_stackName="ldcsng_songStack"

declare -a ldcsng_reply=()			#
declare	   ldcsng_buffer=""

function updateOption()
{
	[[ ${#ldcsng_reply[@]} -lt 2 || -z "${ldcsng_reply[1]}" ]] &&
	{
		ldcConioDisplay "option name=value"
		return 0
	}

	local parameter
	local value
	local option
			
	ldcStrSplit ${ldcsng_reply[1]} parameter value
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "option ${ldcsng_reply[1]}=value"
		return 0
	 }

	ldcCliValid $parameter
	[[ $? -eq 0 ]] ||
	{
		ldcConioDisplay "Unknown parameter '${parameter}'"
		return 0
	}

	ldcCliLookup $parameter option
	[[ $? -eq 0 ]] ||
	 {
		ldcConioDisplay "Unknown option '${parameter}'"
		return 0
	 }

	[[ -z "${value}" ]] &&
	{
		ldcConioDisplay "option ldccli_${option}=${value}"
		return 0
	}

	ldcConioDisplay "Setting option '${option}' to '${value}'"
	eval "ldccli_${option}='${value}'"

	return 0
}

# *****************************************************************************
#
#   checkInput
#
#		check for input from keyboard: return if none,
#		                               exit script if 'quit' entered
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function checkInput()
{
	read -t 1
	[[ -z "${REPLY}" ]] && return 0

	ldcsng_reply=()
	ldcStrExplode "${REPLY}" " " ldcsng_reply

	case ${ldcsng_reply[0]} in

		"exit" | "quit")
			[[ ${ldccli_optDebug} -eq 0 ]] || ldcConioDebugExit $LINENO "Debug" "Exiting by request"

			ldcConioDisplay "Exiting by request"
			ldcErrorExitScript "Exit"
			;;

		"help")
			displayHelp
			[[ $? -eq 0 ]] ||
			 {
				ldcConioDisplay "Help error: $?"
				return 0
			 }

			;;

		"option")
			updateOption

			;;

		"show")
			ldcConioDisplay ""
			ldcsng_buffer=$( declare -p | grep "ldcsng_" )
			ldcConioDisplay "$ldcsng_buffer"

			ldcConioDisplay ""
			ldcsng_buffer=$( declare -p | grep "ldccli_" )
			ldcConioDisplay "$ldcsng_buffer"

			;;

		"showall")
			ldcDmpVar
			;;

		*)	ldcsng_buffer="Console commands: option show showall help exit quit"
			ldcConioDisplay "$ldcsng_buffer"
			;;
	esac

	ldcConioDisplay ""
	ldcConioDisplay "${ldcsng_timestamp}   ${ldcsng_songName}"
	return 0
}

# *****************************************************************************
#
#	getSongTuple
#
#		Get the requested field song-tuple from audacious
#
#	parameters:
#		field = name of the field to retrieve information for
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function getSongTuple()
{
	local field="$1"
	ldcsng_tuple="`audtool current-song-tuple-data ${field}`"
}

# *****************************************************************************
#
#	streamOrLocal
#
#		Get the formatted-title field from audacious
#
#	parameters:
#		none
#
#	returns:
#		0 = local file
#		1 = remote stream (default)
#
# *****************************************************************************
function streamOrLocal()
{
	ldcsng_streamType=1	# default to stream
	getSongTuple "file-path"

	ldcConioDebug $LINENO "Debug" "(streamOrLocal) file-path: ${ldcsng_tuple}"

	if [[ ${ldcsng_tuple} == *"file://"* || "${ldcsng_tuple:0:1}" == "/" ]]
	then
		ldcsng_streamType=0	# set to file (local)
		ldcConioDebug $LINENO "Debug" "file-path is local"
	fi

	return ${ldcsng_streamType}
}

# *****************************************************************************
#
#	album
#
#		Get the album field from audacious
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function album()
{
	ldcsng_album=""

	getSongTuple 'album'
	ldcsng_album=${ldcsng_tuple}
}

# *****************************************************************************
#
#	artist
#
#		Get the artist field from audacious
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function artist()
{
	ldcsng_artist=""

	getSongTuple 'artist'
	ldcsng_artist=${ldcsng_tuple}
}

# *****************************************************************************
#
#	title
#
#		Get the title field from audacious
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function title()
{
	ldcsng_title=""

	getSongTuple 'title'
	ldcsng_title=${ldcsng_tuple}

	[[ ${ldcsng_reduceQuote} -ne 0 ]] && ldcsng_title="${ldcsng_title/\'/$ldccli_optAlter}"
	return 0
}

# *****************************************************************************
#
#	formattedTitle
#
#		Get the formatted-title field from audacious
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function formattedTitle()
{
	ldcsng_formattedTitle=""

	getSongTuple "formatted-title"
	ldcsng_formattedTitle=${ldcsng_tuple}

	[[ ${ldcsng_reduceQuote} -ne 0 ]] && ldcsng_formattedTitle="${ldcsng_formattedTitle/\'/$ldccli_optAlter}"
	return 0
}

# *****************************************************************************
#
#   isRunning
#
#		return 1 if audacious is running, 0 if not
#
#	parameters:
#		none
#
#	returns:
#		0 = not running
#		1 = is running
#
# *****************************************************************************
function isRunning()
{
	ldcsng_playerPID="`pidof audacious`"
	[[ $? -eq 0 ]] && return 1

	return 0
}

# *****************************************************************************
#
#   waitRunning
#
#		wait UNTIL audacious is running
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function waitRunning()
{
	isRunning

	until [ $? == 1 ]
	do
	  sleep $ldccli_optRun

	  checkInput
	  isRunning
	done
	
	return 0
}

# *****************************************************************************
#
#   isPlaying
#
#		Return 1 if a song is playing, 0 if not
#
#	parameters:
#		none
#
#	returns:
#		1 = song is playing
#		0 = song is not playing
#
# *****************************************************************************
function isPlaying()
{
	ldcsng_playerStatus="stopped"

	isRunning
	[[ $? -eq 1 ]] &&
	 {
		ldcsng_playerStatus="`audtool playback-status`"
		[[ "$ldcsng_playerStatus" == "playing" ]] && return 1
	 }

	return 0
}

# *****************************************************************************
#
#   waitPlaying
#
#		Wait until a song is playing
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function waitPlaying()
{
	isPlaying

	until [ $? -eq 1 ]
	do
		isRunning
		[[ $? -eq 0 ]] && waitRunning || sleep $ldccli_optPlay

		checkInput

		ldcConioDebug $LINENO "Debug" "(waitPlaying) Play status: $ldcsng_playerStatus"

		isPlaying
	done

	return 0
}

# *****************************************************************************
#
#	songChanged
#
#		Wait until the current song has changed
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function songChanged()
{
	local waitingSong=${ldcsng_title}

	checkInput

	ldcConioDebug $LINENO "Debug" "(songChanged) Waiting for song to end: ${waitingSong}"

	until [ "${waitingSong}" != "${ldcsng_title}" ]
	do
		sleep $ldccli_optSleep
		checkInput
		title
	done

	return 0
}

# *****************************************************************************
#
#	splitHostName
#
#	  Attempts to split out the actual host name from
#		the current ldcsng_songHost to a shortened ldcsng_songHost and
#		remainder into descriptive ldcsng_songName
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function splitHostName()
{
	ldcConioDebug $LINENO "Debug" "(splitHostName) SongHost: ${ldcsng_songHost}"

	sep=':'
	case $ldcsng_songHost in

		(*"$sep"*)
			ldcsng_songName=${ldcsng_songHost#*"$sep"}   # first extract the end of the host name as a songname
			ldcConioDebug $LINENO "Debug" "(splitHostName) SongNAME: ${ldcsng_songName}"

			ldcsng_songHost=${ldcsng_songHost%%"$sep"*}  # extract the beginning of the host name AS the host name
			ldcConioDebug $LINENO "Debug" "(splitHostName) SongHOST: ${ldcsng_songHost}"
			;;

		(*)
			ldcConioDebug $LINENO "Debug" "(splitHostName) no seperator found!"
			ldcConioDebug $LINENO "Debug" "(splitHostName) SongHOST: ${ldcsng_songHost}"

			ldcsng_songName=""
			ldcConioDebug $LINENO "Debug" "(splitHostName) SongNAME: ${ldcsng_songName}"
			;;

	esac
	
	return 0
}

# *****************************************************************************
#
#	createFileListName
#
#		Create the name of the Play List file
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function createFileListName()
{
	ldcsng_fileListName="$ldcsng_fileListName-$(date +%F)"
	ldcsng_currentHour=$(date +"%k")

	return 0
}

# *****************************************************************************
#
#	checkCurrentDate
#
#		Check current date and make sure it's the same as last time
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function checkCurrentDate()
{
	local -i hour=$(date +"%k")
	[[ "${ldcsng_currentHour}" -gt "${hour}" ]] && 
	 {
		ldcConioDisplay "Date change detected - $(date +%F)"
		createFileListName
	 }

	return 0
}

# *****************************************************************************
#
#	processSong
#
#		Process the song's items and output them as appropriate
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function processSong()
{
	ldcsng_timestamp=$(date +%H:%M:%S)
	ldcsng_currentHost=${ldcsng_songHost}

	if [ ${ldcsng_streamType} -eq 0 ]
	then # local files
		ldcsng_songHost="${ldcsng_album}"
		ldcsng_songName="${ldcsng_artist} - ${ldcsng_title}"
	else # remote stream
		ldcsng_songHost=${ldcsng_artist}
		ldcsng_songName=${ldcsng_title}
	fi

	#
	#  remove invalid characters from SongName
	#
	ldcsng_songNameMod=`echo "${ldcsng_songName}" | tr -d -c ".[:alnum:]._ ()-"`

	[[ "${ldcsng_currentHost}" != "${ldcsng_songHost}" ]] &&
	 {
		ldcConioDisplay "*********************************"
		ldcConioDisplay "${ldcsng_timestamp} ${ldcsng_songHost}"
	 }

	#
	#  if there is nothing in ldcsng_songName, try to create a ldcsng_songName from ldcsng_songHost
	#
	[[ -e "$ldcsng_songNameMod" ]] &&
	 {
		[[ "${ldcsng_currentHost}" != "${ldcsng_songHost}" ]] && splitHostName
		[[ -e "$ldcsng_songName" ]] && ldcsng_songName="... Station Break ..."

		ldcsng_songNameMod=$ldcsng_songName
	 }

	# *************************************************************************
	#
	#	write to the various files
	#
	# *************************************************************************

	checkCurrentDate

	ldcConioDisplay "${ldcsng_timestamp}   ${ldcsng_songName}"

	echo "${ldcsng_songHost}" > ${ldcsng_fileRoot}${ldcsng_fileSongHost}
	
	if [ ${ldcsng_streamType} -eq 0 ]
	then # local files
		ldcsng_outputTitle="${ldcsng_album} - ${ldcsng_songNameMod}"
		echo "${ldcsng_album} - ${ldcsng_songNameMod}" > ${ldcsng_fileRoot}${ldcsng_fileCurrent}
	else
		ldcsng_outputTitle="${ldcsng_songNameMod}"
		echo "${ldcsng_songNameMod}" > ${ldcsng_fileRoot}${ldcsng_fileCurrent}
	fi

	[[ ${ldcsng_titleAllowed} -eq 1 ]] && xtitle $ldcsng_outputTitle

	echo "${ldcsng_timestamp} - ${ldcsng_formattedTitle}" >> ${ldcsng_fileList}
}

# *****************************************************************************
#
#	processOptions
#
#		Process command line parameters
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
function processCliOptions()
{
	[[ "${ldccli_optAlter}" != "-" ]] &&
	 {
		[[ "${ldccli_optAlter:0:1}" == "-" ]] && ldccli_optAlter=""
		ldcsng_reduceQuote=1
	 }
	
	return 0
}

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the application
#
# *****************************************************************************
# *****************************************************************************

ldcDomCLoad ${ldcvar_SongOptions} "$ldcsng_stackName" 0
[[ $? -eq 0 ]] || ldcConioDebugExit $LINENO "DomError" "ldcDomCLoad failed loading '${ldcsng_stackName}'."

processCliOptions

# *****************************************************************************

createFileListName

ldcsng_fileList="${ldcsng_fileRootList}${ldcsng_fileListName}"
ldcsng_currentAlbum=""
ldcsng_currentHost=""

ldcConioDisplay "Song Log = ${ldcsng_fileList}"

ldcsng_titleAllowed=$(ldcUtilCommandExists "xtitle")

# *******************************************************

while [[ ${ldcapp_abort} -eq 0 ]]
do
	waitPlaying

	album
	artist
	title
	formattedTitle
	streamOrLocal

	processSong

	songChanged
done

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
