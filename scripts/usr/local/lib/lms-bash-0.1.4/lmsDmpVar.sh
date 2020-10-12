# *********************************************************************************
# *********************************************************************************
#
#   lmsDmpVar
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.2
# @copyright © 2016, 2017, 2018. EarthWalk Software.
# @license Licensed under the GNU General Public License, GPL-3.0-or-later.
# @package Linux Management Scripts
# @subpackage dumpVariables
#
# *****************************************************************************
#
#	Copyright © 2016, 2017, 2018. EarthWalk Software
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
#   <http://www.gnu.org/licenses/>.
#
# *****************************************************************************
#
#			Version 0.0.1 - 06-26-2016.
#					0.0.2 - 09-06-2016.
#					0.1.0 - 01-15-2017.
#					0.1.1 - 02-09-2017.
#					0.1.2 - 08-25-2018.
#
# *********************************************************************************
# ***********************************************************************************************************

declare -r lmslib_lmsDumpVar="0.1.2"	# version of library

# ***********************************************************************************************************
#
#	lmsDmpVar
#
#		dump the name table for debug purposes
#
#	attributes:
#		none
#
#	returns:
#		0 = no error
#
# *********************************************************************************
lmsDmpVar()
{
	eval declare -p |
	{
		local -i lineNumber=0

		echo ""
		echo "Variable contents:"

		while IFS= read -r line
		do
    		printf "%s% 5u : %s%s\n" ${lmsclr_Red} $lineNumber "$line" ${lmsclr_NoColor}
			let lineNumber+=1
		done
	}
	
	lmsDmpVarStack
}

# ***********************************************************************************************************
#
#	lmsDmpVarStack
#
#		dump the call stack for debug purposes
#
#	parameterss:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
lmsDmpVarStack()
{
	local frame=0

	echo ""
	echo "Stack contents:"
	echo "---------------"

	while caller $frame
	do
		((frame++));
	done

	echo "$*"

}

