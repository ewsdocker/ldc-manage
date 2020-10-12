# *****************************************************************************
# *****************************************************************************
#
#   ldcXCfg.sh
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.1
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage configXML
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
#			Version 0.0.1 - 07-01-2016.
#					0.1.0 - 01-29-2017.
#					0.1.1 - 02-14-2017.
#
# *****************************************************************************
# *****************************************************************************

declare -r  ldclib_ldcXCfg="0.1.1"	# version of library

# *****************************************************************************

declare    ldcxcfg_stack
declare    ldcxcfg_ns

declare	-a ldcxcfg_tagTypes=( OPEN OPENCLOSE CLOSE )
declare -a ldcxcfg_tagNames=( 'declare' 'declarations' 'set' '/declarations' )

declare -i  ldcxcfg_trace=0

# *****************************************************************************
#
#	ldcXCfgShowData
#
#		Show the xml data element selected
#
# *****************************************************************************
function ldcXCfgShowData()
{
	local content

	ldcConioDisplay ""
	ldcConioDisplay "XML_ENTITY    : '${ldcxml_Entity}'"

	ldcConioDisplay "XML_CONTENT   :     '${ldcxml_Content}'"

	ldcConioDisplay "XML_TAG_NAME  :     '${ldcxml_TagName}'"
	ldcConioDisplay "XML_TAG_TYPE  :     '${ldcxml_TagType}'"

	[[ "${ldcxml_TagType}" == "OPEN" || "${ldcxml_TagType}" == "OPENCLOSE" ]] &&
	 {
		[[ ${ldcxml_AttributeCount} -eq 0 ]] ||
		 {
			ldcConioDisplay "XML_ATT_COUNT :     '${ldcxml_AttributeCount}'"
		
			for attribute in "${!ldcxml_AttributesArray[@]}"
			do
				ldcConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				ldcConioDisplay "XML_ATT_VAL   :     '${ldcxml_AttributesArray[$attribute]}'"
				
			done
		 }
	 }

	ldcConioDisplay "XML_COMMENT   :     '${ldcxml_Comment}'"
	ldcConioDisplay "XML_PATH      :     '${ldcxml_Path}'"

	ldcConioDisplay "XPATH         :     '${ldcxml_XPath}'"
}


# *********************************************************************************
#
#	ldcXCfgParseTags
#
#		Check for matching tag names and tags
#
#	parameters:
#		result = variable to receive the result: 1 = match, 0 = no match
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcXCfgParseTags()
{
	ldcDeclareInt ${1} 0

	[[ "${ldcxcfg_tagTypes}" =~ "${ldcxml_TagType}" ]] || return 1
	[[ "${ldcxcfg_tagNames}" =~ "${ldcxml_TagName}" ]] || return 2

#	[[ ${ldcxml_TagType} != "OPEN" && ${ldcxml_TagType} != "OPENCLOSE" && ${ldcxml_TagType} != "CLOSE" ]] && return 1
#	[[ "${ldcxml_TagName}" != "declare" && "${ldcxml_TagName}" != "declarations" && "${ldcxml_TagName}" != "set" && "${ldcxml_TagName}" != "/declarations" ]] && return 2

	[[ " ${!ldcxml_AttributesArray[@]} " =~ "name" ]] || return 3
	[[ " ${ldcxml_AttributesArray[@]} " =~ "type" ]] || ldcxml_AttributesArray['type']="string"

	ldcDeclareInt ${1} 1

	return 0
}

# *********************************************************************************
#
#	ldcXCfgLoad
#
#		initialize and start the XML parser
#
#	parameters:
#		fileName = path to the xml file
#		stackName = internal stack name
#		printTrace = non-zero to trace parse
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcXCfgLoad()
{
	ldccfg_xpath=${1}
	ldcxcfg_stack=${2:-"$ldcxcfg_defaultStk"}
	ldcxcfg_trace=${3:-0}

	ldcRDomCallback "ldcXCfgParse" 
	[[ $? -eq 0 ]] || return 1

	ldcStackCreate ${ldcxcfg_stack} ldccfg_xUid 8
	[[ $? -eq 0 ]] || return 2

	ldcStackWrite ${ldcxcfg_stack} "ldctest_"
	[[ $? -eq 0 ]] || return 3

	ldcxcfg_ns=""
	
	ldcRDomParse ${ldccfg_xpath}
	[[ $? -eq 0 ]] || return 4

	return 0
}

