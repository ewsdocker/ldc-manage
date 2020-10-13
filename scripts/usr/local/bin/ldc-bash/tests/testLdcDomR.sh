#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLdcDomR.sh
#
#		Test the DOMDocument, ldcDomRRead, DOMNode and ldcDomToStr libraries.
#
# *****************************************************************************
#
# @author Jay Wheeler.
# @version 0.1.3
# @copyright © 2016, 2017. EarthWalk Software.
# @license Licensed under the Academic Free License version 3.0
# @package Linux Management Scripts
# @subpackage DOM
#
# *****************************************************************************
#
#	Copyright © 2016, 2017. EarthWalk Software
#	Licensed under the Academic Free License, version 3.0.
#
#	Refer to the file named License.txt provided with the source,
#	or from
#
#			http://opensource.org/licenses/academic.php
#
# *****************************************************************************
#
#			Version 0.0.1 - 07-22-2016.
#					0.0.2 - 09-05-2016.
#					0.1.0 - 01-15-2017.
#					0.1.1 - 01-23-2017.
#					0.1.2 - 02-10-2017.
#					0.1.3 - 02-23-2017.
#
# *****************************************************************************
# *****************************************************************************

declare    ldcapp_name="testLdcDomR"
declare    ldclib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $ldcbase_dirLib/stdLibs.sh
. $ldcbase_dirLib/ldcDomTS.sh

. $ldcbase_dirLib/cliOptions.sh
. $ldcbase_dirLib/commonVars.sh

# *****************************************************************************

ldcscr_Version="0.1.3"						# script version

#ldctst_testOptions="$ldcbase_dirEtc/errorCodes.xml"
#ldctst_testOptions="$ldcbase_dirEtc/testDeclarations.xml"
#ldctst_testOptions="$ldcbase_dirEtc/testDOMVariables.xml"
ldctst_testOptions="$ldcbase_dirEtc/cliOptions.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $ldcbase_dirLib/testDump.sh

# *****************************************************************************
# *****************************************************************************
#
#		Test Functions
#
# *****************************************************************************
# *****************************************************************************

# *****************************************************************************
# *****************************************************************************
#
#		Start main program below here
#
# *****************************************************************************
# *****************************************************************************

ldcScriptFileName $0

. $ldcbase_dirLib/openLog.sh
. $ldcbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the ldcDomRRead tests
#
# *****************************************************************************
# *****************************************************************************

ldccli_optLogDisplay=0

ldcDomRInit
[[ $? -eq 0 ]] ||
 {
	ldcConioDebug $LINENO "DomError" "ldcDomRInit failed."
	exit 1
 }

ldcConioDisplay "********************************"
ldcConioDisplay
ldcConioDisplay " Processing XML file '${ldctst_testOptions}' into the document tree."
ldcConioDisplay

ldcDomDParse ${ldctst_testOptions}
[[ $? -eq 0 ]] || ldcConioDebugExit $LINENO "DomError" "ldcDomDParse '${ldctst_Declarations}'"

ldcConioDisplay "********************************"
ldcConioDisplay
ldcConioDisplay " Creating output buffer from the document tree."
ldcConioDisplay

ldcDomToStr ldctst_buffer
[[ $? -eq 0 ]] || ldcConioDebugExit $LINENO "DomError" "ldcDomToStr failed, buffer = '$ldctst_buffer'"

ldcConioDisplay "********************************"
ldcConioDisplay
ldcConioDisplay " Document tree:"
ldcConioDisplay
ldcConioDisplay "---------------------------------"
ldcConioDisplay "$ldctst_buffer"
ldcConioDisplay "---------------------------------"
ldcConioDisplay

# *****************************************************************************

. $ldcbase_dirLib/scriptEnd.sh

# *****************************************************************************