# **************************************************************************
#
#	lmsDmpVarCli
#
#		dump the cli parameters to the console
#
#	parameters:
#		none
#
#	returns:
#		0 = found
#		non-zero = not found
#
# **************************************************************************
lmsDmpVarCli()
{
	lmscli_optOverride=1
	lmscli_optNoReset=1

	lmsConioDisplay " "
	lmsConioDisplay "lmslib_cliParametersVersion:  ${lmslib_cliParametersVersion}"

	lmsConioDisplay " "
	lmsConioDisplay "lmscli_Errors:                ${lmscli_Errors}"

	# *******************************************************

	lmsConioDisplay " "
	lmsConioDisplay "lmscli_ParamList:         ${lmscli_ParamList}"
	lmsConioDisplay "lmscli_ParamCount:        ${#lmscli_InputParam[@]}"

	# *******************************************************

	lmsConioDisplay "lmscli_InputErrors:           ${#lmscli_InputErrors[@]}"

	lmsConioDisplay " "
	if [ ${#lmscli_InputErrors[@]} -ne 0 ]
	then
		for name in "${lmscli_InputErrors[@]}"
		do
			lmsConioDisplay "lmscli_InputErrorCount   ${lmsclr_Red}${lmsclr_Bold}${name}${lmsclr_NoColor} => ${lmscli_InputParam[$name]}"
		done

		lmsConioDisplay " "
	else
		lmsConioDisplay "lmscli_InputErrors            ***** NO ENTRIES *****"
	fi

	if [ ${#lmscli_InputParam[@]} -ne 0 ]
	then
		for name in "${!lmscli_InputParam[@]}"
		do
			if [[ " ${!lmscli_InputErrors[@]} " =~ "${name}" ]]
			then
				lmsConioDisplay "lmscli_InputParam        ${lmsclr_Red}${name}${lmsclr_NoColor} => ${lmscli_InputParam[$name]}"
			else
				lmsConioDisplay "lmscli_InputParam        $name => ${lmscli_InputParam[$name]}"
			fi
		done
	else
		lmsConioDisplay "lmscli_InputParam        ***** NO ENTRIES *****"
	fi

	# *******************************************************

	lmsConioDisplay " "
	lmsConioDisplay "lmscli_command:               ${lmscli_command}"
	lmsConioDisplay "lmscli_cmndErrors:         ${lmscli_cmndErrors}"
	lmsConioDisplay ""
	
	if [ ${#lmscli_cmndsValid[@]} -ne 0 ]
	then
		for name in "${!lmscli_cmndsValid[@]}"
		do
			lmsConioDisplay "lmscli_cmndsValid      ${name} => ${lmscli_cmndsValid[$name]}"
		done
	else
		lmsConioDisplay "lmscli_cmndsValid      ***** NO ENTRIES *****"
	fi

	# *******************************************************

	lmsConioDisplay " "
	if [ ${#lmscli_shellParam[@]} -ne 0 ]
	then
		for name in "${!lmscli_shellParam[@]}"
		do
			lmsConioDisplay "lmscli_shellParam        $name => ${lmscli_shellParam[$name]}"
		done
	else
		lmsConioDisplay "lmscli_shellParam        ***** NO ENTRIES *****"
	fi

	# *******************************************************

	lmsConioDisplay " "
	if [ ${#lmscli_shellParam[@]} -ne 0 ]
	then
		local index=0
		for name in "${!lmscli_shellParam[@]}"
		do
			lmsConioDisplay "lmscli_ValidParameters        ${index}  =>  ${name}"
			(( index+=1 ))
		done
	else
		lmsConioDisplay "lmscli_ValidParameters         ***** NO ENTRIES *****"
	fi

	# *******************************************************

	lmsConioDisplay " "

	lmscli_optNoReset=0
	lmscli_optOverride=0
	
	declare -p | grep lmscli_
}

# **************************************************************************
#
#	lmsDmpVarUids
#
#		dump the contents of the Uid Table for inspection
#
#	parameters:
#		none
#
#	returns:
#		0 = found
#		non-zero = not found
#
# **************************************************************************
lmsDmpVarUids()
{
	local element
	local table=( "${lmsuid_Unique[@]}" )

	lmsConioDisplay "Unique id table:"

	local index=0
	for element in "${lmsuid_Unique[@]}"
	do
		printf -v elemBuffer "% 5u:    %s" $index $element 
		(( index++ ))
	done
}

# *******************************************************
#
#	lmsDmpVarDOM
#
#		Show the xml data element selected
#
# *******************************************************
function lmsDmpVarDOM()
{
	local content

	lmsConioDisplay "XML_ENTITY    : '${lmsdom_Entity}'"

	lmsStrTrim "${lmsdom_Content}" lmsdom_Content

	lmsConioDisplay "XML_CONTENT   :     '${lmsdom_Content}'"
	lmsConioDisplay "XML_TAG_NAME  :     '${lmsdom_TagName}'"
	lmsConioDisplay "XML_TAG_TYPE  :     '${lmsdom_TagType}'"

	if [[ "${lmsdom_TagType}" == "OPEN" || "${lmsdom_TagType}" == "OPENCLOSE" ]]
	then
		if [ -n "${lmsdom_attribs}" ]
		then
			lmsRDomParseAtt
			lmsdom_attribCount=${#lmsdom_attArray[@]}

			lmsConioDisplay "XML_ATT_COUNT :     '${lmsdom_attribCount}'"
		
			for attribute in "${!lmsdom_attArray[@]}"
			do
				lmsConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				lmsConioDisplay "XML_ATT_VAL   :     '${lmsdom_attArray[$attribute]}'"
			done
		fi
	fi

	lmsStrTrim "${lmsdom_Comment}" lmsdom_Comment

	lmsConioDisplay "XML_COMMENT   :     '${lmsdom_Comment}'"
	lmsConioDisplay "XML_PATH      :     '${lmsdom_Path}'"
	lmsConioDisplay "XPATH         :     '${lmsdom_XPath}'"

	lmsConioDisplay ""
}

# *******************************************************
#
#	lmsDmpVarSelected
#
#		Show the selected variables
#
#	Parameters:
#		selectString = grep selection string
#
#	Returns:
#		0 = no error
#
# *******************************************************
function lmsDmpVarSelected()
{
	local selectString="${1}"
	
	declare -p | grep "$selectString"
	echo ""

	return 0
}

