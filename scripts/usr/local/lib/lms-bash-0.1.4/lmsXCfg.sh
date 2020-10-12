# *****************************************************************************
# *****************************************************************************
#
#   lmsXCfg.sh
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

declare -r  lmslib_lmsXCfg="0.1.1"	# version of library

# *****************************************************************************

declare    lmsxcfg_stack
declare    lmsxcfg_ns

declare	-a lmsxcfg_tagTypes=( OPEN OPENCLOSE CLOSE )
declare -a lmsxcfg_tagNames=( 'declare' 'declarations' 'set' '/declarations' )

declare -i  lmsxcfg_trace=0

# *****************************************************************************
#
#	lmsXCfgShowData
#
#		Show the xml data element selected
#
# *****************************************************************************
function lmsXCfgShowData()
{
	local content

	lmsConioDisplay ""
	lmsConioDisplay "XML_ENTITY    : '${lmsxml_Entity}'"

	lmsConioDisplay "XML_CONTENT   :     '${lmsxml_Content}'"

	lmsConioDisplay "XML_TAG_NAME  :     '${lmsxml_TagName}'"
	lmsConioDisplay "XML_TAG_TYPE  :     '${lmsxml_TagType}'"

	[[ "${lmsxml_TagType}" == "OPEN" || "${lmsxml_TagType}" == "OPENCLOSE" ]] &&
	 {
		[[ ${lmsxml_AttributeCount} -eq 0 ]] ||
		 {
			lmsConioDisplay "XML_ATT_COUNT :     '${lmsxml_AttributeCount}'"
		
			for attribute in "${!lmsxml_AttributesArray[@]}"
			do
				lmsConioDisplay "XML_ATT_NAME  :     '${attribute}'"
				lmsConioDisplay "XML_ATT_VAL   :     '${lmsxml_AttributesArray[$attribute]}'"
				
			done
		 }
	 }

	lmsConioDisplay "XML_COMMENT   :     '${lmsxml_Comment}'"
	lmsConioDisplay "XML_PATH      :     '${lmsxml_Path}'"

	lmsConioDisplay "XPATH         :     '${lmsxml_XPath}'"
}


# *********************************************************************************
#
#	lmsXCfgParseTags
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
function lmsXCfgParseTags()
{
	lmsDeclareInt ${1} 0

	[[ "${lmsxcfg_tagTypes}" =~ "${lmsxml_TagType}" ]] || return 1
	[[ "${lmsxcfg_tagNames}" =~ "${lmsxml_TagName}" ]] || return 2

#	[[ ${lmsxml_TagType} != "OPEN" && ${lmsxml_TagType} != "OPENCLOSE" && ${lmsxml_TagType} != "CLOSE" ]] && return 1
#	[[ "${lmsxml_TagName}" != "declare" && "${lmsxml_TagName}" != "declarations" && "${lmsxml_TagName}" != "set" && "${lmsxml_TagName}" != "/declarations" ]] && return 2

	[[ " ${!lmsxml_AttributesArray[@]} " =~ "name" ]] || return 3
	[[ " ${lmsxml_AttributesArray[@]} " =~ "type" ]] || lmsxml_AttributesArray['type']="string"

	lmsDeclareInt ${1} 1

	return 0
}

# *********************************************************************************
#
#	lmsXCfgLoad
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
function lmsXCfgLoad()
{
	lmscfg_xpath=${1}
	lmsxcfg_stack=${2:-"$lmsxcfg_defaultStk"}
	lmsxcfg_trace=${3:-0}

	lmsRDomCallback "lmsXCfgParse" 
	[[ $? -eq 0 ]] || return 1

	lmsStackCreate ${lmsxcfg_stack} lmscfg_xUid 8
	[[ $? -eq 0 ]] || return 2

	lmsStackWrite ${lmsxcfg_stack} "lmstest_"
	[[ $? -eq 0 ]] || return 3

	lmsxcfg_ns=""
	
	lmsRDomParse ${lmscfg_xpath}
	[[ $? -eq 0 ]] || return 4

	return 0
}

