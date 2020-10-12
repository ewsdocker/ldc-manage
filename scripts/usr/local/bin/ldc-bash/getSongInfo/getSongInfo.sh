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
#   <http://www.gnu.org/licenses/>.#
# *****************************************************************************
#
#			Version 0.0.1 - 01-29-2017.
#					1.1.0 - 02-23-2017.
#					1.1.6 - 09-05-2018.
#
## *****************************************************************************
# *****************************************************************************

declare    lmsapp_name="getSongInfo"
declare    lmslib_bashRelease="0.1.4"

declare -i lmscli_optProduction=0

# *****************************************************************************

source applib/installDirs.sh

# *****************************************************************************

source $lmsbase_dirLib/stdLibs.sh
source $lmsbase_dirLib/cliOptions.sh
source $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="1.1.6"									# script version

lmsapp_errors="$lmsbase_dirEtc/errorCodes.xml"
lmsvar_help="$lmsbase_dirEtc/getSongHelp.xml"					# path to the help information file
lmsvar_SongOptions="$lmsbase_dirEtc/getSongOptions.xml"

lmsapp_declare="$lmsbase_dirEtc/getSongOptions.xml"			# script declarations

# *****************************************************************************
#
#   File locations - modify as needed
#
# *****************************************************************************
declare    lmssng_fileRoot="/home/jay/.config/songlists/"
declare    lmssng_fileCurrent="CurrentSong"
declare    lmssng_fileSongName="SongName"
declare    lmssng_fileSongHost="SongHost"

declare    lmssng_fileRootList="/home/jay/Music/"
declare    lmssng_fileListName="SongList"

# *****************************************************************************
#
#   Setable options - change default, 
#			or as command line options
#
# *****************************************************************************
declare -i lmssng_reduceQuote=1   	# 0 = do not translate quote char, 1 = translate with lmscli_optAlter

# *****************************************************************************
#
#   Global variables - modified by program flow
#
# *****************************************************************************
declare    lmssng_current=""  		# Currently playing song
declare    lmssng_playerStatus=""   # Player status
declare -i lmssng_playerPID=0		# Player PID

declare -i lmssng_streamType=0		# Type of stream - 0=local file, 1=remote stream

declare    lmssng_album=""			# Playing song album name
declare    lmssng_artist=""   		#              artist
declare    lmssng_title=""			#			   title
declare    lmssng_formattedTitle="" #              formatted title

declare    lmssng_tuple=""

declare    lmssng_songHost=""		#
declare    lmssng_songName=""		#
declare    lmssng_currentHost=""	#
declare    lmssng_currentAlbum=""	#

declare    lmssng_songNameMod=""	#
declare    lmssng_outputTitle=""	#
declare -i lmssng_titleAllowed=0	# 1 if ok to output an xterm title

declare	   lmssng_helpMessage=""	#
declare -i lmssng_currentHour=0

declare    lmssng_stackName="lmssng_songStack"

declare -a lmssng_reply=()			#
declare	   lmssng_buffer=""

