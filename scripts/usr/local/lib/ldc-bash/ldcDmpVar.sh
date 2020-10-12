# *********************************************************************************
# *********************************************************************************
#
#   ldcDmpVar
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

declare -r ldclib_ldcDumpVar="0.1.2"	# version of library

# ***********************************************************************************************************
#
#	ldcDmpVar
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
ldcDmpVar()
{
	eval declare -p |
	{
		local -i lineNumber=0

		echo ""
		echo "Variable contents:"

		while IFS= read -r line
		do
    		printf "%s% 5u : %s%s\n" ${ldcclr_Red} $lineNumber "$line" ${ldcclr_NoColor}
			let lineNumber+=1
		done
	}
	
	ldcDmpVarStack
}

# ***********************************************************************************************************
#
#	ldcDmpVarStack
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
ldcDmpVarStack()
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
#	ldcDmpVarCli
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
ldcDmpVarCli()
{
	ldccli_optOverride=1
	ldccli_optNoReset=1

	ldcConioDisplay " "
	ldcConioDisplay "ldclib_cliParametersVersion:  ${ldclib_cliParametersVersion}"

	ldcConioDisplay " "
	ldcConioDisplay "ldccli_Errors:                ${ldccli_Errors}"

	# *******************************************************

	ldcConioDisplay " "
	ldcConioDisplay "ldccli_ParamList:         ${ldccli_ParamList}"
	ldcConioDisplay "ldccli_ParamCount:        ${#ldccli_InputParam[@]}"

	# *******************************************************

	ldcConioDisplay "ldccli_InputErrors:           ${#ldccli_InputErrors[@]}"

	ldcConioDisplay " "
	if [ ${#ldccli_InputErrors[@]} -ne 0 ]
	then
		for name in "${ldccli_InputErrors[@]}"
		do
			ldcConioDisplay "ldccli_InputErrorCount   ${ldcclr_Red}${ldcclr_Bold}${name}${ldcclr_NoColor} => ${ldccli_InputParam[$name]}"
		done

		ldcConioDisplay " "
	else
		ldcConioDisplay "ldccli_InputErrors            ***** NO ENTRIES *****"
	fi

	if [ ${#ldccli_InputParam[@]} -ne 0 ]
	then
		for name in "${!ldccli_InputParam[@]}"
		do
			if [[ " ${!ldccli_InputErrors[@]} " =~ "${name}" ]]
			then
				ldcConioDisplay "ldccli_InputParam        ${ldcclr_Red}${name}${ldcclr_NoColor} => ${ldccli_InputParam[$name]}"
			else
				ldcConioDisplay "ldccli_InputParam        $name => ${ldccli_InputParam[$name]}"
			fi
		done
	else
		ldcConioDisplay "ldccli_InputParam        ***** NO ENTRIES *****"
	fi

	# *******************************************************

	ldcConioDisplay " "
	ldcConioDisplay "ldccli_command:               ${ldccli_command}"
	ldcConioDisplay "ldccli_cmndErrors:         ${ldccli_cmndErrors}"
	ldcConioDisplay ""
	
	if [ ${#ldccli_cmndsValid[@]} -ne 0 ]
	then
		for name in "${!ldccli_cmndsValid[@]}"
		do
			ldcConioDisplay "ldccli_cmndsValid      ${name} => ${ldccli_cmndsValid[$name]}"
		done
	else
		ldcConioDisplay "ldccli_cmndsValid      ***** NO ENTRIES *****"
	fi

	# *******************************************************

	ldcConioDisplay " "
	if [ ${#ldccli_shellParam[@]} -ne 0 ]
	then
		for name in "${!ldccli_shellParam[@]}"
		do
			ldcConioDisplay "ldccli_shellParam        $name => ${ldccli_shellParam[$name]}"
		done
	else
		ldcConioDisplay "ldccli_shellParam        ***** NO ENTRIES *****"
	fi

	# *******************************************************

	ldcConioDisplay " "
	if [ ${#ldccli_shellParam[@]} -ne 0 ]
	then
		local index=0
		for name in "${!ldccli_shellParam[@]}"
		do
			ldcConioDisplay "ldccli_ValidParameters        ${index}  =>  ${name}"
			(( index+=1 ))
		done
	else
		ldcConioDisplay "ldccli_ValidParameters         ***** NO ENTRIES *****"
	fi

	# *******************************************************

	ldcConioDisplay " "

	ldccli_optNoReset=0
	ldccli_optOverride=0
	
	declare -p | grep ldccli_
}

# **************************************************************************
#
#	ldcDmpVarUids
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
ldcDmpVarUids()
{
	local element
	local table=( "${ldcuid_Unique[@]}" )

	ldcConioDisplay "Unique id table:"

	local index=0
	for element in "${ldcuid_Unique[@]}"
	do
		printf -v elemBuffer "% 5u:    %s" $index $element 
		(( index++ ))
	done
}

# *******************************************************
#
#	ldcDmpVarDOM
#
#		Show the xml data element selected
#
# *******************************************************
function ldcDmpVarDOM()
{
	local content

	ldcConioDisplay "XML_ENTITY    : '${ldcdom_Entity}'"

	ldcStrTrim "${ldcdom_Content}" ldcdom_Content

	ldcConioDisplay "XML_CONTENT   :     '${ldcdom_Content}'"
	ldcConioDisplay "XML_TAG_NAME  :     '${ldcdom_TagName}'"
	ldcConioDisplay "XML_TAG_TYPE  :     '${ldcdom_TagType}'"

	if [[ "${ldcdom_TagType}" == "OPEN" || "${ldcdom_TagType}" == "OPENCLOSE" ]]
	then
		if [ -n "${ldcdom_attribs}" ]
		then
			ldcRDomParseAtt
			ldcdom_attribCount=${#ldcdom_attArray[@]}

			ldcConioDisplay "XML_ATT_COUNT :     '${ldcdom_attribCount}'"
		
			for attribute in "${!ldcdom_attArray[@]}"
			do
				ldcConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				ldcConioDisplay "XML_ATT_VAL   :     '${ldcdom_attArray[$attribute]}'"
			done
		fi
	fi

	ldcStrTrim "${ldcdom_Comment}" ldcdom_Comment

	ldcConioDisplay "XML_COMMENT   :     '${ldcdom_Comment}'"
	ldcConioDisplay "XML_PATH      :     '${ldcdom_Path}'"
	ldcConioDisplay "XPATH         :     '${ldcdom_XPath}'"

	ldcConioDisplay ""
}

# *******************************************************
#
#	ldcDmpVarSelected
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
function ldcDmpVarSelected()
{
	local selectString="${1}"
	
	declare -p | grep "$selectString"
	echo ""

	return 0
}