# *********************************************************************************
#
#	lmsXCfgParse
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
function lmsXCfgParse()
{
	local parent

	lmsStrTrim "${lmsxml_Content}" lmsxml_Content
	lmsStrTrim "${lmsxml_Comment}" lmsxml_Comment

	[[ -n "${lmsxml_Attributes}" ]] && lmsRDomParseAtt

	[[ ${lmsxcfg_trace} -eq 0 ]] || lmsXCfgShowData

	local pResult=0
	lmsXCfgParseTags pResult
	[[ $? -eq 0 ]] || return 1
	
	[[ $pResult -eq 0 ]] && return 0

	local attribName=""
	[[ " ${!lmsxml_AttributesArray[@]} " =~ "name" ]] && attribName=${lmsxml_AttributesArray['name']}

	local attribType=""
	[[ " ${!lmsxml_AttributesArray[@]} " =~ "type" ]] && attribType=${lmsxml_AttributesArray['type']}

	case ${lmsxml_TagType} in

		"OPEN" | "OPENCLOSE")

			case ${lmsxml_TagName} in

				"declarations")
					
					[[ -n "${attribName}" ]] &&
					 {
						lmsStackWrite ${lmsxcfg_stack} ${lmsxcfg_ns}
						[[ $? -eq 0 ]] || return 1
					 }

					lmsxcfg_ns=${attribName}

					;;

				"declare")

					[[ -n "${lmsxcfg_ns}" ]] && attribName="${lmsxcfg_ns}${attribName}"

					[[ ${attribType} != "element" ]] && 
					 {
   						declare -p "${attribName}" > /dev/null 2>&1
						[[ $? -eq 0 ]] && return 2
					 }

					[[ ${lmsxml_TagType} == "OPENCLOSE" ]] &&
					 {
						[[ -z "${lmsxml_Content}" ]] &&
						 {
							lmsxml_Content=0
							[[ " ${!lmsxml_AttributesArray[@]} " =~ "default" ]] && lmsxml_Content=${lmsxml_AttributesArray["default"]}
						 }
					 }

					case ${attribType} in

						"integer")
							lmsDeclareInt ${attribName} "${lmsxml_Content}"
							;;

						"array")
echo "array '$attribName' '$lmsxml_Content'"

							lmsDeclareArray ${attribName} "${lmsxml_Content}"
							;;

						"associative")
echo "assoc '$attribName' '$lmsxml_Content'"
							lmsDeclareAssoc ${attribName} "${lmsxml_Content}"
							;;

						"element")
echo "element"
							[[ ! " ${!lmsxml_AttributesArray[@]} " =~ "parent" ]] && return 1

							parent="${lmsxcfg_ns}${lmsxml_AttributesArray['parent']}"
echo "  parent: ${parent}"

							lmsDeclareArrayEl "${parent}" "${attribName}" "${lmsxml_Content}"
							;;

						"password")

							lmsDeclarePwd ${attribName} "${lmsxml_Content}"
							;;

						"string")

							lmsDeclareStr ${attribName} "${lmsxml_Content}"
							;;

						*)
							lmsDeclareStr ${attribName} "${lmsxml_Content}"
							;;
							
					esac
					
					[[ $? -eq 0 ]] || return 3
					;;
					
				"set")
					lmsDeclareSet ${attribName} "${lmsxml_Content}"
					[[ $? -eq 0 ]] || return 4
					;;
					
				*)
					;;
			esac

			;;

		"CLOSE")
						
			case ${lmsxml_TagName} in

				"/declarations")

					local namespace=""
					lmsStackRead ${lmsxcfg_stack} namespace
					[[ $? -eq 0 ]] || return 5
					
					lmsxcfg_ns=${namespace}

					;;

				*)
					;;
			esac

			;;

		*)
			;;

	esac

	lmsxml_AttributesArray=()
	return 0
}

