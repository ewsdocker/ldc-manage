#!/bin/bash
# *****************************************************************************
# *****************************************************************************
#
#	testLmsDomR.sh
#
#		Test the DOMDocument, lmsDomRRead, DOMNode and lmsDomToStr libraries.
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

declare    lmsapp_name="testLmsDomR"
declare    lmslib_bashRelease="0.1.1"

# *****************************************************************************

. testlib/installDirs.sh

. $lmsbase_dirLib/stdLibs.sh
. $lmsbase_dirLib/lmsDomTS.sh

. $lmsbase_dirLib/cliOptions.sh
. $lmsbase_dirLib/commonVars.sh

# *****************************************************************************

lmsscr_Version="0.1.3"						# script version

#lmstst_testOptions="$lmsbase_dirEtc/errorCodes.xml"
#lmstst_testOptions="$lmsbase_dirEtc/testDeclarations.xml"
#lmstst_testOptions="$lmsbase_dirEtc/testDOMVariables.xml"
lmstst_testOptions="$lmsbase_dirEtc/cliOptions.xml"

# *****************************************************************************
# *****************************************************************************
#
#		External Functions
#
# *****************************************************************************
# *****************************************************************************

. $lmsbase_dirLib/testDump.sh

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

lmsScriptFileName $0

. $lmsbase_dirLib/openLog.sh
. $lmsbase_dirLib/startInit.sh

# *****************************************************************************
# *****************************************************************************
#
#		Run the lmsDomRRead tests
#
# *****************************************************************************
# *****************************************************************************

lmscli_optLogDisplay=0

lmsDomRInit
[[ $? -eq 0 ]] ||
 {
	lmsConioDebug $LINENO "DomError" "lmsDomRInit failed."
	exit 1
 }

lmsConioDisplay "********************************"
lmsConioDisplay
lmsConioDisplay " Processing XML file '${lmstst_testOptions}' into the document tree."
lmsConioDisplay

lmsDomDParse ${lmstst_testOptions}
[[ $? -eq 0 ]] || lmsConioDebugExit $LINENO "DomError" "lmsDomDParse '${lmstst_Declarations}'"

lmsConioDisplay "********************************"
lmsConioDisplay
lmsConioDisplay " Creating output buffer from the document tree."
lmsConioDisplay

lmsDomToStr lmstst_buffer
[[ $? -eq 0 ]] || lmsConioDebugExit $LINENO "DomError" "lmsDomToStr failed, buffer = '$lmstst_buffer'"

lmsConioDisplay "********************************"
lmsConioDisplay
lmsConioDisplay " Document tree:"
lmsConioDisplay
lmsConioDisplay "---------------------------------"
lmsConioDisplay "$lmstst_buffer"
lmsConioDisplay "---------------------------------"
lmsConioDisplay

# *****************************************************************************

. $lmsbase_dirLib/scriptEnd.sh

# *****************************************************************************
