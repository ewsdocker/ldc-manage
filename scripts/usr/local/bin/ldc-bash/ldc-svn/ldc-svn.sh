#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#		ldc-svn.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package ldc-svn
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
ldcscr_Version="0.1.3"

# *****************************************************************************
# *****************************************************************************
#
#		External Scripts
#
# *****************************************************************************
# *****************************************************************************

ldccli_optProduction=0

if [ $ldccli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/ldc/bash"
	etcDir="$rootDir/etc/ldc"
else
	rootDir="../.."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/arraySort.sh
. $libDir/ldcCli.sh
. $libDir/ldcColorDef.sh
. $libDir/ldcConio.sh
. $libDir/ldcXCfg.sh
. $libDir/ldcDomN.sh
. $libDir/ldcDomR.sh
. $libDir/ldcDomTs.sh
. $libDir/ldcDmpVar
. $libDir/dynamicArrayFunctions.sh
. $libDir/dynamicArrayIterator.sh
. $libDir/ldcError.sh
. $libDir/ldcErrorQDisp.sh
. $libDir/ldcErrorQ.sh
. $libDir/ldcHelp.sh
. $libDir/ldcDeclare.sh
. $libDir/ldcLog.sh
. $libDir/ldcLogRead.sh
. $libDir/ldcRldcDomD.sh
. $libDir/ldcScriptName.sh
. $libDir/ldcStack.sh
. $libDir/ldcStartup.sh
. $libDir/ldcStr.sh
. $libDir/ldcUId
. $libDir/ldcUtilities.sh
. $libDir/ldcXMLParse
. $libDir/ldcXPath.sh

# *****************************************************************************
# *****************************************************************************
#
#   		Global variables
#
# *****************************************************************************
# *****************************************************************************

ldcapp_errors="$etcDir/errorCodes.xml"  		# where to find the error code definitions

ldcsvn_help="$PWD/ldc-svnHelp.xml"  			# where to find the help message file
ldcsvn_options="$PWD/ldc-svnOptions.xml"		# where to find the options declarations
ldcsvn_variables="$PWD/ldc-svnVariables.xml"	# where to find the options declarations

ldccli_opt="$etcDir/cliOptions.xml"			# cli option defaults

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
	[[ -z "${ldcsvn_helpMessage}" ]] &&
	 {
		ldcHelpInit ${ldcsvn_help}
		[[ $? -eq 0 ]] ||
		 {
			ldcLogMessage $LINENO "HelpError" "Help initialize '${ldcsvn_help}' failed: $?"
			return 1
		 }

		ldcsvn_helpMessage=$( ldcHelpToStr )
		[[ $? -eq 0 ]] ||
		 {
			ldcLogMessage $LINENO "HelpError" "ldcHelpToStr failed: $?"
			return 2
		 }
	 }

	ldcLogDisplay "${ldcsvn_helpMessage}"
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

	if [[ -z "${optionLocal}" || ! " ${!ldccli_shellParam[@]} " =~ "${optionLocal}" ||  -z "${optionName}" ]]
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
	checkOption "branch" "${ldccli_optBranch}"
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
	checkOption "source" "${ldccli_optSource}"
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
	checkOption "svn" "${ldccli_optSvn}"
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
	checkOption "repo" "${ldccli_optRepo}"
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
	checkOption "host" "${ldccli_optHost}"
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
   		ldcErrorQWrite $2 $3 $4
		ldcErrorQDispPop
		ldcErrorExitScript EndInError
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
	ldcUtilIsUser
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

	ldcsvn_baseDir="${ldccli_optSvn}${ldccli_optSvnName}"
	ldcsvn_url="http://${ldccli_optHost}/${ldccli_optSvnName}/"
	ldcsvn_repoUrl="${ldcsvn_url}${ldccli_optRepo}/"

	ldcsvn_repoPath="${ldcsvn_baseDir}/${ldccli_optRepo}"

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
	ldcCliParse
	[[ $? -eq 0 ]] ||
	 {
		ldcLogMessage $LINENO "ParamError" "cliParameterParse failed."
		ldcErrorExitScript "ParamError"
	 }

	[[ ${ldccli_Errors} -eq 0 ]] &&
	 {
		ldcCliApply
		[[ $? -eq 0 ]] ||
		 {
			ldcLogMessage $LINENO "ParamError" "ldcCliApply failed."
			ldcErrorExitScript "ParamError"
		 }
	 }

	[[ "${ldccli_optHelp}" == "1" ]] &&
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
ldccli_optDebug=0

ldcLogOpen "${ldcsvn_logFile}"
[[ $? -eq 0 ]] ||
 {
	ldcConioDisplay "Unable to open log file: '${ldcsvn_logFile}'"
	exit 1
 }

ldcStartupInit $ldcscr_Version ${ldcapp_errors}
[[ $? -eq 0 ]] ||
 {
	logMessaage $LINENO "Debug" "Unable to load error codes."
	errorExit "Debug"
 }

ldcConioDisplay "  Log-file: ${ldcsvn_logFile}"
ldcConioDisplay ""

ldcXPathSelect ${ldcerr_arrayName}
[[ $? -eq 0 ]] ||
 {
	ldcLogMessage $LINENO "XmlError" "Unable to select ${ldcerr_arrayName}"
	errorExit "XmlError"
 }

ldcXCfgLoad ${ldcsvn_vars} "svnMakeRepo"
[[ $? -eq 0 ]] ||
 {
	ldcLogMessage $LINENO "ConfigXmlError" "ldcXCfgLoad '${ldcsvn_vars}'"
	errorExit "ConfigXmlError"
 }

ldcXCfgLoad ${ldcsvn_options} "svnMakeRepo"
[[ $? -eq 0 ]] ||
 {
	ldcLogMessage $LINENO "ConfigXmlError" "ldcXCfgLoad '${ldcsvn_vars}'"
	errorExit "ConfigXmlError"
 }

# *****************************************************************************

processCliOptions

# *****************************************************************************

if [ ! -d ${ldcsvn_baseDir} ]
then
	ldcLogDisplay "Subversion base directory '${ldcsvn_baseDir}' does not exist."
	ldcConioDisplay ""
	ldcLogDisplay "Making subversion base directory: '${ldcsvn_baseDir}'"
	sudo mkdir "${ldcsvn_baseDir}"
	checkResult $? $LINENO "SvnRepository" "mkdir '$ldcsvn_baseDir}' failed."

	ldcConioDisplay ""
	ldcLogDisplay "Creating template folders in '${ldcsvn_baseDir}/template'"
	sudo mkdir -p "${ldcsvn_baseDir}/template/trunk"
	sudo mkdir "${ldcsvn_baseDir}/template/branches"
	sudo mkdir "${ldcsvn_baseDir}/template/tags"

	ldcConioDisplay ""
	ldcLogDisplay "Changing directory permissions on '${ldcsvn_baseDir}'"
	sudo chmod -R "${ldcsvn_repoRights}" "${ldcsvn_baseDir}"
	checkResult $? $LINENO "SvnRepository" "chmod ${ldcsvn_repoRights} ${ldcsvn_baseDir} failed."

	ldcConioDisplay ""
	ldcLogDisplay "Changing repository directory owner on '${ldcsvn_baseDir}' to ${ldccli_optSvnUser}:${ldccli_optSvnGroup}"
	sudo chown -R "${ldccli_optSvnUser}:${ldccli_optSvnGroup}" "${ldcsvn_baseDir}"
	checkResult $? $LINENO "SvnRepository" "chown ${ldcsvn_baseDir} failed."

	ldcConioDisplay ""
	ldcLogDisplay "Restarting Apache server"
	sudo $ldccli_optService 1>/dev/null 2>&1
	checkResult $? $LINENO "SvnRepository" "'${ldccli_optService}' failed."
fi

# *******************************************************************************

ldcConioDisplay ""
ldcLogDisplay "Creating repository directory: ${ldcsvn_repoPath}"
sudo svnadmin create "${ldcsvn_repoPath}"
checkResult $? $LINENO "SvnRepository" "create ${ldcsvn_repoPath} failed."

ldcConioDisplay ""
ldcLogDisplay "Changing directory permissions on '${ldcsvn_repoPath}' to ${ldcsvn_repoRights}"
sudo chmod -R "${ldcsvn_repoRights}" "${ldcsvn_repoPath}"
checkResult $? $LINENO "SvnRepository" "chmod ${ldcsvn_repoRights} ${ldcsvn_repoPath} failed."

ldcConioDisplay ""
ldcLogDisplay "Changing repository directory owner on '${ldcsvn_repoPath}' to ${ldccli_optSvnUser}:${ldccli_optSvnGroup}"
sudo chown -R "${ldccli_optSvnUser}:${ldccli_optSvnGroup}" "${ldcsvn_repoPath}"
checkResult $? $LINENO "SvnRepository" "chown ${ldcsvn_repoPath} failed."

[[ ${ldccli_optSelinux} == 1 ]] &&
{
	ldcConioDisplay "Modifying selinux: httpd_sys_content_t"
	sudo chcon -R -t httpd_sys_content_t "${ldcsvn_repoPath}"
	checkResult $? $LINENO "SvnRepository" "chcon ${ldcsvn_repoPath} failed."

	ldcConioDisplay "Modifying selinux: httpd_sys_rw_content_t"
	sudo chcon -R -t httpd_sys_rw_content_t "${ldcsvn_repoPath}"
	checkResult $? $LINENO "SvnRepository" "chcon ${ldcsvn_repoPath} failed."
}

ldcConioDisplay ""
ldcLogDisplay "Restarting Apache server"
sudo ${ldccli_optService}  1>/dev/null 2>&1
checkResult $? $LINENO "SvnRepository" "'${ldccli_optService}' failed."

ldcConioDisplay ""
ldcLogDisplay "Importing template folders: ${ldcsvn_baseDir}/template/ ${ldcsvn_repoUrl}"
if [ $ldccli_optDebug -eq 0 ]
then
	sudo svn import -m 'Template import' "${ldcsvn_baseDir}"/template/ "${ldcsvn_repoUrl}" 1>/dev/null 2>&1
else
	sudo svn import -m 'Template import' "${ldcsvn_baseDir}"/template/ "${ldcsvn_repoUrl}"
fi

checkResult $? $LINENO "SvnRepository" "Import template to ${ldcsvn_repoUrl} failed."

# *******************************************************************************

[[ -n "$ldccli_optSource" ]] &&
 {
	branchURL="${ldcsvn_repoUrl}${ldccli_optBranch}"
	ldcConioDisplay ""
	ldcLogDisplay "Importing source to $branchURL"
	
	if [ $ldccli_optDebug -eq 0 ]
	then
		sudo svn import -m 'Initial source import' "${ldccli_optSource}" "${branchURL}" 1>/dev/null 2>&1
	else
		sudo svn import -m 'Initial source import' "${ldccli_optSource}" "${branchURL}"
	fi

	checkResult $? $LINENO "SvnRepository" "Importing source to ${ldcsvn_repoPath} failed."
 }

# *******************************************************************************

ldccli_optSilent=0
ldccli_optOverride=1
ldccli_optNoReset=1

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""

ldcLogDisplay "Repository ${ldcsvn_repoPath} has been successfully created."

ldcConioDisplay ""
ldcLogDisplay "    URL: ${ldcsvn_repoUrl}"
ldcConioDisplay ""
ldcConioDisplay "    Log: ${ldcsvn_logFile}"

# *******************************************************************************

ldcLogClose

[[ ${ldccli_optLogDisplay} -ne 0 ]] &&
 {
	$ldcLogMessage=$( svnReadLog "${ldclog_file}" )
	[[ $? -eq 0 ]] ||
	{
		ldcConioDebug $LINENO "LogError" "Unable to read log file '${ldclog_file}'"
	}
	
	ldcConioDisplay "${ldcLogMessage}"
 }

# *****************************************************************************
# *****************************************************************************

if [ $ldccli_optDebug -ne 0 ]
then
	ldcErrorQDispPop $LINENO "EndOfTest"
fi

ldcConioDisplay " "
exit 0
