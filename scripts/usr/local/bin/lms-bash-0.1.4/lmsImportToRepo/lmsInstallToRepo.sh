# *****************************************************************************
# *****************************************************************************
#
#   lmsInstallToRepo.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage lmsInstallScript
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
#			Version 0.0.1 - 05-20-2016.
#
# *****************************************************************************
# *****************************************************************************

# *******************************************************
# *******************************************************
#
#		External Scripts
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
	rootDir=".."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/arraySort.sh
. $libDir/lmsCli.sh
. $libDir/lmsColorDef.sh
. $libDir/lmsConio.sh
. $libDir/lmsError.sh
. $libDir/lmsErrorQDisp.sh
. $libDir/lmsErrorQ.sh
. $libDir/lmsScriptName.sh
. $libDir/lmsDeclare.sh
. $libDir/lmsStack.sh
. $libDir/lmsStartup.sh
. $libDir/lmsStr.sh
. $libDir/lmsUId
. $libDir/xmlParser.sh
. $libDir/lmsXPath.sh

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************

lmsscr_Version="0.0.1"		# script version
lmsapp_errors="$etcDir/errorCodes.xml"

# *******************************************************
# *******************************************************
#
#		Start main program below here
#
# *******************************************************
# *******************************************************


# *******************************************************
#
#	displayHelp
#
#	parameters:
#		none
#
#	returns:
#		$? = 0 ==> no errors.
#
# *******************************************************
displayHelp()
{
	if [ -z "${helpMessage}" ]
	then
		startupBuildHelp
	fi

	lmsConioDisplay "${helpMessage}"
}