function updateOption()
{
	[[ ${#lmssng_reply[@]} -lt 2 || -z "${lmssng_reply[1]}" ]] &&
	{
		lmsConioDisplay "option name=value"
		return 0
	}

	local parameter
	local value
	local option
			
	lmsStrSplit ${lmssng_reply[1]} parameter value
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "option ${lmssng_reply[1]}=value"
		return 0
	 }

	lmsCliValid $parameter
	[[ $? -eq 0 ]] ||
	{
		lmsConioDisplay "Unknown parameter '${parameter}'"
		return 0
	}

	lmsCliLookup $parameter option
	[[ $? -eq 0 ]] ||
	 {
		lmsConioDisplay "Unknown option '${parameter}'"
		return 0
	 }

	[[ -z "${value}" ]] &&
	{
		lmsConioDisplay "option lmscli_${option}=${value}"
		return 0
	}

	lmsConioDisplay "Setting option '${option}' to '${value}'"
	eval "lmscli_${option}='${value}'"

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

	lmssng_reply=()
	lmsStrExplode "${REPLY}" " " lmssng_reply

	case ${lmssng_reply[0]} in

		"exit" | "quit")
			[[ ${lmscli_optDebug} -eq 0 ]] || lmsConioDebugExit $LINENO "Debug" "Exiting by request"

			lmsConioDisplay "Exiting by request"
			lmsErrorExitScript "Exit"
			;;

		"help")
			displayHelp
			[[ $? -eq 0 ]] ||
			 {
				lmsConioDisplay "Help error: $?"
				return 0
			 }

			;;

		"option")
			updateOption

			;;

		"show")
			lmsConioDisplay ""
			lmssng_buffer=$( declare -p | grep "lmssng_" )
			lmsConioDisplay "$lmssng_buffer"

			lmsConioDisplay ""
			lmssng_buffer=$( declare -p | grep "lmscli_" )
			lmsConioDisplay "$lmssng_buffer"

			;;

		"showall")
			lmsDmpVar
			;;

		*)	lmssng_buffer="Console commands: option show showall help exit quit"
			lmsConioDisplay "$lmssng_buffer"
			;;
	esac

	lmsConioDisplay ""
	lmsConioDisplay "${lmssng_timestamp}   ${lmssng_songName}"
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
	lmssng_tuple="`audtool current-song-tuple-data ${field}`"
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
	lmssng_streamType=1	# default to stream
	getSongTuple "file-path"

	lmsConioDebug $LINENO "Debug" "(streamOrLocal) file-path: ${lmssng_tuple}"

	if [[ ${lmssng_tuple} == *"file://"* || "${lmssng_tuple:0:1}" == "/" ]]
	then
		lmssng_streamType=0	# set to file (local)
		lmsConioDebug $LINENO "Debug" "file-path is local"
	fi

	return ${lmssng_streamType}
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
	lmssng_album=""

	getSongTuple 'album'
	lmssng_album=${lmssng_tuple}
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
	lmssng_artist=""

	getSongTuple 'artist'
	lmssng_artist=${lmssng_tuple}
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
	lmssng_title=""

	getSongTuple 'title'
	lmssng_title=${lmssng_tuple}

	[[ ${lmssng_reduceQuote} -ne 0 ]] && lmssng_title="${lmssng_title/\'/$lmscli_optAlter}"
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
	lmssng_formattedTitle=""

	getSongTuple "formatted-title"
	lmssng_formattedTitle=${lmssng_tuple}

	[[ ${lmssng_reduceQuote} -ne 0 ]] && lmssng_formattedTitle="${lmssng_formattedTitle/\'/$lmscli_optAlter}"
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
	lmssng_playerPID="`pidof audacious`"
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
	  sleep $lmscli_optRun

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
	lmssng_playerStatus="stopped"

	isRunning
	[[ $? -eq 1 ]] &&
	 {
		lmssng_playerStatus="`audtool playback-status`"
		[[ "$lmssng_playerStatus" == "playing" ]] && return 1
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
		[[ $? -eq 0 ]] && waitRunning || sleep $lmscli_optPlay

		checkInput

		lmsConioDebug $LINENO "Debug" "(waitPlaying) Play status: $lmssng_playerStatus"

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
	local waitingSong=${lmssng_title}

	checkInput

	lmsConioDebug $LINENO "Debug" "(songChanged) Waiting for song to end: ${waitingSong}"

	until [ "${waitingSong}" != "${lmssng_title}" ]
	do
		sleep $lmscli_optSleep
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
#		the current lmssng_songHost to a shortened lmssng_songHost and
#		remainder into descriptive lmssng_songName
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
	lmsConioDebug $LINENO "Debug" "(splitHostName) SongHost: ${lmssng_songHost}"

	sep=':'
	case $lmssng_songHost in

		(*"$sep"*)
			lmssng_songName=${lmssng_songHost#*"$sep"}   # first extract the end of the host name as a songname
			lmsConioDebug $LINENO "Debug" "(splitHostName) SongNAME: ${lmssng_songName}"

			lmssng_songHost=${lmssng_songHost%%"$sep"*}  # extract the beginning of the host name AS the host name
			lmsConioDebug $LINENO "Debug" "(splitHostName) SongHOST: ${lmssng_songHost}"
			;;

		(*)
			lmsConioDebug $LINENO "Debug" "(splitHostName) no seperator found!"
			lmsConioDebug $LINENO "Debug" "(splitHostName) SongHOST: ${lmssng_songHost}"

			lmssng_songName=""
			lmsConioDebug $LINENO "Debug" "(splitHostName) SongNAME: ${lmssng_songName}"
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
	lmssng_fileListName="$lmssng_fileListName-$(date +%F)"
	lmssng_currentHour=$(date +"%k")

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
	[[ "${lmssng_currentHour}" -gt "${hour}" ]] && 
	 {
		lmsConioDisplay "Date change detected - $(date +%F)"
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
	lmssng_timestamp=$(date +%H:%M:%S)
	lmssng_currentHost=${lmssng_songHost}

	if [ ${lmssng_streamType} -eq 0 ]
	then # local files
		lmssng_songHost="${lmssng_album}"
		lmssng_songName="${lmssng_artist} - ${lmssng_title}"
	else # remote stream
		lmssng_songHost=${lmssng_artist}
		lmssng_songName=${lmssng_title}
	fi

	#
	#  remove invalid characters from SongName
	#
	lmssng_songNameMod=`echo "${lmssng_songName}" | tr -d -c ".[:alnum:]._ ()-"`

	[[ "${lmssng_currentHost}" != "${lmssng_songHost}" ]] &&
	 {
		lmsConioDisplay "*********************************"
		lmsConioDisplay "${lmssng_timestamp} ${lmssng_songHost}"
	 }

	#
	#  if there is nothing in lmssng_songName, try to create a lmssng_songName from lmssng_songHost
	#
	[[ -e "$lmssng_songNameMod" ]] &&
	 {
		[[ "${lmssng_currentHost}" != "${lmssng_songHost}" ]] && splitHostName
		[[ -e "$lmssng_songName" ]] && lmssng_songName="... Station Break ..."

		lmssng_songNameMod=$lmssng_songName
	 }

	# *************************************************************************
	#
	#	write to the various files
	#
	# *************************************************************************

	checkCurrentDate

	lmsConioDisplay "${lmssng_timestamp}   ${lmssng_songName}"

	echo "${lmssng_songHost}" > ${lmssng_fileRoot}${lmssng_fileSongHost}
	
	if [ ${lmssng_streamType} -eq 0 ]
	then # local files
		lmssng_outputTitle="${lmssng_album} - ${lmssng_songNameMod}"
		echo "${lmssng_album} - ${lmssng_songNameMod}" > ${lmssng_fileRoot}${lmssng_fileCurrent}
	else
		lmssng_outputTitle="${lmssng_songNameMod}"
		echo "${lmssng_songNameMod}" > ${lmssng_fileRoot}${lmssng_fileCurrent}
	fi

	[[ ${lmssng_titleAllowed} -eq 1 ]] && xtitle $lmssng_outputTitle

	echo "${lmssng_timestamp} - ${lmssng_formattedTitle}" >> ${lmssng_fileList}
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
	[[ "${lmscli_optAlter}" != "-" ]] &&
	 {
		[[ "${lmscli_optAlter:0:1}" == "-" ]] && lmscli_optAlter=""
		lmssng_reduceQuote=1
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

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the application
#
# *****************************************************************************
# *****************************************************************************

lmsDomCLoad ${lmsvar_SongOptions} "$lmssng_stackName" 0
[[ $? -eq 0 ]] || lmsConioDebugExit $LINENO "DomError" "lmsDomCLoad failed loading '${lmssng_stackName}'."

processCliOptions

# *****************************************************************************

createFileListName

lmssng_fileList="${lmssng_fileRootList}${lmssng_fileListName}"
lmssng_currentAlbum=""
lmssng_currentHost=""

lmsConioDisplay "Song Log = ${lmssng_fileList}"

lmssng_titleAllowed=$(lmsUtilCommandExists "xtitle")

# *******************************************************

while [[ ${lmsapp_abort} -eq 0 ]]
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

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