# *********************************************************************************
#
#	ldcXCfgParse
#
#		Load declarations from an XML formatted DOM
#
#	parameters:
#		none
#
#	returns:
#		0 = no error
#		non-zero = error code
#
# *********************************************************************************
function ldcXCfgParse()
{
	local parent

	ldcStrTrim "${ldcxml_Content}" ldcxml_Content
	ldcStrTrim "${ldcxml_Comment}" ldcxml_Comment

	[[ -n "${ldcxml_Attributes}" ]] && ldcRDomParseAtt

	[[ ${ldcxcfg_trace} -eq 0 ]] || ldcXCfgShowData

	local pResult=0
	ldcXCfgParseTags pResult
	[[ $? -eq 0 ]] || return 1
	
	[[ $pResult -eq 0 ]] && return 0

	local attribName=""
	[[ " ${!ldcxml_AttributesArray[@]} " =~ "name" ]] && attribName=${ldcxml_AttributesArray['name']}

	local attribType=""
	[[ " ${!ldcxml_AttributesArray[@]} " =~ "type" ]] && attribType=${ldcxml_AttributesArray['type']}

	case ${ldcxml_TagType} in

		"OPEN" | "OPENCLOSE")

			case ${ldcxml_TagName} in

				"declarations")
					
					[[ -n "${attribName}" ]] &&
					 {
						ldcStackWrite ${ldcxcfg_stack} ${ldcxcfg_ns}
						[[ $? -eq 0 ]] || return 1
					 }

					ldcxcfg_ns=${attribName}

					;;

				"declare")

					[[ -n "${ldcxcfg_ns}" ]] && attribName="${ldcxcfg_ns}${attribName}"

					[[ ${attribType} != "element" ]] && 
					 {
   						declare -p "${attribName}" > /dev/null 2>&1
						[[ $? -eq 0 ]] && return 2
					 }

					[[ ${ldcxml_TagType} == "OPENCLOSE" ]] &&
					 {
						[[ -z "${ldcxml_Content}" ]] &&
						 {
							ldcxml_Content=0
							[[ " ${!ldcxml_AttributesArray[@]} " =~ "default" ]] && ldcxml_Content=${ldcxml_AttributesArray["default"]}
						 }
					 }

					case ${attribType} in

						"integer")
							ldcDeclareInt ${attribName} "${ldcxml_Content}"
							;;

						"array")
echo "array '$attribName' '$ldcxml_Content'"

							ldcDeclareArray ${attribName} "${ldcxml_Content}"
							;;

						"associative")
echo "assoc '$attribName' '$ldcxml_Content'"
							ldcDeclareAssoc ${attribName} "${ldcxml_Content}"
							;;

						"element")
echo "element"
							[[ ! " ${!ldcxml_AttributesArray[@]} " =~ "parent" ]] && return 1

							parent="${ldcxcfg_ns}${ldcxml_AttributesArray['parent']}"
echo "  parent: ${parent}"

							ldcDeclareArrayEl "${parent}" "${attribName}" "${ldcxml_Content}"
							;;

						"password")

							ldcDeclarePwd ${attribName} "${ldcxml_Content}"
							;;

						"string")

							ldcDeclareStr ${attribName} "${ldcxml_Content}"
							;;

						*)
							ldcDeclareStr ${attribName} "${ldcxml_Content}"
							;;
							
					esac
					
					[[ $? -eq 0 ]] || return 3
					;;
					
				"set")
					ldcDeclareSet ${attribName} "${ldcxml_Content}"
					[[ $? -eq 0 ]] || return 4
					;;
					
				*)
					;;
			esac

			;;

		"CLOSE")
						
			case ${ldcxml_TagName} in

				"/declarations")

					local namespace=""
					ldcStackRead ${ldcxcfg_stack} namespace
					[[ $? -eq 0 ]] || return 5
					
					ldcxcfg_ns=${namespace}

					;;

				*)
					;;
			esac

			;;

		*)
			;;

	esac

	ldcxml_AttributesArray=()
	return 0
}

