#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#		lms-svn.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package lms-svn
#
# *****************************************************************************
#
#	Copyright © 2016. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#		Version 0.0.1 - 02-28-2016.
#		        0.1.0 - 05-18-2016.
#				0.1.1 - 08-25-2016.
#               0.1.2 - 08-30-2016.
#				0.1.3 - 09-08-2016.
#
# *****************************************************************************
# *****************************************************************************
lmsscr_Version="0.1.3"

# *****************************************************************************
# *****************************************************************************
#
#		External Scripts
#
# *****************************************************************************
# *****************************************************************************

lmscli_optProduction=0

if [ $lmscli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/lms/bash"
	etcDir="$rootDir/etc/lms"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/arraySort.sh
. $libDir/lmsCli.sh
. $libDir/lmsColorDef.sh
. $libDir/lmsConio.sh
. $libDir/lmsXCfg.sh
. $libDir/lmsDomN.sh
. $libDir/lmsDomR.sh
. $libDir/lmsDomTs.sh
. $libDir/lmsDmpVar
. $libDir/dynamicArrayFunctions.sh
. $libDir/dynamicArrayIterator.sh
. $libDir/lmsError.sh
. $libDir/lmsErrorQDisp.sh
. $libDir/lmsErrorQ.sh
. $libDir/lmsHelp.sh
. $libDir/lmsDeclare.sh
. $libDir/lmsLog.sh
. $libDir/lmsLogRead.sh
. $libDir/lmsRlmsDomD.sh
. $libDir/lmsScriptName.sh
. $libDir/lmsStack.sh
. $libDir/lmsStartup.sh
. $libDir/lmsStr.sh
. $libDir/lmsUId
. $libDir/lmsUtilities.sh
. $libDir/lmsXMLParse
. $libDir/lmsXPath.sh

# *****************************************************************************
# *****************************************************************************
#
#   		Global variables
#
# *****************************************************************************
# *****************************************************************************

lmsapp_errors="$etcDir/errorCodes.xml"  		# where to find the error code definitions

lmssvn_help="$PWD/lms-svnHelp.xml"  			# where to find the help message file
lmssvn_options="$PWD/lms-svnOptions.xml"		# where to find the options declarations
lmssvn_variables="$PWD/lms-svnVariables.xml"	# where to find the options declarations

lmscli_opt="$etcDir/cliOptions.xml"			# cli option defaults

# *****************************************************************************
#
#	displayHelp
#
#		Display the contents of the help file
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors
#		non-zero = error code
#
# *****************************************************************************
displayHelp()
{
	[[ -z "${lmssvn_helpMessage}" ]] &&
	 {
		lmsHelpInit ${lmssvn_help}
		[[ $? -eq 0 ]] ||
		 {
			lmsLogMessage $LINENO "HelpError" "Help initialize '${lmssvn_help}' failed: $?"
			return 1
		 }

		lmssvn_helpMessage=$( lmsHelpToStr )
		[[ $? -eq 0 ]] ||
		 {
			lmsLogMessage $LINENO "HelpError" "lmsHelpToStr failed: $?"
			return 2
		 }
	 }

	lmsLogDisplay "${lmssvn_helpMessage}"
	return 0
}

# *******************************************************************************
#
#   checkOption
#
#	 	check the requested option has a presence and value
#
#	parameters:
#		optionLocal = cli name of the option
#		optionName = value of the option
#
#	returns:
#		0 ==> no errors
#		1 ==> missing repository branch
#
# *******************************************************************************
checkOption()
{
	local optionLocal=${1:-""}
	local optionName=${2:-""}

	if [[ -z "${optionLocal}" || ! " ${!lmscli_shellParam[@]} " =~ "${optionLocal}" ||  -z "${optionName}" ]]
	then
		return 1
	fi

	return 0
}

# *******************************************************************************
#
#   getRepositoryBranch
#
#	 	get SVN branch name
#
#	parameters:
#		none
#
#	returns:
#		0 ==> no errors
#		1 ==> missing repository branch
#
# *******************************************************************************
getRepositoryBranch()
{
	checkOption "branch" "${lmscli_optBranch}"
	return $?
}

# *******************************************************************************
#
#   getSourcePath
#
#	 get SVN Source Folder path
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors.
#
# *******************************************************************************
getSourcePath()
{
	checkOption "source" "${lmscli_optSource}"
	return $?
}

# *******************************************************************************
#
#   getRepositoryPath
#
#	 get SVN Repository Folder path
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors.
#		1 = missing svn repository path
#
# *******************************************************************************
getRepositoryPath()
{
	checkOption "svn" "${lmscli_optSvn}"
	return $?
}

# *******************************************************************************
#
#   getRepository
#
#	 get SVN Repository name
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors.
#		1 = missing svn repository name
#
# *******************************************************************************
getRepository()
{
	checkOption "repo" "${lmscli_optRepo}"
	return $?
}

# *******************************************************************************
#
#   getHost
#
#	 get SVN host
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors.
#		1 = missing svn host address/name
#
# *******************************************************************************
getHost()
{
	checkOption "host" "${lmscli_optHost}"
	return $?
}

# *******************************************************************************
#
#	checkResult
#
#		check the result status, exit if error
#
#	parameters:
#		result = result to check
#		lineNumber = calling line number
#		errorCode = integer error code
#		message = error message
#
#	returns:
#		0 = no errors.
#		1 = missing svn repository name
#
# *******************************************************************************
checkResult()
{
	result=${1}

	[[ ${result} -eq 0 ]] ||
	 {
   		lmsErrorQWrite $2 $3 $4
		lmsErrorQDispPop
		lmsErrorExitScript EndInError
	 }

	return 0
}

# *******************************************************************************
#
#   getOptions
#
#	 get SVN options
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors.
#
# *******************************************************************************
getOptions()
{
	lmsUtilIsUser
	checkResult $? $LINENO SvnRepository "Program must be run by sudo user."

	getHost
	checkResult $? $LINENO "SvnRepository" "Missing host name"

	getRepositoryPath
	checkResult $? $LINENO "SvnRepository" "Missing repository folder path"

	getRepository
	checkResult $? $LINENO "SvnRepository" "Missing repository name"

	getSourcePath
	checkResult $? $LINENO "SvnRepository" "Missing repository source path"

	getRepositoryBranch
	checkResult $? $LINENO "SvnRepository" "Missing repository branch"

	lmssvn_baseDir="${lmscli_optSvn}${lmscli_optSvnName}"
	lmssvn_url="http://${lmscli_optHost}/${lmscli_optSvnName}/"
	lmssvn_repoUrl="${lmssvn_url}${lmscli_optRepo}/"

	lmssvn_repoPath="${lmssvn_baseDir}/${lmscli_optRepo}"

	return 0
}

# *****************************************************************************
#
#	processCliOptions
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
processCliOptions()
{
	lmsCliParse
	[[ $? -eq 0 ]] ||
	 {
		lmsLogMessage $LINENO "ParamError" "cliParameterParse failed."
		lmsErrorExitScript "ParamError"
	 }

	[[ ${lmscli_Errors} -eq 0 ]] &&
	 {
		lmsCliApply
		[[ $? -eq 0 ]] ||
		 {
			lmsLogMessage $LINENO "ParamError" "lmsCliApply failed."
			lmsErrorExitScript "ParamError"
		 }
	 }

	[[ "${lmscli_optHelp}" == "1" ]] &&
	 {
		displayHelp
		exit 0
	 }

	getOptions	
}

# *****************************************************************************
# *****************************************************************************
#
#		MAIN script begins here...
#
# *****************************************************************************
# *****************************************************************************
lmscli_optDebug=0

lmsLogOpen "${lmssvn_logFile}"
[[ $? -eq 0 ]] ||
 {
	lmsConioDisplay "Unable to open log file: '${lmssvn_logFile}'"
	exit 1
 }

lmsStartupInit $lmsscr_Version ${lmsapp_errors}
[[ $? -eq 0 ]] ||
 {
	logMessaage $LINENO "Debug" "Unable to load error codes."
	errorExit "Debug"
 }

lmsConioDisplay "  Log-file: ${lmssvn_logFile}"
lmsConioDisplay ""

lmsXPathSelect ${lmserr_arrayName}
[[ $? -eq 0 ]] ||
 {
	lmsLogMessage $LINENO "XmlError" "Unable to select ${lmserr_arrayName}"
	errorExit "XmlError"
 }

lmsXCfgLoad ${lmssvn_vars} "svnMakeRepo"
[[ $? -eq 0 ]] ||
 {
	lmsLogMessage $LINENO "ConfigXmlError" "lmsXCfgLoad '${lmssvn_vars}'"
	errorExit "ConfigXmlError"
 }

lmsXCfgLoad ${lmssvn_options} "svnMakeRepo"
[[ $? -eq 0 ]] ||
 {
	lmsLogMessage $LINENO "ConfigXmlError" "lmsXCfgLoad '${lmssvn_vars}'"
	errorExit "ConfigXmlError"
 }

# *****************************************************************************

processCliOptions

# *****************************************************************************

if [ ! -d ${lmssvn_baseDir} ]
then
	lmsLogDisplay "Subversion base directory '${lmssvn_baseDir}' does not exist."
	lmsConioDisplay ""
	lmsLogDisplay "Making subversion base directory: '${lmssvn_baseDir}'"
	sudo mkdir "${lmssvn_baseDir}"
	checkResult $? $LINENO "SvnRepository" "mkdir '$lmssvn_baseDir}' failed."

	lmsConioDisplay ""
	lmsLogDisplay "Creating template folders in '${lmssvn_baseDir}/template'"
	sudo mkdir -p "${lmssvn_baseDir}/template/trunk"
	sudo mkdir "${lmssvn_baseDir}/template/branches"
	sudo mkdir "${lmssvn_baseDir}/template/tags"

	lmsConioDisplay ""
	lmsLogDisplay "Changing directory permissions on '${lmssvn_baseDir}'"
	sudo chmod -R "${lmssvn_repoRights}" "${lmssvn_baseDir}"
	checkResult $? $LINENO "SvnRepository" "chmod ${lmssvn_repoRights} ${lmssvn_baseDir} failed."

	lmsConioDisplay ""
	lmsLogDisplay "Changing repository directory owner on '${lmssvn_baseDir}' to ${lmscli_optSvnUser}:${lmscli_optSvnGroup}"
	sudo chown -R "${lmscli_optSvnUser}:${lmscli_optSvnGroup}" "${lmssvn_baseDir}"
	checkResult $? $LINENO "SvnRepository" "chown ${lmssvn_baseDir} failed."

	lmsConioDisplay ""
	lmsLogDisplay "Restarting Apache server"
	sudo $lmscli_optService 1>/dev/null 2>&1
	checkResult $? $LINENO "SvnRepository" "'${lmscli_optService}' failed."
fi

# *******************************************************************************

lmsConioDisplay ""
lmsLogDisplay "Creating repository directory: ${lmssvn_repoPath}"
sudo svnadmin create "${lmssvn_repoPath}"
checkResult $? $LINENO "SvnRepository" "create ${lmssvn_repoPath} failed."

lmsConioDisplay ""
lmsLogDisplay "Changing directory permissions on '${lmssvn_repoPath}' to ${lmssvn_repoRights}"
sudo chmod -R "${lmssvn_repoRights}" "${lmssvn_repoPath}"
checkResult $? $LINENO "SvnRepository" "chmod ${lmssvn_repoRights} ${lmssvn_repoPath} failed."

lmsConioDisplay ""
lmsLogDisplay "Changing repository directory owner on '${lmssvn_repoPath}' to ${lmscli_optSvnUser}:${lmscli_optSvnGroup}"
sudo chown -R "${lmscli_optSvnUser}:${lmscli_optSvnGroup}" "${lmssvn_repoPath}"
checkResult $? $LINENO "SvnRepository" "chown ${lmssvn_repoPath} failed."

[[ ${lmscli_optSelinux} == 1 ]] &&
{
	lmsConioDisplay "Modifying selinux: httpd_sys_content_t"
	sudo chcon -R -t httpd_sys_content_t "${lmssvn_repoPath}"
	checkResult $? $LINENO "SvnRepository" "chcon ${lmssvn_repoPath} failed."

	lmsConioDisplay "Modifying selinux: httpd_sys_rw_content_t"
	sudo chcon -R -t httpd_sys_rw_content_t "${lmssvn_repoPath}"
	checkResult $? $LINENO "SvnRepository" "chcon ${lmssvn_repoPath} failed."
}

lmsConioDisplay ""
lmsLogDisplay "Restarting Apache server"
sudo ${lmscli_optService}  1>/dev/null 2>&1
checkResult $? $LINENO "SvnRepository" "'${lmscli_optService}' failed."

lmsConioDisplay ""
lmsLogDisplay "Importing template folders: ${lmssvn_baseDir}/template/ ${lmssvn_repoUrl}"
if [ $lmscli_optDebug -eq 0 ]
then
	sudo svn import -m 'Template import' "${lmssvn_baseDir}"/template/ "${lmssvn_repoUrl}" 1>/dev/null 2>&1
else
	sudo svn import -m 'Template import' "${lmssvn_baseDir}"/template/ "${lmssvn_repoUrl}"
fi

checkResult $? $LINENO "SvnRepository" "Import template to ${lmssvn_repoUrl} failed."

# *******************************************************************************

[[ -n "$lmscli_optSource" ]] &&
 {
	branchURL="${lmssvn_repoUrl}${lmscli_optBranch}"
	lmsConioDisplay ""
	lmsLogDisplay "Importing source to $branchURL"
	
	if [ $lmscli_optDebug -eq 0 ]
	then
		sudo svn import -m 'Initial source import' "${lmscli_optSource}" "${branchURL}" 1>/dev/null 2>&1
	else
		sudo svn import -m 'Initial source import' "${lmscli_optSource}" "${branchURL}"
	fi

	checkResult $? $LINENO "SvnRepository" "Importing source to ${lmssvn_repoPath} failed."
 }

# *******************************************************************************

lmscli_optSilent=0
lmscli_optOverride=1
lmscli_optNoReset=1

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""

lmsLogDisplay "Repository ${lmssvn_repoPath} has been successfully created."

lmsConioDisplay ""
lmsLogDisplay "    URL: ${lmssvn_repoUrl}"
lmsConioDisplay ""
lmsConioDisplay "    Log: ${lmssvn_logFile}"

# *******************************************************************************

lmsLogClose

[[ ${lmscli_optLogDisplay} -ne 0 ]] &&
 {
	$lmsLogMessage=$( svnReadLog "${lmslog_file}" )
	[[ $? -eq 0 ]] ||
	{
		lmsConioDebug $LINENO "LogError" "Unable to read log file '${lmslog_file}'"
	}
	
	lmsConioDisplay "${lmsLogMessage}"
 }

# *****************************************************************************
# *****************************************************************************

if [ $lmscli_optDebug -ne 0 ]
then
	lmsErrorQDispPop $LINENO "EndOfTest"
fi

lmsConioDisplay " "
exit 0
