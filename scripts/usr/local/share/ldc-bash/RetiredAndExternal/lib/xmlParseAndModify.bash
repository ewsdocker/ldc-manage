#!/bin/sh

# *******************************************************
# *******************************************************
#
#   xmlParseAndModify.bash
#
#     By KAM
#
#		http://www.dotkam.com/2007/04/04/sed-to-parse-and-modify-xml-element-nodes/
#
# *******************************************************
# *******************************************************

declare -r lmslib_xmlParseAndModify="0.0.1"	# version of library

# *******************************************************
# *******************************************************
#
#    	External Script
#
# *******************************************************
# *******************************************************

# *******************************************************
#
#	parseXml
#
#		parameters:
#			xmlFileName = path to the file to parse
#			elementName = name of the element to modify
#			newValue = the new value for element name
#
#		returns
#			$? = 0 if no errors, else the error number
#
# *******************************************************
parseXml()
{
	local xmlFileName=$1
	local elementName=$2
	local newValue=$3

	local elementValue
	local tempFile="repl.temp"

	if [ $# -ne 3 ]
	then
		lmsConioDisplay “This script replaces xml element’s value with the one provided as a command parameter \n\n\tUsage: $0 <xml filename> <element name> <new value>”
		return Error_ParseXmlParameters
	fi

	echo ” ” >> $xmlFileName

	lmsConioDebug "parseXml" "searching $xmlFileName for tagname <$elementName> and replacing its value with '$newValue'"

	elementValue=`grep “<$elementName>.*<.$elementName>” $xmlFileName | sed -e “s/^.*<$elementName/<$elementName/” | cut -f2 -d”>”| cut -f1 -d”<”`
	lmsConioDebug "parseXml" "Found the current value for the element <$elementName> - '$elementValue'"

	sed -e “s/<$elementName>$elementValue<\/$elementName>/<$elementName>$newValue<\/$elementName>/g” $xmlFileName > $tempFile

	chmod 666 $xmlFileName
	mv $tempFile $xmlFileName

	return Error_None
}