# *******************************************************
#
#	lmsDmpVar
#
#	parameters:
#		none
#
#	returns:
#		$? = 0 ==> no errors.
#
# *******************************************************
lmsDmpVar()
{
	lmscli_optOverride=1
	lmscli_optNoReset=1

	lmsConioDisplay "subversion:"
	if [ ${#subversion[@]} -ne 0 ]
	then
		for name in "${!subversion[@]}"
		do
			lmsConioDisplay "    lmsDmpVar         $name => ${subversion[$name]}"
		done
	else
		lmsConioDisplay "lmsDmpVar         ***** NO ENTRIES *****"
	fi

	# *******************************************************

	lmsConioDisplay "installOptions:"
	if [ ${#installOptions[@]} -ne 0 ]
	then
		for name in "${!installOptions[@]}"
		do
			lmsConioDisplay "    installlmsDmpVar         $name => ${installOptions[$name]}"
		done
	else
		lmsConioDisplay "installlmsDmpVar         ***** NO ENTRIES *****"
	fi

	# *******************************************************

	lmsConioDisplay "cli structures:"
	lmsDmpVarCli

	lmscli_optNoReset=0
	lmscli_optOverride=0
}

# *******************************************************
#
#   getRepositoryBranch
#
#	 	get SVN branch name
#
#	parameters:
#		none
#
#	returns:
#		$? = 0 ==> no errors
#		$? = 1 ==> missing repository branch
#
# *******************************************************
getRepositoryBranch()
{
	if [[ " ${!lmscli_shellParam[@]} " =~ "branch" ]]
	then
		svnBranch=${lmscli_shellParam[branch]}
	fi

	if [ -z "${svnBranch}" ]
	then
		lmsErrorQWrite $LINENO "SvnRepository" "Missing repository branch"
		return 1
	fi

	return 0
}

# *******************************************************
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
# *******************************************************
getSourcePath()
{
	if [[ " ${!lmscli_shellParam[@]} " =~ "source" ]]
	then
		repoSource=${lmscli_shellParam[source]}
	fi

	return 0
}

# *******************************************************
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
# *******************************************************
getRepositoryPath()
{
	if [[ " ${!lmscli_shellParam[@]} " =~ "svn" ]]
	then
		svnPath=${lmscli_shellParam[svn]}
	else
		if [ -z "${svnPath}" ]
		then
			lmsConioPrompt "Enter path to SVN Repository Folder"

			if [ -z "${REPLY}" ]
			then
				lmsErrorQWrite $LINENO "SvnRepository" "Missing repository path"
				return 1
			fi

			svnPath=${REPLY}
		fi
	fi

	return 0
}

# *******************************************************
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
# *******************************************************
getRepository()
{
	if [[ " ${!lmscli_shellParam[@]} " =~ "name" ]]
	then
		repository=${lmscli_shellParam[name]}
	else 
		if [ -z "${repository}" ]
		then
			lmsConioPrompt "Enter SVN Repository name"
			if [ -z "${REPLY}" ]
			then
				lmsErrorQWrite $LINENO "SvnRepository" "Missing repository name"
				return 1
			fi

			repository=${REPLY}
		fi
	fi

	if [ "${repository:0:1}" == "/" ]
	then
		repoPath=${repository}
	else
		repoPath="${svnPath}${repository}"
	fi

	return 0
}

# *******************************************************
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
# *******************************************************
getHost()
{
	if [[ " ${!lmscli_shellParam[@]} " =~ "host" ]]
	then
		svnHost=${lmscli_shellParam[host]}
	else
		if [ -z "${svnHost}" ]
		then
			lmsConioPrompt "Enter host name/address"

			if [ -z "${REPLY}" ]
			then
				lmsErrorQWrite $LINENO "SvnRepository" "Missing host name/address"
				return 1
			fi

			svnHost=${REPLY}
		fi
	fi

	return 0
}

# *******************************************************
#
#   getOptions
#
#	 get/set lmsInstallScript variables
#
#	parameters:
#		none
#
#	returns:
#		0 = no errors.
#
# *******************************************************
getOptions()
{
	lmsUtilIsUser
	checkResult $? $LINENO SvnRepository "Program must be run by sudo user."

	getHost
	checkResult $? $LINENO SvnRepository "Missing host name"

	getRepositoryPath
	checkResult $? $LINENO SvnRepository "Missing repository folder path"

	getRepository
	checkResult $? $LINENO SvnRepository "Missing repository name"

	getSourcePath
	getSourcePath

	svnURL="http://${svnHost}/svn/${repository}"

	return 0
}

# *******************************************************
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
# *******************************************************
checkResult()
{
	result=$1

	if [ $result -ne 0 ]
	then
   		lmsErrorQWrite $2 $3 $4
		lmsErrorQDispPop
		lmsErrorExitScript EndInError
	fi

	return 0
}

# *******************************************************
# *******************************************************
#
#		MAIN script begins here...
#
# *******************************************************
# *******************************************************

lmscli_Validate=1

lmscli_ParamBuffer=( "$@" )
lmsStartupInit "1.0.0" $lmsapp_errors $lmsvar_help $lmsVariables

case $? in

	0)	if [[ " ${!lmscli_shellParam[@]} " =~ "help" ]] || [ "$lmscli_command" = "help" ]
		then
			displayHelp
			$LINENO "EndOfTest"			
		fi
		;;

	1)	dumpNameTable
		lmsErrorExitScript MissAssign
		;;

	*)	lmsErrorExitScript Unknown
		;;

esac

# *******************************************************
#
#	check that all parameters have been supplied
#
# *******************************************************

if [ $lmscli_optProduction -ne 1 ]
then
	varShellDum
	lmsConioDisplay "**************************"

	lmsDmpVar
	lmsConioDisplay "**************************"

	$LINENO "EndOfTest"
fi

getOptions

lmsConioDisplay "Creating repository directory: ${repoPath}"
sudo svnadmin create "${repoPath}"
checkResult $? $LINENO SvnRepository "create ${repoPath} failed."

lmsConioDisplay "Changing repository directory owner"
sudo chown -R apache.apache "${repoPath}"
checkResult $? $LINENO SvnRepository "chown ${repoPath} failed."

lmsConioDisplay "Modifying selinux: httpd_sys_content_t"
sudo chcon -R -t httpd_sys_content_t "${repoPath}"
checkResult $? $LINENO SvnRepository "chcon ${repoPath} failed."

lmsConioDisplay "Modifying selinux: httpd_sys_rw_content_t"
sudo chcon -R -t httpd_sys_rw_content_t "${repoPath}"
checkResult $? $LINENO SvnRepository "chcon ${repoPath} failed."

lmsConioDisplay "Restarting httpd service"
sudo systemctl restart httpd.service
checkResult $? $LINENO SvnRepository "systemctl restart httpd.service failed."

lmsConioDisplay "Importing folder template"

if [ $lmscli_optDebug -ne 0 ]
then
	svn import -m 'Template import' "${svnPath}"/template/ "${svnURL}"
else
	svn import -m 'Template import' "${svnPath}"/template/ "${svnURL}" 1>/dev/null 2>&1
fi

checkResult $? $LINENO SvnRepository "Import template to ${repoPath} failed."

if [ -n "$repoSource" ]
then
	branchURL="${svnURL}/${svnBranch}"
	lmsConioDisplay "Importing source to $branchURL"
	
	if [ $lmscli_optDebug -ne 0 ]
	then
		svn import -m 'Initial source import' "${repoSource}" "${branchURL}"
	else
		svn import -m 'Initial source import' "${repoSource}" "${branchURL}" 1>/dev/null 2>&1
	fi

	checkResult $? $LINENO SvnRepository "Importing source to ${repoPath} failed."
fi

lmsConioDisplay ""
lmsConioDisplay "*******************************************************"
lmsConioDisplay ""
lmsConioDisplay "Repository ${repository} successfully created."
lmsConioDisplay "    URL: ${svnURL}";

# *******************************************************
# *******************************************************

if [ $lmscli_optDebug -ne 0 ]
then
	lmsErrorQDispPop
	$LINENO "EndOfTest"
fi

lmsConioDisplay " "
exit 0
