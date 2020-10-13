# *****************************************************************************
# *****************************************************************************
#
#   ldcInstallToRepo.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.0.1
# @copyright © 2016. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage ldcInstallScript
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

declare -i ldccli_optProduction=0

if [ $ldccli_optProduction -eq 1 ]
then
	rootDir="/usr/local"
	libDir="$rootDir/lib/ldc/bash"
	etcDir="$rootDir/etc/ldc"
else
	rootDir=".."
	libDir="$rootDir/lib"
	etcDir="$rootDir/etc"
fi

. $libDir/arraySort.sh
. $libDir/ldcCli.sh
. $libDir/ldcColorDef.sh
. $libDir/ldcConio.sh
. $libDir/ldcError.sh
. $libDir/ldcErrorQDisp.sh
. $libDir/ldcErrorQ.sh
. $libDir/ldcScriptName.sh
. $libDir/ldcDeclare.sh
. $libDir/ldcStack.sh
. $libDir/ldcStartup.sh
. $libDir/ldcStr.sh
. $libDir/ldcUId
. $libDir/xmlParser.sh
. $libDir/ldcXPath.sh

# *******************************************************
# *******************************************************
#
#   Global variables - modified by program flow
#
# *******************************************************
# *******************************************************

ldcscr_Version="0.0.1"		# script version
ldcapp_errors="$etcDir/errorCodes.xml"

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

	ldcConioDisplay "${helpMessage}"
}

# *******************************************************
#
#	ldcDmpVar
#
#	parameters:
#		none
#
#	returns:
#		$? = 0 ==> no errors.
#
# *******************************************************
ldcDmpVar()
{
	ldccli_optOverride=1
	ldccli_optNoReset=1

	ldcConioDisplay "subversion:"
	if [ ${#subversion[@]} -ne 0 ]
	then
		for name in "${!subversion[@]}"
		do
			ldcConioDisplay "    ldcDmpVar         $name => ${subversion[$name]}"
		done
	else
		ldcConioDisplay "ldcDmpVar         ***** NO ENTRIES *****"
	fi

	# *******************************************************

	ldcConioDisplay "installOptions:"
	if [ ${#installOptions[@]} -ne 0 ]
	then
		for name in "${!installOptions[@]}"
		do
			ldcConioDisplay "    installldcDmpVar         $name => ${installOptions[$name]}"
		done
	else
		ldcConioDisplay "installldcDmpVar         ***** NO ENTRIES *****"
	fi

	# *******************************************************

	ldcConioDisplay "cli structures:"
	ldcDmpVarCli

	ldccli_optNoReset=0
	ldccli_optOverride=0
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
	if [[ " ${!ldccli_shellParam[@]} " =~ "branch" ]]
	then
		svnBranch=${ldccli_shellParam[branch]}
	fi

	if [ -z "${svnBranch}" ]
	then
		ldcErrorQWrite $LINENO "SvnRepository" "Missing repository branch"
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
	if [[ " ${!ldccli_shellParam[@]} " =~ "source" ]]
	then
		repoSource=${ldccli_shellParam[source]}
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
	if [[ " ${!ldccli_shellParam[@]} " =~ "svn" ]]
	then
		svnPath=${ldccli_shellParam[svn]}
	else
		if [ -z "${svnPath}" ]
		then
			ldcConioPrompt "Enter path to SVN Repository Folder"

			if [ -z "${REPLY}" ]
			then
				ldcErrorQWrite $LINENO "SvnRepository" "Missing repository path"
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
	if [[ " ${!ldccli_shellParam[@]} " =~ "name" ]]
	then
		repository=${ldccli_shellParam[name]}
	else 
		if [ -z "${repository}" ]
		then
			ldcConioPrompt "Enter SVN Repository name"
			if [ -z "${REPLY}" ]
			then
				ldcErrorQWrite $LINENO "SvnRepository" "Missing repository name"
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
	if [[ " ${!ldccli_shellParam[@]} " =~ "host" ]]
	then
		svnHost=${ldccli_shellParam[host]}
	else
		if [ -z "${svnHost}" ]
		then
			ldcConioPrompt "Enter host name/address"

			if [ -z "${REPLY}" ]
			then
				ldcErrorQWrite $LINENO "SvnRepository" "Missing host name/address"
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
#	 get/set ldcInstallScript variables
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
	ldcUtilIsUser
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
   		ldcErrorQWrite $2 $3 $4
		ldcErrorQDispPop
		ldcErrorExitScript EndInError
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

ldccli_Validate=1

ldccli_ParamBuffer=( "$@" )
ldcStartupInit "1.0.0" $ldcapp_errors $ldcvar_help $ldcVariables

case $? in

	0)	if [[ " ${!ldccli_shellParam[@]} " =~ "help" ]] || [ "$ldccli_command" = "help" ]
		then
			displayHelp
			$LINENO "EndOfTest"			
		fi
		;;

	1)	dumpNameTable
		ldcErrorExitScript MissAssign
		;;

	*)	ldcErrorExitScript Unknown
		;;

esac

# *******************************************************
#
#	check that all parameters have been supplied
#
# *******************************************************

if [ $ldccli_optProduction -ne 1 ]
then
	varShellDum
	ldcConioDisplay "**************************"

	ldcDmpVar
	ldcConioDisplay "**************************"

	$LINENO "EndOfTest"
fi

getOptions

ldcConioDisplay "Creating repository directory: ${repoPath}"
sudo svnadmin create "${repoPath}"
checkResult $? $LINENO SvnRepository "create ${repoPath} failed."

ldcConioDisplay "Changing repository directory owner"
sudo chown -R apache.apache "${repoPath}"
checkResult $? $LINENO SvnRepository "chown ${repoPath} failed."

ldcConioDisplay "Modifying selinux: httpd_sys_content_t"
sudo chcon -R -t httpd_sys_content_t "${repoPath}"
checkResult $? $LINENO SvnRepository "chcon ${repoPath} failed."

ldcConioDisplay "Modifying selinux: httpd_sys_rw_content_t"
sudo chcon -R -t httpd_sys_rw_content_t "${repoPath}"
checkResult $? $LINENO SvnRepository "chcon ${repoPath} failed."

ldcConioDisplay "Restarting httpd service"
sudo systemctl restart httpd.service
checkResult $? $LINENO SvnRepository "systemctl restart httpd.service failed."

ldcConioDisplay "Importing folder template"

if [ $ldccli_optDebug -ne 0 ]
then
	svn import -m 'Template import' "${svnPath}"/template/ "${svnURL}"
else
	svn import -m 'Template import' "${svnPath}"/template/ "${svnURL}" 1>/dev/null 2>&1
fi

checkResult $? $LINENO SvnRepository "Import template to ${repoPath} failed."

if [ -n "$repoSource" ]
then
	branchURL="${svnURL}/${svnBranch}"
	ldcConioDisplay "Importing source to $branchURL"
	
	if [ $ldccli_optDebug -ne 0 ]
	then
		svn import -m 'Initial source import' "${repoSource}" "${branchURL}"
	else
		svn import -m 'Initial source import' "${repoSource}" "${branchURL}" 1>/dev/null 2>&1
	fi

	checkResult $? $LINENO SvnRepository "Importing source to ${repoPath} failed."
fi

ldcConioDisplay ""
ldcConioDisplay "*******************************************************"
ldcConioDisplay ""
ldcConioDisplay "Repository ${repository} successfully created."
ldcConioDisplay "    URL: ${svnURL}";

# *******************************************************
# *******************************************************

if [ $ldccli_optDebug -ne 0 ]
then
	ldcErrorQDispPop
	$LINENO "EndOfTest"
fi

ldcConioDisplay " "
exit 0
